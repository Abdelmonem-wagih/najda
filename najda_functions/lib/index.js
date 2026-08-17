"use strict";
/**
 * ╔══════════════════════════════════════════════════════════════════╗
 * ║           NAJDA — Firebase Cloud Functions v2                   ║
 * ║   Auto-assign • AI Hospital Selection • FCM • Retry • Groq AI  ║
 * ╚══════════════════════════════════════════════════════════════════╝
 *
 * Environment variables required (set via Firebase Functions config):
 *   GROQ_API_KEY  — Groq API key (uses llama-3.3-70b and llama-3.1-8b)
 */
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.releaseAmbulance = exports.createParamedicAccount = exports.handleMedicalReportSubmission = exports.triageSymptoms = exports.najdaAIAssistant = exports.selectHospitalWithAI = exports.retryPendingAssignments = exports.handleParamedicStatusChange = exports.notifyOnRegularAssign = exports.notifyOnEmergencyAssign = exports.autoAssignRegularReport = exports.autoAssignEmergencyReport = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const groq_sdk_1 = __importDefault(require("groq-sdk"));
admin.initializeApp();
const db = admin.firestore();
/* ═══════════════════════════════════════════════════════════════════
   UTILITIES
═══════════════════════════════════════════════════════════════════ */
/** Haversine distance in km */
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos((lat1 * Math.PI) / 180) *
            Math.cos((lat2 * Math.PI) / 180) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
