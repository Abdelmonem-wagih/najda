import { onDocumentCreated, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

import { COLLECTIONS, INCIDENT_STATUS, INCIDENT_FIELDS, incidentKindFor } from './contract';
import { db } from './lib/firebaseAdmin';
import { tryAutoAssign } from './lib/autoAssign';
import { applyAssignment, releaseAmbulanceInTx } from './lib/assignment';
import { findNearestEligibleAmbulance, isAmbulanceEligible } from './lib/geo';
import { notifyAmbulanceOfAssignment, notifyAdminsNoAmbulanceAvailable } from './lib/notify';
import { handleIncidentStatusChange } from './triggers/statusMachine';

// ═══════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ═══════════════════════════════════════════════════════════════════

async function requireDashboardUser(
  uid: string | undefined,
  allowedRoles: Array<'admin' | 'operator'>
): Promise<FirebaseFirestore.DocumentData> {
  if (!uid) throw new HttpsError('unauthenticated', 'Not authenticated');
  const snap = await db.collection(COLLECTIONS.dashboardUsers).doc(uid).get();
  if (!snap.exists) throw new HttpsError('permission-denied', 'Not a dashboard user');
  const data = snap.data()!;
  if (data.active !== true) throw new HttpsError('permission-denied', 'Account disabled');
  if (!allowedRoles.includes(data.role)) throw new HttpsError('permission-denied', 'Insufficient role');
  return data;
}

async function afterAssignment(
  incidentId: string,
  incidentCollection: 'criticals' | 'incidents',
  ambulanceId: string
): Promise<void> {
  const snap = await db.collection(incidentCollection).doc(incidentId).get();
  const data = snap.data();
  await notifyAmbulanceOfAssignment(
    ambulanceId,
    incidentId,
    incidentKindFor(incidentCollection),
    data?.[INCIDENT_FIELDS.patientName],
    data?.[INCIDENT_FIELDS.address]
  );
  // The citizen is notified of 'assigned' via the status-machine trigger,
  // which fires for this same write (status pending -> assigned) and calls
  // notifyCitizenOfStatus — no separate call needed here.
}

// ═══════════════════════════════════════════════════════════════════
// AUTO-ASSIGN ON CREATE (distance only, no AI — Decision 2)
// ═══════════════════════════════════════════════════════════════════

export const autoAssignCritical = onDocumentCreated('criticals/{incidentId}', async (event) => {
  const incidentId = event.params.incidentId;
  try {
    const ambulanceId = await tryAutoAssign(incidentId, COLLECTIONS.criticals);
    if (ambulanceId) await afterAssignment(incidentId, COLLECTIONS.criticals, ambulanceId);
  } catch (err) {
    console.error(`[autoAssignCritical] ${incidentId}:`, err);
  }
});

export const autoAssignIncident = onDocumentCreated('incidents/{incidentId}', async (event) => {
  const incidentId = event.params.incidentId;
  try {
    const ambulanceId = await tryAutoAssign(incidentId, COLLECTIONS.incidents);
    if (ambulanceId) await afterAssignment(incidentId, COLLECTIONS.incidents, ambulanceId);
  } catch (err) {
    console.error(`[autoAssignIncident] ${incidentId}:`, err);
  }
});

// ═══════════════════════════════════════════════════════════════════
// STATUS MACHINE — validates every transition, reverts illegal ones,
// syncs the ambulance, writes ambulance_history, notifies the citizen.
// ═══════════════════════════════════════════════════════════════════

export const onCriticalStatusChanged = onDocumentUpdated('criticals/{incidentId}', async (event) => {
  if (!event.data) return;
  try {
    await handleIncidentStatusChange(
      event.data.before.data(),
      event.data.after.data(),
      event.data.after.ref,
      event.params.incidentId,
      COLLECTIONS.criticals
    );
  } catch (err) {
    console.error(`[onCriticalStatusChanged] ${event.params.incidentId}:`, err);
  }
});

export const onIncidentStatusChanged = onDocumentUpdated('incidents/{incidentId}', async (event) => {
  if (!event.data) return;
  try {
    await handleIncidentStatusChange(
      event.data.before.data(),
      event.data.after.data(),
      event.data.after.ref,
      event.params.incidentId,
      COLLECTIONS.incidents
    );
  } catch (err) {
    console.error(`[onIncidentStatusChanged] ${event.params.incidentId}:`, err);
  }
});

// ═══════════════════════════════════════════════════════════════════
// RETRY PENDING (every 3 minutes) — caps at 5 attempts, then alerts admins
// ═══════════════════════════════════════════════════════════════════

const MAX_RETRY_ATTEMPTS = 5;

export const retryPending = onSchedule('every 3 minutes', async () => {
  const [critSnap, incSnap] = await Promise.all([
    db.collection(COLLECTIONS.criticals).where(INCIDENT_FIELDS.status, '==', INCIDENT_STATUS.pending).get(),
    db.collection(COLLECTIONS.incidents).where(INCIDENT_FIELDS.status, '==', INCIDENT_STATUS.pending).get(),
  ]);

  const all: Array<{ doc: FirebaseFirestore.QueryDocumentSnapshot; collection: 'criticals' | 'incidents' }> = [
    ...critSnap.docs.map(doc => ({ doc, collection: COLLECTIONS.criticals })),
    ...incSnap.docs.map(doc => ({ doc, collection: COLLECTIONS.incidents })),
  ];

  console.log(`[retryPending] ${all.length} pending incidents`);

  for (const { doc, collection } of all) {
    try {
      const data = doc.data();
      const currentRetryCount = (data[INCIDENT_FIELDS.retryCount] ?? 0) as number;
      if (currentRetryCount >= MAX_RETRY_ATTEMPTS) continue; // already alerted; wait for manual assign

      const ambulanceId = await tryAutoAssign(doc.id, collection);
      if (ambulanceId) {
        await afterAssignment(doc.id, collection, ambulanceId);
        continue;
      }

      const newCount = currentRetryCount + 1;
      await doc.ref.update({
        [INCIDENT_FIELDS.retryCount]: newCount,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      if (newCount >= MAX_RETRY_ATTEMPTS) {
        await notifyAdminsNoAmbulanceAvailable(doc.id, collection, data[INCIDENT_FIELDS.shortId], newCount);
      }
    } catch (err) {
      console.error(`[retryPending] failed for ${collection}/${doc.id}:`, err);
    }
  }
});

// ═══════════════════════════════════════════════════════════════════
// MANUAL ASSIGN / REASSIGN (dashboard — the ONLY callable it uses for both)
// ═══════════════════════════════════════════════════════════════════

export const manualAssign = onCall(async (request) => {
  const callerUid = request.auth?.uid;
  const dashboardUser = await requireDashboardUser(callerUid, ['admin', 'operator']);

  const { incidentId, incidentCollection, ambulanceId, force } = request.data as {
    incidentId: string;
    incidentCollection: 'criticals' | 'incidents';
    ambulanceId: string;
    force?: boolean;
  };

  if (!incidentId || !incidentCollection || !ambulanceId) {
    throw new HttpsError('invalid-argument', 'incidentId, incidentCollection, and ambulanceId are required');
  }
  if (incidentCollection !== COLLECTIONS.criticals && incidentCollection !== COLLECTIONS.incidents) {
    throw new HttpsError('invalid-argument', 'incidentCollection must be "criticals" or "incidents"');
  }

  const forceOverride = force === true && dashboardUser.role === 'admin';

  const incidentRef = db.collection(incidentCollection).doc(incidentId);
  const ambulanceRef = db.collection(COLLECTIONS.ambulances).doc(ambulanceId);

  let releasedPreviousAmbulanceId: string | null = null;

  await db.runTransaction(async (tx) => {
    const [incSnap, ambSnap, trackingSnap] = await Promise.all([
      tx.get(incidentRef),
      tx.get(ambulanceRef),
      tx.get(db.collection(COLLECTIONS.tracking).doc(ambulanceId)),
    ]);

    if (!incSnap.exists) throw new HttpsError('not-found', 'Incident not found');
    if (!ambSnap.exists) throw new HttpsError('not-found', 'Ambulance not found');

    if (!forceOverride) {
      const tracking = trackingSnap.exists ? (trackingSnap.data() as any) : null;
      const eligible = isAmbulanceEligible(ambSnap.data(), tracking, admin.firestore.Timestamp.now());
      if (!eligible) {
        throw new HttpsError(
          'failed-precondition',
          'Ambulance is not currently eligible (offline, busy, or stale location). Pass force:true as an admin to override.'
        );
      }
    }

    const prevAmbulanceId = incSnap.data()?.[INCIDENT_FIELDS.assignedAmbulanceId] as string | undefined;
    if (prevAmbulanceId && prevAmbulanceId !== ambulanceId) {
      releaseAmbulanceInTx(tx, prevAmbulanceId);
      releasedPreviousAmbulanceId = prevAmbulanceId;
    }

    applyAssignment(tx, incidentRef, incidentId, incidentCollection, ambSnap, callerUid!);
  });

  await afterAssignment(incidentId, incidentCollection, ambulanceId);

  return { success: true, releasedPreviousAmbulanceId };
});

// ═══════════════════════════════════════════════════════════════════
// RELEASE AMBULANCE (dashboard — admin or operator)
// ═══════════════════════════════════════════════════════════════════

export const releaseAmbulance = onCall(async (request) => {
  await requireDashboardUser(request.auth?.uid, ['admin', 'operator']);

  const { ambulanceId } = request.data as { ambulanceId: string };
  if (!ambulanceId) throw new HttpsError('invalid-argument', 'ambulanceId required');

  await db.collection(COLLECTIONS.ambulances).doc(ambulanceId).update({
    status: 'available',
    currentIncidentId: null,
    currentIncidentType: null,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});

// ═══════════════════════════════════════════════════════════════════
// AMBULANCE ACCOUNT MANAGEMENT (dashboard — admin only)
// ═══════════════════════════════════════════════════════════════════

export const createAmbulanceAccount = onCall(async (request) => {
  await requireDashboardUser(request.auth?.uid, ['admin']);

  const { ambulanceId, email, password, driverName, phone, area, baseLocation } = request.data as {
    ambulanceId: string;
    email: string;
    password: string;
    driverName: string;
    phone?: string;
    area: string;
    baseLocation: { latitude: number; longitude: number };
  };

  if (!ambulanceId || !email || !password || !baseLocation) {
    throw new HttpsError('invalid-argument', 'Missing required fields: ambulanceId, email, password, baseLocation');
  }

  try {
    const userRecord = await admin.auth().createUser({
      email,
      password,
      phoneNumber: phone || undefined,
      displayName: driverName,
    });
    await admin.auth().setCustomUserClaims(userRecord.uid, { role: 'ambulance', ambulanceId });

    const batch = db.batch();
    batch.set(db.collection(COLLECTIONS.ambulances).doc(ambulanceId), {
      uid: userRecord.uid,
      ambulanceId,
      driverName: driverName ?? '',
      area: area ?? '',
      baseLocation,
      isOnline: false,
      status: 'available',
      currentIncidentId: null,
      currentIncidentType: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    batch.set(db.collection(COLLECTIONS.ambulancePrivate).doc(ambulanceId), {
      email,
      phone: phone ?? null,
      fcmToken: null,
    });
    await batch.commit();

    return { success: true, uid: userRecord.uid, ambulanceId };
  } catch (err: any) {
    console.error('[createAmbulanceAccount] error:', err);
    if (err.code === 'auth/email-already-exists') throw new HttpsError('already-exists', 'Email already registered');
    throw new HttpsError('internal', err.message || 'Failed to create account');
  }
});

export const deleteAmbulanceAccount = onCall(async (request) => {
  await requireDashboardUser(request.auth?.uid, ['admin']);

  const { ambulanceId } = request.data as { ambulanceId: string };
  if (!ambulanceId) throw new HttpsError('invalid-argument', 'ambulanceId required');

  const ambSnap = await db.collection(COLLECTIONS.ambulances).doc(ambulanceId).get();
  if (!ambSnap.exists) throw new HttpsError('not-found', 'Ambulance not found');
  const uid = ambSnap.data()?.uid as string | undefined;

  if (uid) {
    try {
      await admin.auth().updateUser(uid, { disabled: true });
    } catch (err) {
      console.warn(`[deleteAmbulanceAccount] could not disable Auth user ${uid}:`, err);
    }
  }

  const batch = db.batch();
  batch.delete(db.collection(COLLECTIONS.ambulances).doc(ambulanceId));
  batch.delete(db.collection(COLLECTIONS.ambulancePrivate).doc(ambulanceId));
  batch.delete(db.collection(COLLECTIONS.tracking).doc(ambulanceId));
  await batch.commit();

  return { success: true };
});

// ═══════════════════════════════════════════════════════════════════
// DASHBOARD USER MANAGEMENT (admin only)
// ═══════════════════════════════════════════════════════════════════

export const createDashboardUser = onCall(async (request) => {
  await requireDashboardUser(request.auth?.uid, ['admin']);

  const { email, password, name, role } = request.data as {
    email: string;
    password: string;
    name: string;
    role: 'admin' | 'operator';
  };

  if (!email || !password || !name || !['admin', 'operator'].includes(role)) {
    throw new HttpsError('invalid-argument', 'Missing/invalid fields: email, password, name, role');
  }

  try {
    const userRecord = await admin.auth().createUser({ email, password, displayName: name });
    await admin.auth().setCustomUserClaims(userRecord.uid, { role: 'dashboard', dashboardRole: role });
    await db.collection(COLLECTIONS.dashboardUsers).doc(userRecord.uid).set({
      role,
      name,
      email,
      active: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true, uid: userRecord.uid };
  } catch (err: any) {
    console.error('[createDashboardUser] error:', err);
    if (err.code === 'auth/email-already-exists') throw new HttpsError('already-exists', 'Email already registered');
    throw new HttpsError('internal', err.message || 'Failed to create dashboard user');
  }
});

export const setDashboardUserActive = onCall(async (request) => {
  await requireDashboardUser(request.auth?.uid, ['admin']);

  const { uid, active } = request.data as { uid: string; active: boolean };
  if (!uid || typeof active !== 'boolean') throw new HttpsError('invalid-argument', 'uid and active are required');

  await db.collection(COLLECTIONS.dashboardUsers).doc(uid).update({ active });
  try {
    await admin.auth().updateUser(uid, { disabled: !active });
  } catch (err) {
    console.warn(`[setDashboardUserActive] could not toggle Auth disabled for ${uid}:`, err);
  }

  return { success: true };
});

// ═══════════════════════════════════════════════════════════════════
// MARK NOTIFICATION READ
// ═══════════════════════════════════════════════════════════════════

export const markNotificationRead = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Not authenticated');
  const { notificationId } = request.data as { notificationId: string };
  if (!notificationId) throw new HttpsError('invalid-argument', 'notificationId required');

  const ref = db.collection(COLLECTIONS.notifications).doc(notificationId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError('not-found', 'Notification not found');
  const data = snap.data()!;

  const isOwnNotification = data.recipientId === request.auth.uid;
  let isDashboardCaller = false;
  if (data.recipientRole === 'admin') {
    const dashSnap = await db.collection(COLLECTIONS.dashboardUsers).doc(request.auth.uid).get();
    isDashboardCaller = dashSnap.exists && dashSnap.data()?.active === true;
  }
  if (!isOwnNotification && !isDashboardCaller) {
    throw new HttpsError('permission-denied', 'Not your notification');
  }

  await ref.update({ isRead: true, readAt: admin.firestore.FieldValue.serverTimestamp() });
  return { success: true };
});

// ═══════════════════════════════════════════════════════════════════
// NOTE on join requests: v1 decision is a public Firestore create with
// strict field validation in firestore.rules (Phase 3), not a callable —
// there's nothing for the client to call, so no joinRequest export here.
// The legacy dashboard functions/index.js had one; it was deleted (step 1.2).
// ═══════════════════════════════════════════════════════════════════

// NOTE on AI: assignHospitalDisabled (src/ai/assignHospital.disabled.ts) is
// intentionally not exported/imported here. v1 hospital selection is manual.

export { findNearestEligibleAmbulance }; // re-exported for the Phase 6 emulator test suite
