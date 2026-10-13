"use strict";
/**
 * Canonical Firestore schema contract — single source of truth.
 *
 * Mirrored (by hand, kept in sync) in:
 *   - lib/core/constants/firestore_contract.dart   (Flutter app)
 *   - src/lib/contract.js                           (dashboard)
 *   - firebase/CONTRACT.md                          (human-readable docs)
 *
 * `scripts/check-contract.mjs` parses the CONTRACT:*:START/END blocks in all
 * three source files and fails if the collection names or status enums ever
 * drift apart. Run `npm run check:contract` from the repo root after editing
 * any of them.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.DASHBOARD_USER_FIELDS = exports.AMBULANCE_HISTORY_FIELDS = exports.NOTIFICATION_FIELDS = exports.NOTIFICATION_RECIPIENT_ROLE = exports.CITIZEN_FIELDS = exports.TRACKING_FIELDS = exports.AMBULANCE_PRIVATE_FIELDS = exports.AMBULANCE_FIELDS = exports.INCIDENT_FIELDS = exports.STATUS_TRANSITIONS = exports.AMBULANCE_STATUS = exports.INCIDENT_STATUS = exports.COLLECTIONS = void 0;
exports.incidentCollectionFor = incidentCollectionFor;
exports.incidentKindFor = incidentKindFor;
exports.isLegalTransition = isLegalTransition;
// CONTRACT:COLLECTIONS:START
exports.COLLECTIONS = {
    criticals: 'criticals',
    incidents: 'incidents',
    ambulances: 'ambulances',
    ambulancePrivate: 'ambulance_private',
    tracking: 'tracking',
    citizens: 'citizens',
    notifications: 'notifications',
    ambulanceHistory: 'ambulance_history',
    hospitals: 'hospitals',
    joinRequests: 'join_requests',
    dashboardUsers: 'dashboard_users',
    counters: '_counters',
};
// CONTRACT:COLLECTIONS:END
// CONTRACT:INCIDENT_STATUS:START
exports.INCIDENT_STATUS = {
    pending: 'pending',
    assigned: 'assigned',
    onMission: 'on_mission',
    arrived: 'arrived',
    toHospital: 'to_hospital',
    completed: 'completed',
    cancelled: 'cancelled',
    duplicate: 'duplicate',
};
// CONTRACT:INCIDENT_STATUS:END
// CONTRACT:AMBULANCE_STATUS:START
exports.AMBULANCE_STATUS = {
    available: 'available',
    assigned: 'assigned',
    onMission: 'on_mission',
    arrived: 'arrived',
    toHospital: 'to_hospital',
};
/** Which collection a 'critical' vs 'incident' kind lives in. ONE helper, used everywhere. */
function incidentCollectionFor(kind) {
    return kind === 'critical' ? exports.COLLECTIONS.criticals : exports.COLLECTIONS.incidents;
}
/** Inverse of incidentCollectionFor — used when only the collection name is known. */
function incidentKindFor(collection) {
    return collection === exports.COLLECTIONS.criticals ? 'critical' : 'incident';
}
/**
 * Legal status transitions and who may perform them.
 * 'server' = Cloud Function only (never a client write).
 * 'ambulance' = the assigned ambulance user.
 * 'citizen' = the owning citizen.
 * 'admin' = a dashboard admin/operator (manualAssign / force override).
 */
