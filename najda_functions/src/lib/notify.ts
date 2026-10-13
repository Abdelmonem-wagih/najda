import * as admin from 'firebase-admin';
import {
  COLLECTIONS,
  NOTIFICATION_RECIPIENT_ROLE,
  INCIDENT_STATUS,
  type IncidentStatus,
  type IncidentKind,
  incidentCollectionFor,
} from '../contract';

const db = admin.firestore();

/** Sentinel recipientId for broadcast-to-all-dashboard-users notifications (no single admin uid to target). */
export const ADMIN_BROADCAST_RECIPIENT_ID = 'admin-broadcast';

export async function sendFcm(
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
  channelId = 'najda_emergency'
): Promise<void> {
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
  } catch (err) {
    console.error('[FCM] Failed:', err);
  }
}

export async function saveNotification(
  recipientId: string,
  recipientRole: 'ambulance' | 'citizen' | 'admin',
  type: string,
  title: string,
  body: string,
  incidentId: string,
  incidentCollection: 'criticals' | 'incidents'
): Promise<void> {
  await db.collection(COLLECTIONS.notifications).add({
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
export async function notifyAmbulanceOfAssignment(
  ambulanceId: string,
  incidentId: string,
  incidentKind: IncidentKind,
  patientName: string | undefined,
  address: string | undefined
): Promise<void> {
  const collection = incidentCollectionFor(incidentKind);
  const privateSnap = await db.collection(COLLECTIONS.ambulancePrivate).doc(ambulanceId).get();
  const fcmToken = privateSnap.exists ? (privateSnap.data()?.fcmToken as string | undefined) : undefined;

  const title = incidentKind === 'critical' ? CRITICAL_ASSIGN_TITLE : INCIDENT_ASSIGN_TITLE;
  const body = `${patientName ?? 'مريض غير محدد'} — ${address || 'تحقق من الموقع'}`;

  if (fcmToken) {
    await sendFcm(
      fcmToken,
      title,
      body,
      { incidentId, incidentCollection: collection, type: `${incidentKind}_assigned` },
      incidentKind === 'critical' ? 'emergency_channel' : 'incidents_channel'
    );
  }
  await saveNotification(ambulanceId, NOTIFICATION_RECIPIENT_ROLE.ambulance, `${incidentKind}_assigned`, title, body, incidentId, collection);
}

const CITIZEN_STATUS_TEXT: Partial<Record<IncidentStatus, { title: string; body: (ctx: { ambulanceName?: string }) => string }>> = {
  [INCIDENT_STATUS.assigned]: {
    title: '🚑 تم تعيين سيارة إسعاف',
    body: ({ ambulanceName }) => `سيارة الإسعاف ${ambulanceName ?? ''} في طريقها إليك الآن`,
  },
  [INCIDENT_STATUS.onMission]: {
    title: '🚑 السيارة في الطريق',
    body: () => 'سيارة الإسعاف تتحرك الآن نحو موقعك',
  },
  [INCIDENT_STATUS.arrived]: {
    title: '📍 وصلت سيارة الإسعاف',
    body: () => 'وصلت سيارة الإسعاف إلى موقعك',
  },
  [INCIDENT_STATUS.toHospital]: {
    title: '🏥 في الطريق إلى المستشفى',
    body: () => 'تم نقل المريض وهو الآن في الطريق إلى المستشفى',
  },
  [INCIDENT_STATUS.completed]: {
    title: '✅ اكتملت المهمة',
    body: () => 'تم إنهاء هذا البلاغ بنجاح',
  },
};

/** Notify the reporting citizen of a status change. Silently skips if they never saved an FCM token (see CC10). */
export async function notifyCitizenOfStatus(
  incidentId: string,
  incidentCollection: 'criticals' | 'incidents',
  incidentData: FirebaseFirestore.DocumentData,
  status: IncidentStatus
): Promise<void> {
  const copy = CITIZEN_STATUS_TEXT[status];
  if (!copy) return;

  const patientUid = incidentData.patientUid as string | undefined;
  if (!patientUid) return;

  const citizenSnap = await db.collection(COLLECTIONS.citizens).doc(patientUid).get();
  const fcmToken = citizenSnap.exists ? (citizenSnap.data()?.fcmToken as string | undefined) : undefined;

  const title = copy.title;
  const body = copy.body({ ambulanceName: incidentData.assignedAmbulanceName });

  if (fcmToken) {
    await sendFcm(fcmToken, title, body, { incidentId, incidentCollection, type: `citizen_${status}` });
  }
  await saveNotification(patientUid, NOTIFICATION_RECIPIENT_ROLE.citizen, `citizen_${status}`, title, body, incidentId, incidentCollection);
}

export async function notifyAdminsNoAmbulanceAvailable(
  incidentId: string,
  incidentCollection: 'criticals' | 'incidents',
  shortId: string | undefined,
  retryCount: number
): Promise<void> {
  await saveNotification(
    ADMIN_BROADCAST_RECIPIENT_ID,
    NOTIFICATION_RECIPIENT_ROLE.admin,
    'no_ambulance_available',
    '⚠️ لا توجد سيارة إسعاف متاحة',
    `البلاغ ${shortId ?? incidentId} بانتظار التعيين اليدوي بعد ${retryCount} محاولات`,
    incidentId,
    incidentCollection
  );
}
