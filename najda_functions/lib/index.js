"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.findNearestEligibleAmbulance = exports.markNotificationRead = exports.setDashboardUserActive = exports.createDashboardUser = exports.deleteAmbulanceAccount = exports.createAmbulanceAccount = exports.releaseAmbulance = exports.manualAssign = exports.retryPending = exports.onIncidentStatusChanged = exports.onCriticalStatusChanged = exports.autoAssignIncident = exports.autoAssignCritical = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const contract_1 = require("./contract");
const autoAssign_1 = require("./lib/autoAssign");
const assignment_1 = require("./lib/assignment");
const geo_1 = require("./lib/geo");
Object.defineProperty(exports, "findNearestEligibleAmbulance", { enumerable: true, get: function () { return geo_1.findNearestEligibleAmbulance; } });
const notify_1 = require("./lib/notify");
const statusMachine_1 = require("./triggers/statusMachine");
admin.initializeApp();
const db = admin.firestore();
// ═══════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ═══════════════════════════════════════════════════════════════════
async function requireDashboardUser(uid, allowedRoles) {
    if (!uid)
        throw new https_1.HttpsError('unauthenticated', 'Not authenticated');
    const snap = await db.collection(contract_1.COLLECTIONS.dashboardUsers).doc(uid).get();
    if (!snap.exists)
        throw new https_1.HttpsError('permission-denied', 'Not a dashboard user');
    const data = snap.data();
    if (data.active !== true)
        throw new https_1.HttpsError('permission-denied', 'Account disabled');
    if (!allowedRoles.includes(data.role))
        throw new https_1.HttpsError('permission-denied', 'Insufficient role');
    return data;
}
async function afterAssignment(incidentId, incidentCollection, ambulanceId) {
    const snap = await db.collection(incidentCollection).doc(incidentId).get();
    const data = snap.data();
    await (0, notify_1.notifyAmbulanceOfAssignment)(ambulanceId, incidentId, (0, contract_1.incidentKindFor)(incidentCollection), data?.[contract_1.INCIDENT_FIELDS.patientName], data?.[contract_1.INCIDENT_FIELDS.address]);
    // The citizen is notified of 'assigned' via the status-machine trigger,
    // which fires for this same write (status pending -> assigned) and calls
    // notifyCitizenOfStatus — no separate call needed here.
}
// ═══════════════════════════════════════════════════════════════════
// AUTO-ASSIGN ON CREATE (distance only, no AI — Decision 2)
// ═══════════════════════════════════════════════════════════════════
exports.autoAssignCritical = (0, firestore_1.onDocumentCreated)('criticals/{incidentId}', async (event) => {
    const incidentId = event.params.incidentId;
    try {
        const ambulanceId = await (0, autoAssign_1.tryAutoAssign)(incidentId, contract_1.COLLECTIONS.criticals);
        if (ambulanceId)
            await afterAssignment(incidentId, contract_1.COLLECTIONS.criticals, ambulanceId);
    }
    catch (err) {
        console.error(`[autoAssignCritical] ${incidentId}:`, err);
    }
});
exports.autoAssignIncident = (0, firestore_1.onDocumentCreated)('incidents/{incidentId}', async (event) => {
    const incidentId = event.params.incidentId;
    try {
        const ambulanceId = await (0, autoAssign_1.tryAutoAssign)(incidentId, contract_1.COLLECTIONS.incidents);
        if (ambulanceId)
            await afterAssignment(incidentId, contract_1.COLLECTIONS.incidents, ambulanceId);
    }
    catch (err) {
        console.error(`[autoAssignIncident] ${incidentId}:`, err);
    }
});
// ═══════════════════════════════════════════════════════════════════
// STATUS MACHINE — validates every transition, reverts illegal ones,
// syncs the ambulance, writes ambulance_history, notifies the citizen.
// ═══════════════════════════════════════════════════════════════════
exports.onCriticalStatusChanged = (0, firestore_1.onDocumentUpdated)('criticals/{incidentId}', async (event) => {
    if (!event.data)
        return;
    try {
        await (0, statusMachine_1.handleIncidentStatusChange)(event.data.before.data(), event.data.after.data(), event.data.after.ref, event.params.incidentId, contract_1.COLLECTIONS.criticals);
    }
    catch (err) {
        console.error(`[onCriticalStatusChanged] ${event.params.incidentId}:`, err);
    }
});
exports.onIncidentStatusChanged = (0, firestore_1.onDocumentUpdated)('incidents/{incidentId}', async (event) => {
    if (!event.data)
        return;
    try {
        await (0, statusMachine_1.handleIncidentStatusChange)(event.data.before.data(), event.data.after.data(), event.data.after.ref, event.params.incidentId, contract_1.COLLECTIONS.incidents);
    }
    catch (err) {
        console.error(`[onIncidentStatusChanged] ${event.params.incidentId}:`, err);
    }
});
// ═══════════════════════════════════════════════════════════════════
// RETRY PENDING (every 3 minutes) — caps at 5 attempts, then alerts admins
// ═══════════════════════════════════════════════════════════════════
const MAX_RETRY_ATTEMPTS = 5;
exports.retryPending = (0, scheduler_1.onSchedule)('every 3 minutes', async () => {
    const [critSnap, incSnap] = await Promise.all([
        db.collection(contract_1.COLLECTIONS.criticals).where(contract_1.INCIDENT_FIELDS.status, '==', contract_1.INCIDENT_STATUS.pending).get(),
        db.collection(contract_1.COLLECTIONS.incidents).where(contract_1.INCIDENT_FIELDS.status, '==', contract_1.INCIDENT_STATUS.pending).get(),
    ]);
    const all = [
        ...critSnap.docs.map(doc => ({ doc, collection: contract_1.COLLECTIONS.criticals })),
        ...incSnap.docs.map(doc => ({ doc, collection: contract_1.COLLECTIONS.incidents })),
    ];
    console.log(`[retryPending] ${all.length} pending incidents`);
    for (const { doc, collection } of all) {
        try {
            const data = doc.data();
            const currentRetryCount = (data[contract_1.INCIDENT_FIELDS.retryCount] ?? 0);
            if (currentRetryCount >= MAX_RETRY_ATTEMPTS)
                continue; // already alerted; wait for manual assign
            const ambulanceId = await (0, autoAssign_1.tryAutoAssign)(doc.id, collection);
            if (ambulanceId) {
                await afterAssignment(doc.id, collection, ambulanceId);
                continue;
            }
            const newCount = currentRetryCount + 1;
            await doc.ref.update({
                [contract_1.INCIDENT_FIELDS.retryCount]: newCount,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            if (newCount >= MAX_RETRY_ATTEMPTS) {
                await (0, notify_1.notifyAdminsNoAmbulanceAvailable)(doc.id, collection, data[contract_1.INCIDENT_FIELDS.shortId], newCount);
            }
        }
        catch (err) {
            console.error(`[retryPending] failed for ${collection}/${doc.id}:`, err);
        }
    }
});
// ═══════════════════════════════════════════════════════════════════
// MANUAL ASSIGN / REASSIGN (dashboard — the ONLY callable it uses for both)
// ═══════════════════════════════════════════════════════════════════
exports.manualAssign = (0, https_1.onCall)(async (request) => {
    const callerUid = request.auth?.uid;
    const dashboardUser = await requireDashboardUser(callerUid, ['admin', 'operator']);
    const { incidentId, incidentCollection, ambulanceId, force } = request.data;
    if (!incidentId || !incidentCollection || !ambulanceId) {
        throw new https_1.HttpsError('invalid-argument', 'incidentId, incidentCollection, and ambulanceId are required');
    }
    if (incidentCollection !== contract_1.COLLECTIONS.criticals && incidentCollection !== contract_1.COLLECTIONS.incidents) {
        throw new https_1.HttpsError('invalid-argument', 'incidentCollection must be "criticals" or "incidents"');
    }
    const forceOverride = force === true && dashboardUser.role === 'admin';
    const incidentRef = db.collection(incidentCollection).doc(incidentId);
    const ambulanceRef = db.collection(contract_1.COLLECTIONS.ambulances).doc(ambulanceId);
    let releasedPreviousAmbulanceId = null;
    await db.runTransaction(async (tx) => {
        const [incSnap, ambSnap, trackingSnap] = await Promise.all([
            tx.get(incidentRef),
            tx.get(ambulanceRef),
            tx.get(db.collection(contract_1.COLLECTIONS.tracking).doc(ambulanceId)),
        ]);
        if (!incSnap.exists)
            throw new https_1.HttpsError('not-found', 'Incident not found');
        if (!ambSnap.exists)
            throw new https_1.HttpsError('not-found', 'Ambulance not found');
        if (!forceOverride) {
            const tracking = trackingSnap.exists ? trackingSnap.data() : null;
            const eligible = (0, geo_1.isAmbulanceEligible)(ambSnap.data(), tracking, admin.firestore.Timestamp.now());
            if (!eligible) {
                throw new https_1.HttpsError('failed-precondition', 'Ambulance is not currently eligible (offline, busy, or stale location). Pass force:true as an admin to override.');
            }
        }
        const prevAmbulanceId = incSnap.data()?.[contract_1.INCIDENT_FIELDS.assignedAmbulanceId];
        if (prevAmbulanceId && prevAmbulanceId !== ambulanceId) {
            (0, assignment_1.releaseAmbulanceInTx)(tx, prevAmbulanceId);
            releasedPreviousAmbulanceId = prevAmbulanceId;
        }
        (0, assignment_1.applyAssignment)(tx, incidentRef, incidentId, incidentCollection, ambSnap, callerUid);
    });
    await afterAssignment(incidentId, incidentCollection, ambulanceId);
    return { success: true, releasedPreviousAmbulanceId };
});
// ═══════════════════════════════════════════════════════════════════
// RELEASE AMBULANCE (dashboard — admin or operator)
// ═══════════════════════════════════════════════════════════════════
exports.releaseAmbulance = (0, https_1.onCall)(async (request) => {
    await requireDashboardUser(request.auth?.uid, ['admin', 'operator']);
    const { ambulanceId } = request.data;
    if (!ambulanceId)
        throw new https_1.HttpsError('invalid-argument', 'ambulanceId required');
    await db.collection(contract_1.COLLECTIONS.ambulances).doc(ambulanceId).update({
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
exports.createAmbulanceAccount = (0, https_1.onCall)(async (request) => {
    await requireDashboardUser(request.auth?.uid, ['admin']);
    const { ambulanceId, email, password, driverName, phone, area, baseLocation } = request.data;
    if (!ambulanceId || !email || !password || !baseLocation) {
        throw new https_1.HttpsError('invalid-argument', 'Missing required fields: ambulanceId, email, password, baseLocation');
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
        batch.set(db.collection(contract_1.COLLECTIONS.ambulances).doc(ambulanceId), {
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
        batch.set(db.collection(contract_1.COLLECTIONS.ambulancePrivate).doc(ambulanceId), {
            email,
            phone: phone ?? null,
            fcmToken: null,
        });
        await batch.commit();
        return { success: true, uid: userRecord.uid, ambulanceId };
    }
    catch (err) {
        console.error('[createAmbulanceAccount] error:', err);
        if (err.code === 'auth/email-already-exists')
            throw new https_1.HttpsError('already-exists', 'Email already registered');
        throw new https_1.HttpsError('internal', err.message || 'Failed to create account');
    }
});
exports.deleteAmbulanceAccount = (0, https_1.onCall)(async (request) => {
    await requireDashboardUser(request.auth?.uid, ['admin']);
    const { ambulanceId } = request.data;
    if (!ambulanceId)
        throw new https_1.HttpsError('invalid-argument', 'ambulanceId required');
    const ambSnap = await db.collection(contract_1.COLLECTIONS.ambulances).doc(ambulanceId).get();
    if (!ambSnap.exists)
        throw new https_1.HttpsError('not-found', 'Ambulance not found');
    const uid = ambSnap.data()?.uid;
    if (uid) {
        try {
            await admin.auth().updateUser(uid, { disabled: true });
        }
        catch (err) {
            console.warn(`[deleteAmbulanceAccount] could not disable Auth user ${uid}:`, err);
        }
    }
    const batch = db.batch();
    batch.delete(db.collection(contract_1.COLLECTIONS.ambulances).doc(ambulanceId));
    batch.delete(db.collection(contract_1.COLLECTIONS.ambulancePrivate).doc(ambulanceId));
    batch.delete(db.collection(contract_1.COLLECTIONS.tracking).doc(ambulanceId));
    await batch.commit();
    return { success: true };
});
// ═══════════════════════════════════════════════════════════════════
// DASHBOARD USER MANAGEMENT (admin only)
// ═══════════════════════════════════════════════════════════════════
exports.createDashboardUser = (0, https_1.onCall)(async (request) => {
    await requireDashboardUser(request.auth?.uid, ['admin']);
    const { email, password, name, role } = request.data;
    if (!email || !password || !name || !['admin', 'operator'].includes(role)) {
        throw new https_1.HttpsError('invalid-argument', 'Missing/invalid fields: email, password, name, role');
    }
    try {
        const userRecord = await admin.auth().createUser({ email, password, displayName: name });
        await admin.auth().setCustomUserClaims(userRecord.uid, { role: 'dashboard', dashboardRole: role });
        await db.collection(contract_1.COLLECTIONS.dashboardUsers).doc(userRecord.uid).set({
            role,
            name,
            email,
            active: true,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { success: true, uid: userRecord.uid };
    }
    catch (err) {
        console.error('[createDashboardUser] error:', err);
        if (err.code === 'auth/email-already-exists')
            throw new https_1.HttpsError('already-exists', 'Email already registered');
        throw new https_1.HttpsError('internal', err.message || 'Failed to create dashboard user');
    }
});
exports.setDashboardUserActive = (0, https_1.onCall)(async (request) => {
    await requireDashboardUser(request.auth?.uid, ['admin']);
    const { uid, active } = request.data;
    if (!uid || typeof active !== 'boolean')
        throw new https_1.HttpsError('invalid-argument', 'uid and active are required');
    await db.collection(contract_1.COLLECTIONS.dashboardUsers).doc(uid).update({ active });
    try {
        await admin.auth().updateUser(uid, { disabled: !active });
    }
    catch (err) {
        console.warn(`[setDashboardUserActive] could not toggle Auth disabled for ${uid}:`, err);
    }
    return { success: true };
});
// ═══════════════════════════════════════════════════════════════════
// MARK NOTIFICATION READ
// ═══════════════════════════════════════════════════════════════════
exports.markNotificationRead = (0, https_1.onCall)(async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Not authenticated');
    const { notificationId } = request.data;
    if (!notificationId)
        throw new https_1.HttpsError('invalid-argument', 'notificationId required');
    const ref = db.collection(contract_1.COLLECTIONS.notifications).doc(notificationId);
    const snap = await ref.get();
    if (!snap.exists)
        throw new https_1.HttpsError('not-found', 'Notification not found');
    const data = snap.data();
    const isOwnNotification = data.recipientId === request.auth.uid;
    let isDashboardCaller = false;
    if (data.recipientRole === 'admin') {
        const dashSnap = await db.collection(contract_1.COLLECTIONS.dashboardUsers).doc(request.auth.uid).get();
        isDashboardCaller = dashSnap.exists && dashSnap.data()?.active === true;
    }
    if (!isOwnNotification && !isDashboardCaller) {
        throw new https_1.HttpsError('permission-denied', 'Not your notification');
    }
    await ref.update({ isRead: true, readAt: admin.firestore.FieldValue.serverTimestamp() });
    return { success: true };
});
//# sourceMappingURL=index.js.map