exports.STATUS_TRANSITIONS = {
    [exports.INCIDENT_STATUS.pending]: [
        { to: exports.INCIDENT_STATUS.assigned, by: 'server' },
        { to: exports.INCIDENT_STATUS.cancelled, by: 'citizen' },
        { to: exports.INCIDENT_STATUS.duplicate, by: 'server' },
    ],
    [exports.INCIDENT_STATUS.assigned]: [
        { to: exports.INCIDENT_STATUS.onMission, by: 'ambulance' },
        { to: exports.INCIDENT_STATUS.cancelled, by: 'citizen' },
    ],
    [exports.INCIDENT_STATUS.onMission]: [{ to: exports.INCIDENT_STATUS.arrived, by: 'ambulance' }],
    [exports.INCIDENT_STATUS.arrived]: [{ to: exports.INCIDENT_STATUS.toHospital, by: 'ambulance' }],
    [exports.INCIDENT_STATUS.toHospital]: [{ to: exports.INCIDENT_STATUS.completed, by: 'ambulance' }],
    [exports.INCIDENT_STATUS.completed]: [],
    [exports.INCIDENT_STATUS.cancelled]: [],
    [exports.INCIDENT_STATUS.duplicate]: [],
};
function isLegalTransition(from, to, by) {
    if (by === 'admin')
        return true; // dashboard admin/operator with force:true may override
    return (exports.STATUS_TRANSITIONS[from] ?? []).some(t => t.to === to && t.by === by);
}
// ─── Field name constants (criticals + incidents share this shape) ────────
exports.INCIDENT_FIELDS = {
    shortId: 'shortId',
    incidentType: 'incidentType',
    accidentType: 'accidentType',
    source: 'source',
    patientUid: 'patientUid',
    patientName: 'patientName',
    nationalId: 'nationalId',
    phoneNumber: 'phoneNumber',
    emergencyContact: 'emergencyContact',
    emergencyContactName: 'emergencyContactName',
    bloodType: 'bloodType',
    chronicDiseases: 'chronicDiseases',
    allergies: 'allergies',
    currentMedications: 'currentMedications',
    additionalInfo: 'additionalInfo',
    consciousnessLevel: 'consciousnessLevel',
    injuryLocation: 'injuryLocation',
    painLevel: 'painLevel',
    imageUrl: 'imageUrl',
    latitude: 'latitude',
    longitude: 'longitude',
    address: 'address',
    accuracy: 'accuracy',
    status: 'status',
    assignedAmbulanceId: 'assignedAmbulanceId',
    assignedAmbulanceName: 'assignedAmbulanceName',
    assignedDriverName: 'assignedDriverName',
    assignedVehicleId: 'assignedVehicleId',
    assignedAt: 'assignedAt',
    assignedBy: 'assignedBy',
    retryCount: 'retryCount',
    dedupeKey: 'dedupeKey',
    suggestedHospitalName: 'suggestedHospitalName',
    hospitalId: 'hospitalId',
    medicalReportSubmitted: 'medicalReportSubmitted',
    enRouteAt: 'enRouteAt',
    arrivedAt: 'arrivedAt',
    toHospitalAt: 'toHospitalAt',
    completedAt: 'completedAt',
    createdAt: 'createdAt',
    updatedAt: 'updatedAt',
};
exports.AMBULANCE_FIELDS = {
    uid: 'uid',
    ambulanceId: 'ambulanceId',
    plateNumber: 'plateNumber',
    driverName: 'driverName',
    name: 'name',
    area: 'area',
    baseLocation: 'baseLocation',
    isOnline: 'isOnline',
    status: 'status',
    currentIncidentId: 'currentIncidentId',
    currentIncidentType: 'currentIncidentType',
    lastActiveAt: 'lastActiveAt',
    createdAt: 'createdAt',
    updatedAt: 'updatedAt',
};
exports.AMBULANCE_PRIVATE_FIELDS = {
    fcmToken: 'fcmToken',
    email: 'email',
    phone: 'phone',
};
exports.TRACKING_FIELDS = {
    latitude: 'latitude',
    longitude: 'longitude',
    bearing: 'bearing',
    speed: 'speed',
    accuracy: 'accuracy',
    updatedAt: 'updatedAt',
};
exports.CITIZEN_FIELDS = {
    role: 'role',
    phoneNumber: 'phoneNumber',
    firstName: 'firstName',
    lastName: 'lastName',
    nationalId: 'nationalId',
    medicalProfile: 'medicalProfile',
    emergencyContact: 'emergencyContact',
    fcmToken: 'fcmToken',
    createdAt: 'createdAt',
};
exports.NOTIFICATION_RECIPIENT_ROLE = {
    ambulance: 'ambulance',
    citizen: 'citizen',
    admin: 'admin',
};
exports.NOTIFICATION_FIELDS = {
    recipientId: 'recipientId',
    recipientRole: 'recipientRole',
    type: 'type',
    title: 'title',
    body: 'body',
    incidentId: 'incidentId',
    incidentCollection: 'incidentCollection',
    isRead: 'isRead',
    readAt: 'readAt',
    createdAt: 'createdAt',
};
exports.AMBULANCE_HISTORY_FIELDS = {
    ambulanceId: 'ambulanceId',
    incidentId: 'incidentId',
    incidentCollection: 'incidentCollection',
    patientName: 'patientName',
    address: 'address',
    status: 'status',
    completedAt: 'completedAt',
};
exports.DASHBOARD_USER_FIELDS = {
    role: 'role', // 'admin' | 'operator'
    name: 'name',
    email: 'email',
    active: 'active',
    createdAt: 'createdAt',
};
//# sourceMappingURL=contract.js.map