const DUPLICATE_WINDOW_MS = 5 * 60 * 1000;
function buildDedupeKey(lat, lng, ts) {
    let ms = Date.now();
    if (ts instanceof admin.firestore.Timestamp)
        ms = ts.toMillis();
    const bucket = Math.floor(ms / DUPLICATE_WINDOW_MS);
    return `${lat.toFixed(3)}_${lng.toFixed(3)}_${bucket}`;
}
/** Find the nearest available paramedic from a Firestore snapshot */
function findNearest(paramedics, lat, lng) {
    let nearest = null;
    let shortest = Infinity;
    paramedics.forEach((doc) => {
        const p = { id: doc.id, ...doc.data() };
        if (p.assignedReportId || !p.latitude || !p.longitude)
            return;
        const d = calculateDistance(lat, lng, p.latitude, p.longitude);
        if (d < shortest) {
            shortest = d;
            nearest = p;
        }
    });
    return nearest;
}
async function getAvailableParamedics(transaction) {
    return transaction.get(db.collection('paramedics')
        .where('isAvailable', '==', true)
        .where('isActive', '==', true)
        .where('status', '==', 'available'));
}
async function saveNotification(paramedicId, title, body, type, reportId, reportType, extraData = {}) {
    await db.collection('notifications').add({
        paramedicId,
        title,
        body,
        type,
        reportId,
        reportType,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        source: 'cloud_function',
        ...extraData,
    });
}
async function sendFcm(token, title, body, data, priority = 'high', channelId = 'najda_channel') {
    try {
        await admin.messaging().send({
            token,
            notification: { title, body },
            data: { ...data, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
            android: {
                priority,
                notification: {
                    channelId,
                    priority: priority === 'high' ? 'max' : 'default',
                    defaultVibrateTimings: true,
                    defaultSound: true,
                },
            },
            apns: {
                payload: {
                    aps: {
                        alert: { title, body },
                        sound: 'default',
                        badge: 1,
                        'content-available': 1,
                        'interruption-level': priority === 'high' ? 'critical' : 'active',
                    },
                },
            },
        });
    }
    catch (err) {
        console.error('FCM send failed:', err);
    }
}
/* ═══════════════════════════════════════════════════════════════════
   1. AUTO-ASSIGN — EMERGENCY REPORT
═══════════════════════════════════════════════════════════════════ */
exports.autoAssignEmergencyReport = (0, firestore_1.onDocumentCreated)('emergency_reports/{reportId}', async (event) => {
    const snap = event.data;
    if (!snap)
        return;
    const reportId = event.params.reportId;
    const report = snap.data();
    if (!report.latitude || !report.longitude || !report.patientUid) {
        console.warn('[emergency] Invalid report data');
        return;
    }
    const dedupeKey = buildDedupeKey(report.latitude, report.longitude, report.createdAt);
    await db.runTransaction(async (tx) => {
        // ── Duplicate check ───────────────────────────────────────────
        const dupSnap = await tx.get(db.collection('emergency_reports')
            .where('patientUid', '==', report.patientUid)
            .where('dedupeKey', '==', dedupeKey)
            .where('status', 'in', ['assigned', 'in_progress'])
            .limit(1));
        if (!dupSnap.empty) {
            tx.update(snap.ref, {
                status: 'duplicate',
                dedupeKey,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`[emergency] Duplicate report detected → ${reportId}`);
            return;
        }
        // ── Find nearest paramedic ────────────────────────────────────
        const paramedicsSnap = await getAvailableParamedics(tx);
        const nearest = findNearest(paramedicsSnap, report.latitude, report.longitude);
        if (!nearest) {
            tx.update(snap.ref, {
                status: 'pending_assignment',
                dedupeKey,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`[emergency] No paramedic available → pending_assignment`);
            return;
        }
        // ── Assign ────────────────────────────────────────────────────
        tx.update(db.collection('paramedics').doc(nearest.id), {
            isAvailable: false,
            status: 'OnMission',
            assignedReportId: reportId,
            assignedReportType: 'emergency_report',
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        tx.update(snap.ref, {
            assignedParamedicId: nearest.id,
            status: 'assigned',
            dedupeKey,
            assignedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`[emergency] Assigned ${reportId} → paramedic ${nearest.id}`);
    });
});
/* ═══════════════════════════════════════════════════════════════════
   2. AUTO-ASSIGN — REGULAR REPORT
═══════════════════════════════════════════════════════════════════ */
exports.autoAssignRegularReport = (0, firestore_1.onDocumentCreated)('reports/{reportId}', async (event) => {
    const snap = event.data;
    if (!snap)
        return;
    const reportId = event.params.reportId;
    const report = snap.data();
    if (!report.latitude || !report.longitude || !report.patientUid) {
        console.warn('[report] Invalid report data');
        return;
    }
    const dedupeKey = buildDedupeKey(report.latitude, report.longitude, report.createdAt);
    await db.runTransaction(async (tx) => {
        const dupSnap = await tx.get(db.collection('reports')
            .where('patientUid', '==', report.patientUid)
            .where('dedupeKey', '==', dedupeKey)
            .where('status', 'in', ['assigned', 'in_progress'])
            .limit(1));
        if (!dupSnap.empty) {
            tx.update(snap.ref, {
                status: 'duplicate',
                dedupeKey,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            return;
        }
        const paramedicsSnap = await getAvailableParamedics(tx);
        const nearest = findNearest(paramedicsSnap, report.latitude, report.longitude);
        if (!nearest) {
            tx.update(snap.ref, {
                status: 'pending_assignment',
                dedupeKey,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            return;
        }
        tx.update(db.collection('paramedics').doc(nearest.id), {
            isAvailable: false,
            status: 'OnMission',
            assignedReportId: reportId,
            assignedReportType: 'report',
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        tx.update(snap.ref, {
            assignedParamedicId: nearest.id,
            status: 'assigned',
            dedupeKey,
            assignedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`[report] Assigned ${reportId} → paramedic ${nearest.id}`);
    });
});
/* ═══════════════════════════════════════════════════════════════════
   3. FCM NOTIFY — ON EMERGENCY ASSIGNMENT
═══════════════════════════════════════════════════════════════════ */
exports.notifyOnEmergencyAssign = (0, firestore_1.onDocumentUpdated)('emergency_reports/{reportId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    const reportId = event.params.reportId;
    if (!before || !after)
        return;
    if (before.assignedParamedicId || !after.assignedParamedicId)
        return;
    const paramDoc = await db.collection('paramedics').doc(after.assignedParamedicId).get();
    const paramedic = paramDoc.data();
    await saveNotification(after.assignedParamedicId, '🚨 بلاغ طوارئ عاجل', `مريض ${after.patientName ?? 'غير محدد'} يحتاج مساعدة فورية`, 'emergency', reportId, 'emergency_report');
    if (paramedic?.fcmToken) {
        await sendFcm(paramedic.fcmToken, '🚨 بلاغ طوارئ عاجل', `مريض ${after.patientName ?? 'غير محدد'} يحتاج مساعدة فورية — ${after.address ?? 'تحقق من الموقع'}`, {
            reportId,
            type: 'emergency',
            paramedicId: after.assignedParamedicId,
            patientName: after.patientName ?? '',
            latitude: String(after.latitude),
            longitude: String(after.longitude),
        }, 'high', 'emergency_channel');
    }
});
/* ═══════════════════════════════════════════════════════════════════
   4. FCM NOTIFY — ON REGULAR REPORT ASSIGNMENT
═══════════════════════════════════════════════════════════════════ */
exports.notifyOnRegularAssign = (0, firestore_1.onDocumentUpdated)('reports/{reportId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    const reportId = event.params.reportId;
    if (!before || !after)
        return;
    if (before.assignedParamedicId || !after.assignedParamedicId)
        return;
    const paramDoc = await db.collection('paramedics').doc(after.assignedParamedicId).get();
    const paramedic = paramDoc.data();
    await saveNotification(after.assignedParamedicId, '📋 تعيين بلاغ جديد', `تم تعيينك للمريض ${after.patientName ?? 'غير محدد'}`, 'assignment', reportId, 'report');
    if (paramedic?.fcmToken) {
        await sendFcm(paramedic.fcmToken, '📋 تعيين بلاغ جديد', `تم تعيينك للمريض ${after.patientName ?? 'غير محدد'}`, {
            reportId,
            type: 'assignment',
            paramedicId: after.assignedParamedicId,
            latitude: String(after.latitude),
            longitude: String(after.longitude),
        }, 'high', 'assignment_channel');
    }
});
/* ═══════════════════════════════════════════════════════════════════
   5. PARAMEDIC STATUS MACHINE
   OnMission → arrived → onTheWayToHospital → available
═══════════════════════════════════════════════════════════════════ */
exports.handleParamedicStatusChange = (0, firestore_1.onDocumentUpdated)('paramedics/{paramedicId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    const paramedicId = event.params.paramedicId;
    if (!before || !after || before.status === after.status)
        return;
    console.log(`[paramedic] ${paramedicId}: ${before.status} → ${after.status}`);
    const reportId = after.assignedReportId;
    const reportType = after.assignedReportType;
    if (!reportId || !reportType)
        return;
    const collection = reportType === 'emergency_report' ? 'emergency_reports' : 'reports';
    const reportRef = db.collection(collection).doc(reportId);
    await db.runTransaction(async (tx) => {
        const reportSnap = await tx.get(reportRef);
        if (!reportSnap.exists)
            return;
        const report = reportSnap.data();
        if (after.status === 'arrived' && report.status === 'assigned') {
            // Paramedic arrived at patient → report in_progress
            tx.update(reportRef, {
                status: 'in_progress',
                arrivedAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`[report] ${reportId} → in_progress`);
        }
        if (after.status === 'available' && before.status === 'onTheWayToHospital') {
            // Paramedic delivered patient to hospital → complete
            tx.update(reportRef, {
                status: 'completed',
                completedAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Reset paramedic assignment
            tx.update(db.collection('paramedics').doc(paramedicId), {
                assignedReportId: null,
                assignedReportType: null,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Mission history log
            const historyRef = db.collection('paramedic_history').doc();
            tx.set(historyRef, {
                paramedicId,
                reportId,
                reportType: collection,
                patientName: report.patientName ?? null,
                patientPhone: report.phoneNumber ?? null,
                location: {
                    latitude: report.latitude,
                    longitude: report.longitude,
                    address: report.address ?? null,
                },
                assignedAt: report.assignedAt ?? null,
                completedAt: admin.firestore.FieldValue.serverTimestamp(),
                status: 'completed',
                ambulanceId: after.ambulanceId ?? null,
                paramedicName: `${after.firstName ?? ''} ${after.lastName ?? ''}`.trim(),
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Notify paramedic mission complete
            if (after.fcmToken) {
                await sendFcm(after.fcmToken, '✅ تمت المهمة بنجاح', `تمت مهمة المريض ${report.patientName ?? ''} بنجاح`, { type: 'mission_completed', reportId, paramedicId }, 'normal', 'mission_channel');
            }
            console.log(`[report] ${reportId} completed. Paramedic ${paramedicId} available.`);
        }
    });
});
/* ═══════════════════════════════════════════════════════════════════
   6. RETRY PENDING ASSIGNMENTS (every 5 min)
═══════════════════════════════════════════════════════════════════ */
exports.retryPendingAssignments = (0, scheduler_1.onSchedule)('every 5 minutes', async () => {
    console.log('[retry] Checking for pending_assignment reports...');
    const [pendingReports, pendingEmergencies] = await Promise.all([
        db.collection('reports').where('status', '==', 'pending_assignment').get(),
        db.collection('emergency_reports').where('status', '==', 'pending_assignment').get(),
    ]);
    const allPending = [...pendingReports.docs, ...pendingEmergencies.docs];
    console.log(`[retry] Found ${allPending.length} pending reports`);
    for (const doc of allPending) {
        const report = doc.data();
        const colId = doc.ref.parent.id;
        try {
            await db.runTransaction(async (tx) => {
                const paramedicsSnap = await getAvailableParamedics(tx);
                const nearest = findNearest(paramedicsSnap, report.latitude, report.longitude);
                if (!nearest)
                    return;
                tx.update(db.collection('paramedics').doc(nearest.id), {
                    isAvailable: false,
                    status: 'OnMission',
                    assignedReportId: doc.id,
                    assignedReportType: colId === 'emergency_reports' ? 'emergency_report' : 'report',
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                tx.update(doc.ref, {
                    assignedParamedicId: nearest.id,
                    status: 'assigned',
                    assignedAt: admin.firestore.FieldValue.serverTimestamp(),
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                console.log(`[retry] ${doc.id} → ${nearest.id}`);
            });
        }
        catch (err) {
            console.error(`[retry] Failed for ${doc.id}:`, err);
        }
    }
});
/* ═══════════════════════════════════════════════════════════════════
   7. GROQ AI — HOSPITAL SELECTION
   Called from Flutter app after paramedic submits medical report.
   Returns best hospital suggestion based on patient data + location.
═══════════════════════════════════════════════════════════════════ */
exports.selectHospitalWithAI = (0, https_1.onCall)({ secrets: ['GROQ_API_KEY'] }, async (request) => {
    const data = request.data;
    if (!data.reportId || !data.patientLat || !data.patientLng) {
        throw new https_1.HttpsError('invalid-argument', 'Missing required fields');
    }
    const groqApiKey = process.env.GROQ_API_KEY;
    if (!groqApiKey) {
        throw new https_1.HttpsError('internal', 'Groq API key not configured');
    }
    const groq = new groq_sdk_1.default({ apiKey: groqApiKey });
    // Build clinical summary for Groq
    const medSummary = Object.entries(data.medicalAnswers || {})
        .map(([k, v]) => `${k}: ${v}`)
        .join('\n');
    const prompt = `
أنت نظام ذكاء اصطناعي طبي لنظام نجدة للطوارئ في مصر.

بيانات المريض:
- الموقع الجغرافي: خط عرض ${data.patientLat}، خط طول ${data.patientLng}
- نوع الحادث: ${data.incidentType ?? 'غير محدد'}
- أمراض مزمنة: ${(data.chronicDiseases ?? []).join('، ') || 'لا يوجد'}
- حساسية: ${(data.allergies ?? []).join('، ') || 'لا يوجد'}
- أدوية حالية: ${(data.currentMedications ?? []).join('، ') || 'لا يوجد'}

التقييم الطبي الميداني:
${medSummary}

ملاحظات المسعف: ${data.additionalNotes ?? 'لا يوجد'}

بناءً على هذه البيانات، اقترح أفضل مستشفى قريب من القاهرة، مصر لاستقبال هذا المريض.
يجب أن تراعي:
1. درجة خطورة الحالة
2. التخصصات المطلوبة بناءً على نوع الحادث والحالة الطبية
3. القرب من موقع المريض
4. توافر طاقم الطوارئ والإمكانيات

أجب بـ JSON فقط بهذا الهيكل (بدون أي نص خارج الـ JSON):
{
  "name": "اسم المستشفى",
  "address": "العنوان التفصيلي",
  "distance": "المسافة التقديرية من الموقع",
  "reason": "سبب الاختيار بناءً على الحالة الطبية",
  "specialties": ["تخصص 1", "تخصص 2"],
  "estimatedArrival": "الوقت التقديري للوصول",
  "urgencyLevel": "critical | high | medium | low",
  "notes": "أي ملاحظات طبية للطاقم"
}
`;
    let suggestion;
    try {
        const completion = await groq.chat.completions.create({
            model: 'llama-3.3-70b-versatile',
            messages: [{ role: 'user', content: prompt }],
            temperature: 0.2,
            max_tokens: 600,
        });
        const raw = completion.choices[0]?.message?.content ?? '{}';
        const clean = raw.replace(/```json|```/g, '').trim();
        suggestion = JSON.parse(clean);
    }
    catch (err) {
        console.error('[groq] Hospital selection failed:', err);
        // Fallback suggestion
        suggestion = {
            name: 'مستشفى قريب من موقعك',
            address: 'تحقق من خرائط جوجل',
            distance: 'غير محدد',
            reason: 'لم يتمكن الذكاء الاصطناعي من التحليل — اتصل بمركز العمليات',
            specialties: ['طوارئ'],
            estimatedArrival: 'غير محدد',
        };
    }
    // Save suggestion to report document
    const collection = data.reportType === 'emergency_report' ? 'emergency_reports' : 'reports';
    await db.collection(collection).doc(data.reportId).update({
        suggestedHospital: suggestion,
        hospitalSelectedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`[groq] Hospital selected for ${data.reportId}: ${suggestion.name}`);
    return { success: true, hospital: suggestion };
});
/* ═══════════════════════════════════════════════════════════════════
   8. GROQ AI — IN-APP ASSISTANT (Callable)
   General-purpose medical assistant for citizens and paramedics.
   Citizens: first aid guidance, symptom triage
   Paramedics: clinical decision support, drug interactions
═══════════════════════════════════════════════════════════════════ */
exports.najdaAIAssistant = (0, https_1.onCall)({ secrets: ['GROQ_API_KEY'] }, async (request) => {
    const { message, role, history, context: ctx } = request.data;
    if (!message) {
        throw new https_1.HttpsError('invalid-argument', 'Message is required');
    }
    const groqApiKey = process.env.GROQ_API_KEY;
    if (!groqApiKey) {
        throw new https_1.HttpsError('internal', 'Groq API key not configured');
    }
    const groq = new groq_sdk_1.default({ apiKey: groqApiKey });
    const systemPrompt = role === 'paramedic'
        ? `أنت مساعد طبي متخصص لمسعفين الإسعاف في نظام نجدة للطوارئ بمصر.
تقدم:
• دعم القرار الإكلينيكي الميداني
• إرشادات الجرعات والتفاعلات الدوائية
• بروتوكولات الإسعاف الميداني
• تحليل الحالات وتحديد الأولويات

التزم بالمعلومات الطبية الدقيقة. إذا كانت الحالة تتجاوز نطاق إجابتك أو كانت حرجة جداً، وجّه المسعف لطلب دعم مستشفى أو تواصل مع طبيب.
أجب بالعربية بإيجاز ووضوح مناسبَين للعمل الميداني.
${ctx ? `\nمعلومات الحالة الحالية:\n${ctx}` : ''}`
        : `أنت مساعد طوارئ طبي للمواطنين في نظام نجدة للطوارئ بمصر.
تقدم:
• إرشادات الإسعافات الأولية خطوة بخطوة
• تحديد مستوى خطورة الحالة
• توجيه المواطن لما يفعله قبل وصول الإسعاف
• طمأنة المواطن وتهدئته

لا تشخّص الأمراض. دوماً أوصِ بالاتصال بالإسعاف (123) في الحالات الطارئة.
أجب بالعربية بلغة بسيطة يفهمها المواطن العادي.
${ctx ? `\nالسياق: ${ctx}` : ''}`;
    const messages = [
        { role: 'system', content: systemPrompt },
        ...(history ?? []),
        { role: 'user', content: message },
    ];
    try {
        const completion = await groq.chat.completions.create({
            model: 'llama-3.1-8b-instant',
            messages,
            temperature: role === 'paramedic' ? 0.1 : 0.3,
            max_tokens: 800,
        });
        const reply = completion.choices[0]?.message?.content ?? 'عذراً، لم أتمكن من الإجابة. حاول مرة أخرى.';
        return { success: true, reply };
    }
    catch (err) {
        console.error('[groq] Assistant error:', err);
        throw new https_1.HttpsError('internal', 'AI assistant temporarily unavailable');
    }
});
/* ═══════════════════════════════════════════════════════════════════
   9. GROQ AI — FIRST AID TRIAGE (Callable)
   Citizen sends symptoms → AI returns urgency + first aid steps
═══════════════════════════════════════════════════════════════════ */
exports.triageSymptoms = (0, https_1.onCall)({ secrets: ['GROQ_API_KEY'] }, async (request) => {
    const { symptoms, patientAge, chronicDiseases } = request.data;
    if (!symptoms) {
        throw new https_1.HttpsError('invalid-argument', 'Symptoms are required');
    }
    const groqApiKey = process.env.GROQ_API_KEY;
    if (!groqApiKey) {
        throw new https_1.HttpsError('internal', 'Groq API key not configured');
    }
    const groq = new groq_sdk_1.default({ apiKey: groqApiKey });
    const prompt = `
أنت نظام طوارئ طبي ذكي لتقييم الأعراض في مصر.

الأعراض التي يصفها المريض: ${symptoms}
العمر: ${patientAge ?? 'غير محدد'}
أمراض مزمنة: ${(chronicDiseases ?? []).join('، ') || 'لا يوجد'}

قيّم الحالة وأجب بـ JSON فقط:
{
  "urgencyLevel": "critical | high | medium | low",
  "urgencyLabel": "حرجة | عاجلة | متوسطة | خفيفة",
  "callAmbulance": true/false,
  "firstAidSteps": ["خطوة 1", "خطوة 2", "..."],
  "doNotDo": ["لا تفعل 1", "لا تفعل 2"],
  "waitingInstructions": "ما يفعله المريض أثناء انتظار الإسعاف",
  "possibleConditions": ["احتمال 1", "احتمال 2"]
}
`;
    try {
        const completion = await groq.chat.completions.create({
            model: 'llama-3.1-8b-instant',
            messages: [{ role: 'user', content: prompt }],
            temperature: 0.1,
            max_tokens: 700,
        });
        const raw = completion.choices[0]?.message?.content ?? '{}';
        const clean = raw.replace(/```json|```/g, '').trim();
        const result = JSON.parse(clean);
        return { success: true, triage: result };
    }
    catch (err) {
        console.error('[groq] Triage error:', err);
        throw new https_1.HttpsError('internal', 'Triage service temporarily unavailable');
    }
});
/* ═══════════════════════════════════════════════════════════════════
   10. MEDICAL REPORT HANDLER
   When paramedic submits medical report → trigger hospital selection
═══════════════════════════════════════════════════════════════════ */
exports.handleMedicalReportSubmission = (0, firestore_1.onDocumentCreated)('medical_reports/{reportId}', async (event) => {
    const snap = event.data;
    if (!snap)
        return;
    const medReport = snap.data();
    console.log(`[medical] Report submitted for ${medReport.reportType}:${medReport.reportId}`);
    // Auto-update paramedic status → onTheWayToHospital
    await db.collection('paramedics').doc(medReport.paramedicId).update({
        status: 'onTheWayToHospital',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Mark report as having medical assessment submitted
    const collection = medReport.reportType === 'emergency_report' ? 'emergency_reports' : 'reports';
    await db.collection(collection).doc(medReport.reportId).update({
        medicalReportSubmitted: true,
        medicalReportId: event.params.reportId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`[medical] Paramedic ${medReport.paramedicId} → onTheWayToHospital`);
});
/* ═══════════════════════════════════════════════════════════════════
   11. CREATE PARAMEDIC ACCOUNT (Callable — Admin only)
   Creates Firebase Auth + Firestore doc for a new paramedic.
   Called from the React dashboard.
═══════════════════════════════════════════════════════════════════ */
exports.createParamedicAccount = (0, https_1.onCall)(async (request) => {
    // Verify caller is admin
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Must be authenticated');
    }
    const callerDoc = await db.collection('admins').doc(request.auth.uid).get();
    if (!callerDoc.exists) {
        throw new https_1.HttpsError('permission-denied', 'Only admins can create paramedic accounts');
    }
    const { email, password, firstName, lastName, phoneNumber, licenseNumber, ambulanceId, } = request.data;
    if (!email || !password || !firstName || !lastName) {
        throw new https_1.HttpsError('invalid-argument', 'Missing required fields');
    }
    try {
        // Create Firebase Auth user
        const userRecord = await admin.auth().createUser({
            email,
            password,
            displayName: `${firstName} ${lastName}`,
        });
        // Create Firestore paramedic document
        await db.collection('paramedics').doc(userRecord.uid).set({
            role: 'paramedic',
            email,
            firstName,
            lastName,
            phoneNumber: phoneNumber ?? '',
            licenseNumber: licenseNumber ?? '',
            ambulanceId: ambulanceId ?? '',
            isAvailable: true,
            isActive: true,
            status: 'available',
            fcmToken: null,
            latitude: null,
            longitude: null,
            assignedReportId: null,
            assignedReportType: null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`[admin] Paramedic account created: ${userRecord.uid} (${email})`);
        return {
            success: true,
            uid: userRecord.uid,
            email,
            message: `تم إنشاء حساب المسعف ${firstName} ${lastName} بنجاح`,
        };
    }
    catch (err) {
        console.error('[admin] Create paramedic failed:', err);
        throw new https_1.HttpsError('internal', err.message ?? 'Failed to create paramedic account');
    }
});
/* ═══════════════════════════════════════════════════════════════════
   12. RELEASE AMBULANCE (Callable)
   Manual release of an ambulance from dashboard
═══════════════════════════════════════════════════════════════════ */
exports.releaseAmbulance = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Must be authenticated');
    }
    const { paramedicId } = request.data;
    if (!paramedicId) {
        throw new https_1.HttpsError('invalid-argument', 'paramedicId is required');
    }
    try {
        await db.collection('paramedics').doc(paramedicId).update({
            isAvailable: true,
            isActive: true,
            status: 'available',
            assignedReportId: null,
            assignedReportType: null,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`[admin] Paramedic ${paramedicId} manually released`);
        return { success: true, message: 'تم تحرير عربية الإسعاف' };
    }
    catch (err) {
        throw new https_1.HttpsError('internal', err.message);
    }
});
//# sourceMappingURL=index.js.map