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
exports.ADMIN_BROADCAST_RECIPIENT_ID = void 0;
exports.sendFcm = sendFcm;
exports.saveNotification = saveNotification;
exports.notifyAmbulanceOfAssignment = notifyAmbulanceOfAssignment;
exports.notifyCitizenOfStatus = notifyCitizenOfStatus;
exports.notifyAdminsNoAmbulanceAvailable = notifyAdminsNoAmbulanceAvailable;
const admin = __importStar(require("firebase-admin"));
const contract_1 = require("../contract");
const firebaseAdmin_1 = require("./firebaseAdmin");
/** Sentinel recipientId for broadcast-to-all-dashboard-users notifications (no single admin uid to target). */
exports.ADMIN_BROADCAST_RECIPIENT_ID = 'admin-broadcast';
async function sendFcm(token, title, body, data, channelId = 'najda_emergency') {
    try {
        await admin.messaging().send({
            token,
            notification: { title, body },
            data: { ...data, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
            android: {
                priority: 'high',
                notification: { channelId, priority: 'max', defaultSound: true, defaultVibrateTimings: true },
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
async function saveNotification(recipientId, recipientRole, type, title, body, incidentId, incidentCollection) {
    await firebaseAdmin_1.db.collection(contract_1.COLLECTIONS.notifications).add({
        recipientId,
        recipientRole,
        type,
        title,
        body,
        incidentId,
        incidentCollection,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
const CRITICAL_ASSIGN_TITLE = '🚨 حالة طوارئ عاجلة';
const INCIDENT_ASSIGN_TITLE = '📋 بلاغ حادث جديد';
/** Notify the assigned ambulance crew (FCM token lives in ambulance_private, read here — never on the incident doc). */
async function notifyAmbulanceOfAssignment(ambulanceId, incidentId, incidentKind, patientName, address) {
    const collection = (0, contract_1.incidentCollectionFor)(incidentKind);
    const privateSnap = await firebaseAdmin_1.db.collection(contract_1.COLLECTIONS.ambulancePrivate).doc(ambulanceId).get();
    const fcmToken = privateSnap.exists ? privateSnap.data()?.fcmToken : undefined;
    const title = incidentKind === 'critical' ? CRITICAL_ASSIGN_TITLE : INCIDENT_ASSIGN_TITLE;
    const body = `${patientName ?? 'مريض غير محدد'} — ${address || 'تحقق من الموقع'}`;
    if (fcmToken) {
        await sendFcm(fcmToken, title, body, { incidentId, incidentCollection: collection, type: `${incidentKind}_assigned` }, incidentKind === 'critical' ? 'emergency_channel' : 'incidents_channel');
    }
    await saveNotification(ambulanceId, contract_1.NOTIFICATION_RECIPIENT_ROLE.ambulance, `${incidentKind}_assigned`, title, body, incidentId, collection);
}
const CITIZEN_STATUS_TEXT = {
    [contract_1.INCIDENT_STATUS.assigned]: {
        title: '🚑 تم تعيين سيارة إسعاف',
        body: ({ ambulanceName }) => `سيارة الإسعاف ${ambulanceName ?? ''} في طريقها إليك الآن`,
    },
    [contract_1.INCIDENT_STATUS.onMission]: {
        title: '🚑 السيارة في الطريق',
        body: () => 'سيارة الإسعاف تتحرك الآن نحو موقعك',
    },
    [contract_1.INCIDENT_STATUS.arrived]: {
        title: '📍 وصلت سيارة الإسعاف',
        body: () => 'وصلت سيارة الإسعاف إلى موقعك',
    },
    [contract_1.INCIDENT_STATUS.toHospital]: {
        title: '🏥 في الطريق إلى المستشفى',
        body: () => 'تم نقل المريض وهو الآن في الطريق إلى المستشفى',
    },
    [contract_1.INCIDENT_STATUS.completed]: {
        title: '✅ اكتملت المهمة',
        body: () => 'تم إنهاء هذا البلاغ بنجاح',
    },
};
/** Notify the reporting citizen of a status change. Silently skips if they never saved an FCM token (see CC10). */
async function notifyCitizenOfStatus(incidentId, incidentCollection, incidentData, status) {
    const copy = CITIZEN_STATUS_TEXT[status];
    if (!copy)
        return;
    const patientUid = incidentData.patientUid;
    if (!patientUid)
        return;
    const citizenSnap = await firebaseAdmin_1.db.collection(contract_1.COLLECTIONS.citizens).doc(patientUid).get();
    const fcmToken = citizenSnap.exists ? citizenSnap.data()?.fcmToken : undefined;
    const title = copy.title;
    const body = copy.body({ ambulanceName: incidentData.assignedAmbulanceName });
    if (fcmToken) {
        await sendFcm(fcmToken, title, body, { incidentId, incidentCollection, type: `citizen_${status}` });
    }
    await saveNotification(patientUid, contract_1.NOTIFICATION_RECIPIENT_ROLE.citizen, `citizen_${status}`, title, body, incidentId, incidentCollection);
}
async function notifyAdminsNoAmbulanceAvailable(incidentId, incidentCollection, shortId, retryCount) {
    await saveNotification(exports.ADMIN_BROADCAST_RECIPIENT_ID, contract_1.NOTIFICATION_RECIPIENT_ROLE.admin, 'no_ambulance_available', '⚠️ لا توجد سيارة إسعاف متاحة', `البلاغ ${shortId ?? incidentId} بانتظار التعيين اليدوي بعد ${retryCount} محاولات`, incidentId, incidentCollection);
}
//# sourceMappingURL=notify.js.map