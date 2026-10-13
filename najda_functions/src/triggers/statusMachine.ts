import * as admin from 'firebase-admin';
import {
  COLLECTIONS,
  INCIDENT_STATUS,
  AMBULANCE_STATUS,
  STATUS_TRANSITIONS,
  type IncidentStatus,
} from '../contract';
import { db } from '../lib/firebaseAdmin';
import { notifyCitizenOfStatus } from '../lib/notify';

const AMBULANCE_STATUS_FOR: Partial<Record<IncidentStatus, string>> = {
  [INCIDENT_STATUS.onMission]: AMBULANCE_STATUS.onMission,
  [INCIDENT_STATUS.arrived]: AMBULANCE_STATUS.arrived,
  [INCIDENT_STATUS.toHospital]: AMBULANCE_STATUS.toHospital,
};

/**
 * Validates every status transition on an incident/critical doc and reverts
 * illegal ones. This is a structural backstop on top of Firestore rules
 * (which restrict *who* may write which transition) — this trigger only
 * checks that the sequence itself is a legal forward hop, regardless of who
 * made the write.
 *
 * On an accepted transition it syncs the ambulance's status, releases the
 * ambulance and writes ambulance_history on completion/cancellation, and
 * notifies the citizen.
 */
export async function handleIncidentStatusChange(
  beforeData: FirebaseFirestore.DocumentData,
  afterData: FirebaseFirestore.DocumentData,
  incidentRef: FirebaseFirestore.DocumentReference,
  incidentId: string,
  incidentCollection: 'criticals' | 'incidents'
): Promise<void> {
  // Loop-breaker: a revert write (below) sets pendingRevert=true so the
  // *next* trigger invocation it causes doesn't re-validate (which would
  // ping-pong forever — an illegal A→B being reverted to B→A isn't a legal
  // forward transition either). That next invocation just clears the flag
  // and returns; the write clearing it causes a third invocation where
  // before.status === after.status, a true no-op that returns immediately
  // at the check below. Three invocations total per illegal attempt, then it stops.
  if (afterData.pendingRevert === true) {
    await incidentRef.update({ pendingRevert: admin.firestore.FieldValue.delete() });
    return;
  }

  const fromStatus = beforeData.status as IncidentStatus | undefined;
  const toStatus = afterData.status as IncidentStatus | undefined;
  if (!toStatus || fromStatus === toStatus) return;

  const legalTargets = new Set((STATUS_TRANSITIONS[fromStatus as IncidentStatus] ?? []).map(t => t.to));
  if (!fromStatus || !legalTargets.has(toStatus)) {
    console.warn(
      `[status-machine] illegal transition on ${incidentCollection}/${incidentId}: ${fromStatus} -> ${toStatus}; reverting`
    );
    await incidentRef.update({
      status: fromStatus ?? INCIDENT_STATUS.pending,
      pendingRevert: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  // 'pending' -> 'assigned' is applyAssignment's job — it already syncs the
  // ambulance atomically in the same transaction. Nothing further to do.
  if (toStatus === INCIDENT_STATUS.assigned) return;

  const ambulanceId = afterData.assignedAmbulanceId as string | undefined;

  if (toStatus === INCIDENT_STATUS.cancelled) {
    if (ambulanceId) {
      await db.collection(COLLECTIONS.ambulances).doc(ambulanceId).update({
        status: AMBULANCE_STATUS.available,
        currentIncidentId: null,
        currentIncidentType: null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    return;
  }

  if (toStatus === INCIDENT_STATUS.completed) {
    if (ambulanceId) {
      await db.collection(COLLECTIONS.ambulances).doc(ambulanceId).update({
        status: AMBULANCE_STATUS.available,
        currentIncidentId: null,
        currentIncidentType: null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      await db.collection(COLLECTIONS.ambulanceHistory).add({
        ambulanceId,
        incidentId,
        incidentCollection,
        patientName: afterData.patientName ?? 'مريض',
        address: afterData.address ?? '',
        status: INCIDENT_STATUS.completed,
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    await notifyCitizenOfStatus(incidentId, incidentCollection, afterData, toStatus);
    return;
  }

  // on_mission / arrived / to_hospital: ambulance status mirrors the incident, not released yet.
  const ambStatus = AMBULANCE_STATUS_FOR[toStatus];
  if (ambulanceId && ambStatus) {
    await db.collection(COLLECTIONS.ambulances).doc(ambulanceId).update({
      status: ambStatus,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  await notifyCitizenOfStatus(incidentId, incidentCollection, afterData, toStatus);
}
