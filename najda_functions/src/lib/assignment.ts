import * as admin from 'firebase-admin';
import { COLLECTIONS, AMBULANCE_STATUS, INCIDENT_STATUS } from '../contract';
import { db } from './firebaseAdmin';

export interface AppliedAssignment {
  ambulanceId: string;
  ambulanceName: string;
  driverName: string;
}

/**
 * Writes the FLAT canonical assignment fields to the incident and syncs the
 * ambulance in the same transaction. Never writes an FCM token onto the
 * incident doc — the token lives in ambulance_private/{id} and is read
 * separately, after the transaction commits, by the notify helpers.
 *
 * `assignedBy` is 'auto' for the automatic nearest-ambulance path, or the
 * calling dashboard user's uid for a manual assign/reassign.
 */
export function applyAssignment(
  tx: FirebaseFirestore.Transaction,
  incidentRef: FirebaseFirestore.DocumentReference,
  incidentId: string,
  incidentCollection: 'criticals' | 'incidents',
  ambulanceDoc: FirebaseFirestore.DocumentSnapshot,
  assignedBy: string
): AppliedAssignment {
  const amb = ambulanceDoc.data()!;
  const ambulanceId = ambulanceDoc.id;
  const ambulanceName: string = amb.plateNumber ?? amb.ambulanceId ?? ambulanceId;
  const driverName: string = amb.driverName ?? amb.name ?? '';

  tx.update(incidentRef, {
    status: INCIDENT_STATUS.assigned,
    assignedAmbulanceId: ambulanceId,
    assignedAmbulanceName: ambulanceName,
    assignedDriverName: driverName,
    assignedVehicleId: amb.plateNumber ?? null,
    assignedAt: admin.firestore.FieldValue.serverTimestamp(),
    assignedBy,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  tx.update(db.collection(COLLECTIONS.ambulances).doc(ambulanceId), {
    status: AMBULANCE_STATUS.assigned,
    currentIncidentId: incidentId,
    currentIncidentType: incidentCollection,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { ambulanceId, ambulanceName, driverName };
}

/** Frees an ambulance back to the pool — used on reassignment, cancellation, completion, and the releaseAmbulance callable. */
export function releaseAmbulanceInTx(tx: FirebaseFirestore.Transaction, ambulanceId: string): void {
  tx.update(db.collection(COLLECTIONS.ambulances).doc(ambulanceId), {
    status: AMBULANCE_STATUS.available,
    currentIncidentId: null,
    currentIncidentType: null,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
