import * as admin from 'firebase-admin';
import { COLLECTIONS, INCIDENT_STATUS, INCIDENT_FIELDS } from '../contract';
import { db } from './firebaseAdmin';
import { findNearestEligibleAmbulance, buildDedupeKey } from './geo';
import { applyAssignment } from './assignment';

/**
 * Finds the nearest eligible ambulance and assigns it, distance only, no AI.
 * Used by both onDocumentCreated triggers (first attempt) and retryPending
 * (subsequent attempts for incidents still stuck 'pending').
 *
 * Idempotent: re-reads the incident fresh inside the transaction and bails
 * out if it's no longer 'pending' — this makes at-least-once trigger
 * redelivery (and overlapping retryPending runs) safe to call twice on the
 * same doc without corrupting a valid dispatch.
 *
 * Returns the assigned ambulance id, or null if the incident is still
 * pending (no eligible ambulance) or was found to be a duplicate.
 */
export async function tryAutoAssign(
  incidentId: string,
  incidentCollection: 'criticals' | 'incidents'
): Promise<string | null> {
  let assignedAmbulanceId: string | null = null;

  const incidentRef = db.collection(incidentCollection).doc(incidentId);

  await db.runTransaction(async (tx) => {
    const freshSnap = await tx.get(incidentRef);
    if (!freshSnap.exists) return;
    const data = freshSnap.data()!;

    if (data[INCIDENT_FIELDS.status] !== INCIDENT_STATUS.pending) return; // already handled by an earlier invocation

    const lat = data[INCIDENT_FIELDS.latitude];
    const lng = data[INCIDENT_FIELDS.longitude];
    if (lat == null || lng == null) return; // no location yet — nothing to assign against

    const dedupeKey = buildDedupeKey(lat, lng, data[INCIDENT_FIELDS.createdAt]);

    const dupSnap = await tx.get(
      db.collection(incidentCollection)
        .where(INCIDENT_FIELDS.patientUid, '==', data[INCIDENT_FIELDS.patientUid])
        .where(INCIDENT_FIELDS.dedupeKey, '==', dedupeKey)
        .where(INCIDENT_FIELDS.status, 'in', [
          INCIDENT_STATUS.assigned,
          INCIDENT_STATUS.onMission,
          INCIDENT_STATUS.arrived,
          INCIDENT_STATUS.toHospital,
        ])
    );
    // Exclude this doc's own id so an at-least-once redelivery of the
    // CREATE event (which already assigned this very doc) never flags
    // itself as a duplicate and overwrites a valid dispatch.
    const realDuplicate = dupSnap.docs.find(d => d.id !== incidentId);
    if (realDuplicate) {
      tx.update(incidentRef, {
        status: INCIDENT_STATUS.duplicate,
        dedupeKey,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    const nearest = await findNearestEligibleAmbulance(tx, lat, lng);
    if (!nearest) {
      tx.update(incidentRef, { dedupeKey, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
      return; // stays pending; retryPending will try again
    }

    applyAssignment(tx, incidentRef, incidentId, incidentCollection, nearest.ambulanceDoc, 'auto');
    tx.update(incidentRef, { dedupeKey });
    assignedAmbulanceId = nearest.ambulanceDoc.id;
  });

  return assignedAmbulanceId;
}
