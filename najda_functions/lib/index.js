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
exports.createAmbulancesAccount = exports.releaseAmbulance = exports.markNotificationRead = exports.manualAssign = exports.retryPending = exports.autoAssignIncident = exports.autoAssignCritical = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
const db = admin.firestore();
// ═══════════════════════════════════════════════════════════════════
// STATUS CONSTANTS — match Flutter app exactly
// ═══════════════════════════════════════════════════════════════════
const INCIDENT_STATUS = {
    PENDING: 'pending',
    ASSIGNED: 'assigned',
    ON_MISSION: 'on_mission',
    ARRIVED: 'arrived',
    TO_HOSPITAL: 'to_hospital',
    COMPLETED: 'completed',
    CANCELLED: 'cancelled',
    DUPLICATE: 'duplicate',
};
const AMBULANCE_STATUS = {
    AVAILABLE: 'available',
    ASSIGNED: 'assigned',
    ON_MISSION: 'on_mission',
    ARRIVED: 'arrived',
    TO_HOSPITAL: 'to_hospital',
};
// ═══════════════════════════════════════════════════════════════════
// UTILITIES
// ═══════════════════════════════════════════════════════════════════
function haversineKm(lat1, lng1, lat2, lng2) {
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) ** 2
        + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180)
            * Math.sin(dLng / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
function buildDedupeKey(lat, lng, ts) {
    const ms = ts instanceof admin.firestore.Timestamp ? ts.toMillis() : Date.now();
    return `${lat.toFixed(3)}_${lng.toFixed(3)}_${Math.floor(ms / 300000)}`;
}
// ─── FIXED: Query ambulances with correct fields ──────────────────
async function getAvailableAmbulances(tx) {
    // TWO conditions: isOnline=true AND status='available'
    // AND has location
    const snap = await tx.get(db.collection('ambulances')
        .where('isOnline', '==', true)
        .where('status', '==', AMBULANCE_STATUS.AVAILABLE));
    // Filter: must have lat/lng to be dispatchable
    return snap.docs.filter(d => {
        const data = d.data();
        return data.latitude != null && data.longitude != null;
    });
}
// ─── Find nearest ambulance ───────────────────────────────────────
function findNearest(docs, lat, lng) {
    let nearest = null;
    let shortest = Infinity;
    for (const doc of docs) {
        const d = doc.data();
        // Extra safety: skip if already on mission
        if (d.currentIncidentId)
            continue;
        const dist = haversineKm(lat, lng, d.latitude, d.longitude);
        if (dist < shortest) {
            shortest = dist;
            nearest = doc;
        }
    }
    return nearest ? { doc: nearest, distKm: shortest } : null;
}
// ─── Apply assignment ─────────────────────────────────────────────
async function applyAssignment(tx, incidentRef, ambulanceDoc, incidentId, incidentType // 'incident' | 'critical'
) {
    const amb = ambulanceDoc.data();
    if (!amb)
        return;
    const ambulanceName = amb.ambulanceId ?? amb.plateNumber ?? ambulanceDoc.id;
    const driverName = amb.driverName ?? amb.name ??
        `${amb.firstName ?? ''} ${amb.lastName ?? ''}`.trim();
    // 1. Update incident
    tx.update(incidentRef, {
        status: INCIDENT_STATUS.ASSIGNED,
        assignedAmbulanceId: ambulanceDoc.id,
        assignedAmbulanceName: ambulanceName,
        assignedDriverName: driverName,
        assignedFcmToken: amb.fcmToken ?? null,
        assignedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // 2. Update ambulance — Use canonical status
    tx.update(db.collection('ambulances').doc(ambulanceDoc.id), {
        status: AMBULANCE_STATUS.ASSIGNED,
        currentIncidentId: incidentId,
        currentIncidentType: incidentType,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
// ─── Send FCM ─────────────────────────────────────────────────────
async function sendFcm(token, title, body, data, channelId = 'najda_emergency') {
    try {
        await admin.messaging().send({
            token,
            notification: { title, body },
            data: { ...data, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
            android: {
                priority: 'high',
                notification: {
                    channelId,
                    priority: 'max',
                    defaultSound: true,
                    defaultVibrateTimings: true,
                },
            },
            apns: {
                payload: { aps: { alert: { title, body }, sound: 'default', badge: 1 } },
            },
        });
    }
    catch (err) {
        console.error('[FCM] Failed:', err);
    }
}
// ─── Save notification ────────────────────────────────────────────
async function saveNotification(ambulanceId, title, body, type, incidentId, incidentType, extra = {}) {
    await db.collection('notifications').add({
        ambulanceId,
        title,
        body,
        type,
        incidentId,
        incidentType,
        deepLink: `najda://incident/${incidentType}/${incidentId}`,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        ...extra,
    });
}
// ═══════════════════════════════════════════════════════════════════
// FUNCTION 1: AUTO-ASSIGN CRITICAL (SOS)
// Triggers on: criticals/{incidentId}
// ═══════════════════════════════════════════════════════════════════
exports.autoAssignCritical = (0, firestore_1.onDocumentCreated)('criticals/{incidentId}', async (event) => {
    const snap = event.data;
    if (!snap)
        return;
    const incidentId = event.params.incidentId;
    const data = snap.data();
    if (!data.latitude || !data.longitude) {
        console.warn('[critical] Missing location data');
        return;
    }
    const dedupeKey = buildDedupeKey(data.latitude, data.longitude, data.createdAt);
    let assignedAmbulanceId = null;
    await db.runTransaction(async (tx) => {
        // Duplicate check
        const dupSnap = await tx.get(db.collection('criticals')
            .where('patientUid', '==', data.patientUid)
            .where('dedupeKey', '==', dedupeKey)
            .where('status', 'in', [INCIDENT_STATUS.ASSIGNED, INCIDENT_STATUS.ON_MISSION])
            .limit(1));
        if (!dupSnap.empty) {
            tx.update(snap.ref, {
                status: INCIDENT_STATUS.DUPLICATE,
                dedupeKey,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`[critical] Duplicate → ${incidentId}`);
            return;
        }
        // Find nearest ONLINE + AVAILABLE ambulance
        const available = await getAvailableAmbulances(tx);
        console.log(`[critical] Available ambulances: ${available.length}`);
        const result = findNearest(available, data.latitude, data.longitude);
        if (!result) {
            tx.update(snap.ref, {
                status: INCIDENT_STATUS.PENDING,
                dedupeKey,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`[critical] No ambulance available → pending`);
            return;
        }
        await applyAssignment(tx, snap.ref, result.doc, incidentId, 'critical');
        tx.update(snap.ref, { dedupeKey });
        assignedAmbulanceId = result.doc.id;
        console.log(`[critical] ${incidentId} → ambulance ${result.doc.id} (${result.distKm.toFixed(1)}km)`);
    });
    // Send FCM (outside transaction)
    if (assignedAmbulanceId) {
        const ambDoc = await db.collection('ambulances').doc(assignedAmbulanceId).get();
        const amb = ambDoc.data();
        if (amb?.fcmToken) {
            await sendFcm(amb.fcmToken, '🚨 حالة طوارئ عاجلة', `مريض ${data.patientName ?? 'غير محدد'} — ${data.address || 'تحقق من الموقع'}`, {
                incidentId,
                incidentType: 'critical',
                displayId: data.shortId ?? incidentId.substring(0, 8),
                patientName: data.patientName ?? '',
                latitude: String(data.latitude),
                longitude: String(data.longitude),
            }, 'emergency_channel');
            await saveNotification(assignedAmbulanceId, '🚨 حالة طوارئ عاجلة', `مريض ${data.patientName ?? 'غير محدد'} — ${data.address || 'تحقق من الموقع'}`, 'critical_assigned', incidentId, 'critical', { patientName: data.patientName, latitude: data.latitude, longitude: data.longitude });
        }
    }
});
// ═══════════════════════════════════════════════════════════════════
// FUNCTION 2: AUTO-ASSIGN INCIDENT (Accident)
// Triggers on: incidents/{incidentId}
// ═══════════════════════════════════════════════════════════════════
exports.autoAssignIncident = (0, firestore_1.onDocumentCreated)('incidents/{incidentId}', async (event) => {
    const snap = event.data;
    if (!snap)
        return;
    const incidentId = event.params.incidentId;
    const data = snap.data();
    if (!data.latitude || !data.longitude) {
        console.warn('[incident] Missing location data');
        return;
    }
    const dedupeKey = buildDedupeKey(data.latitude, data.longitude, data.createdAt);
    let assignedAmbulanceId = null;
    await db.runTransaction(async (tx) => {
        const dupSnap = await tx.get(db.collection('incidents')
            .where('patientUid', '==', data.patientUid)
            .where('dedupeKey', '==', dedupeKey)
            .where('status', 'in', [INCIDENT_STATUS.ASSIGNED, INCIDENT_STATUS.ON_MISSION])
            .limit(1));
        if (!dupSnap.empty) {
            tx.update(snap.ref, {
                status: INCIDENT_STATUS.DUPLICATE,
                dedupeKey,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            return;
        }
        const available = await getAvailableAmbulances(tx);
        console.log(`[incident] Available ambulances: ${available.length}`);
        const result = findNearest(available, data.latitude, data.longitude);
        if (!result) {
            tx.update(snap.ref, {
                status: INCIDENT_STATUS.PENDING,
                dedupeKey,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`[incident] No ambulance available → pending`);
            return;
        }
        await applyAssignment(tx, snap.ref, result.doc, incidentId, 'incident');
        tx.update(snap.ref, { dedupeKey });
        assignedAmbulanceId = result.doc.id;
        console.log(`[incident] ${incidentId} → ambulance ${result.doc.id} (${result.distKm.toFixed(1)}km)`);
    });
    // Send FCM (outside transaction)
    if (assignedAmbulanceId) {
        const ambDoc = await db.collection('ambulances').doc(assignedAmbulanceId).get();
        const amb = ambDoc.data();
        if (amb?.fcmToken) {
            await sendFcm(amb.fcmToken, '📋 بلاغ حادث جديد', `${data.patientName ?? 'مريض'} — ${data.address || 'تحقق من الموقع'}`, {
                incidentId,
                incidentType: 'incident',
                displayId: data.shortId ?? incidentId.substring(0, 8),
                patientName: data.patientName ?? '',
                latitude: String(data.latitude),
                longitude: String(data.longitude),
            }, 'incidents_channel');
            await saveNotification(assignedAmbulanceId, '📋 بلاغ حادث جديد', `تم تعيينك للمريض ${data.patientName ?? 'غير محدد'}`, 'incident_assigned', incidentId, 'incident', { patientName: data.patientName, latitude: data.latitude, longitude: data.longitude });
        }
    }
});
// ═══════════════════════════════════════════════════════════════════
// FUNCTION 3: RETRY PENDING (every 3 minutes)
// ═══════════════════════════════════════════════════════════════════
exports.retryPending = (0, scheduler_1.onSchedule)('every 3 minutes', async () => {
    const [critSnap, incSnap] = await Promise.all([
        db.collection('criticals').where('status', '==', INCIDENT_STATUS.PENDING).get(),
        db.collection('incidents').where('status', '==', INCIDENT_STATUS.PENDING).get(),
    ]);
    const allPending = [
        ...critSnap.docs.map(d => ({ doc: d, type: 'critical' })),
        ...incSnap.docs.map(d => ({ doc: d, type: 'incident' })),
    ];
    console.log(`[retry] ${allPending.length} pending incidents`);
    for (const { doc, type } of allPending) {
        const data = doc.data();
        if (!data.latitude || !data.longitude)
            continue;
        try {
            await db.runTransaction(async (tx) => {
                const available = await getAvailableAmbulances(tx);
                const result = findNearest(available, data.latitude, data.longitude);
                if (!result)
                    return;
                await applyAssignment(tx, doc.ref, result.doc, doc.id, type);
                console.log(`[retry] ${doc.id} → ${result.doc.id}`);
            });
        }
        catch (err) {
            console.error(`[retry] Failed for ${doc.id}:`, err);
        }
    }
});
// ═══════════════════════════════════════════════════════════════════
// FUNCTION 4: MANUAL ASSIGN FROM DASHBOARD (Callable)
// ═══════════════════════════════════════════════════════════════════
exports.manualAssign = (0, https_1.onCall)(async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Not authenticated');
    const { incidentId, incidentType, ambulanceId } = request.data;
    if (!incidentId || !incidentType || !ambulanceId) {
        throw new https_1.HttpsError('invalid-argument', 'Missing fields');
    }
    const collection = incidentType === 'critical' ? 'criticals' : 'incidents';
    const incidentRef = db.collection(collection).doc(incidentId);
    const ambDoc = await db.collection('ambulances').doc(ambulanceId).get();
    if (!ambDoc.exists)
        throw new https_1.HttpsError('not-found', 'Ambulance not found');
    await db.runTransaction(async (tx) => {
        const incSnap = await tx.get(incidentRef);
        if (!incSnap.exists)
            throw new https_1.HttpsError('not-found', 'Incident not found');
        // Release previous ambulance if reassigning
        const prevAmbId = incSnap.data()?.assignedAmbulanceId;
        if (prevAmbId && prevAmbId !== ambulanceId) {
            tx.update(db.collection('ambulances').doc(prevAmbId), {
                status: AMBULANCE_STATUS.AVAILABLE,
                currentIncidentId: null,
                currentIncidentType: null,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        await applyAssignment(tx, incidentRef, ambDoc, incidentId, incidentType);
    });
    // Notify
    const amb = ambDoc.data();
    if (amb.fcmToken) {
        const incSnap = await incidentRef.get();
        const inc = incSnap.data();
        await sendFcm(amb.fcmToken, incidentType === 'critical' ? '🚨 تعيين طوارئ يدوي' : '📋 تعيين حادث يدوي', `تم تعيينك للمريض ${inc.patientName ?? ''}`, { incidentId, incidentType, patientName: inc.patientName ?? '' });
    }
    return { success: true };
});
// ═══════════════════════════════════════════════════════════════════
// FUNCTION 5: MARK NOTIFICATION READ (Callable)
// ═══════════════════════════════════════════════════════════════════
exports.markNotificationRead = (0, https_1.onCall)(async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Not authenticated');
    const { notificationId } = request.data;
    if (!notificationId)
        throw new https_1.HttpsError('invalid-argument', 'notificationId required');
    await db.collection('notifications').doc(notificationId).update({
        isRead: true,
        readAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true };
});
// ═══════════════════════════════════════════════════════════════════
// FUNCTION 6: RELEASE AMBULANCE (Callable — dashboard)
// ═══════════════════════════════════════════════════════════════════
exports.releaseAmbulance = (0, https_1.onCall)(async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Not authenticated');
    const { ambulanceId } = request.data;
    if (!ambulanceId)
        throw new https_1.HttpsError('invalid-argument', 'ambulanceId required');
    await db.collection('ambulances').doc(ambulanceId).update({
        status: AMBULANCE_STATUS.AVAILABLE,
        currentIncidentId: null,
        currentIncidentType: null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true };
});
// ═══════════════════════════════════════════════════════════════════
// FUNCTION 7: CREATE AMBULANCES ACCOUNT (Admin/Dashboard)
// ═══════════════════════════════════════════════════════════════════
exports.createAmbulancesAccount = (0, https_1.onCall)(async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Not authenticated');
    // In a real app, check for admin custom claim here
    const { ambulancesId, email, password, driverName, phone, area, baseLocation } = request.data;
    if (!ambulancesId || !email || !password) {
        throw new https_1.HttpsError('invalid-argument', 'Missing required fields (ambulancesId, email, password)');
    }
    try {
        // 1. Create Auth User
        const userRecord = await admin.auth().createUser({
            email,
            password,
            phoneNumber: phone,
            displayName: driverName,
        });
        // 2. Set Custom Claims
        await admin.auth().setCustomUserClaims(userRecord.uid, {
            role: 'ambulances',
            ambulancesId: ambulancesId,
        });
        // 3. Create Firestore Doc in 'ambulances'
        await db.collection('ambulances').doc(ambulancesId).set({
            uid: userRecord.uid,
            ambulancesId,
            email,
            driverName,
            phone,
            area,
            baseLocation,
            currentLocation: baseLocation, // initial location is base
            status: 'available',
            isOnline: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { success: true, uid: userRecord.uid };
    }
    catch (error) {
        console.error('[createAmbulancesAccount] Error:', error);
        throw new https_1.HttpsError('internal', error.message || 'Failed to create account');
    }
});
//# sourceMappingURL=index.js.map