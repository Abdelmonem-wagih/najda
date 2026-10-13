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

// CONTRACT:COLLECTIONS:START
export const COLLECTIONS = {
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
} as const;
// CONTRACT:COLLECTIONS:END

// CONTRACT:INCIDENT_STATUS:START
export const INCIDENT_STATUS = {
  pending: 'pending',
  assigned: 'assigned',
  onMission: 'on_mission',
  arrived: 'arrived',
  toHospital: 'to_hospital',
  completed: 'completed',
  cancelled: 'cancelled',
  duplicate: 'duplicate',
} as const;
// CONTRACT:INCIDENT_STATUS:END

// CONTRACT:AMBULANCE_STATUS:START
export const AMBULANCE_STATUS = {
  available: 'available',
  assigned: 'assigned',
  onMission: 'on_mission',
  arrived: 'arrived',
  toHospital: 'to_hospital',
} as const;
// CONTRACT:AMBULANCE_STATUS:END

export type IncidentStatus = typeof INCIDENT_STATUS[keyof typeof INCIDENT_STATUS];
export type AmbulanceStatus = typeof AMBULANCE_STATUS[keyof typeof AMBULANCE_STATUS];
export type IncidentKind = 'critical' | 'incident';

export type IncidentCollection = typeof COLLECTIONS.criticals | typeof COLLECTIONS.incidents;

/** Which collection a 'critical' vs 'incident' kind lives in. ONE helper, used everywhere. */
export function incidentCollectionFor(kind: IncidentKind): IncidentCollection {
  return kind === 'critical' ? COLLECTIONS.criticals : COLLECTIONS.incidents;
}

/** Inverse of incidentCollectionFor — used when only the collection name is known. */
export function incidentKindFor(collection: string): IncidentKind {
  return collection === COLLECTIONS.criticals ? 'critical' : 'incident';
}

/**
 * Legal status transitions and who may perform them.
 * 'server' = Cloud Function only (never a client write).
 * 'ambulance' = the assigned ambulance user.
 * 'citizen' = the owning citizen.
 * 'admin' = a dashboard admin/operator (manualAssign / force override).
 */
export const STATUS_TRANSITIONS: Record<
  IncidentStatus,
  { to: IncidentStatus; by: 'server' | 'ambulance' | 'citizen' | 'admin' }[]
> = {
  [INCIDENT_STATUS.pending]: [
    { to: INCIDENT_STATUS.assigned, by: 'server' },
    { to: INCIDENT_STATUS.cancelled, by: 'citizen' },
    { to: INCIDENT_STATUS.duplicate, by: 'server' },
  ],
  [INCIDENT_STATUS.assigned]: [
    { to: INCIDENT_STATUS.onMission, by: 'ambulance' },
    { to: INCIDENT_STATUS.cancelled, by: 'citizen' },
  ],
  [INCIDENT_STATUS.onMission]: [{ to: INCIDENT_STATUS.arrived, by: 'ambulance' }],
  [INCIDENT_STATUS.arrived]: [{ to: INCIDENT_STATUS.toHospital, by: 'ambulance' }],
  [INCIDENT_STATUS.toHospital]: [{ to: INCIDENT_STATUS.completed, by: 'ambulance' }],
  [INCIDENT_STATUS.completed]: [],
  [INCIDENT_STATUS.cancelled]: [],
  [INCIDENT_STATUS.duplicate]: [],
};

export function isLegalTransition(
  from: IncidentStatus,
  to: IncidentStatus,
  by: 'server' | 'ambulance' | 'citizen' | 'admin'
): boolean {
  if (by === 'admin') return true; // dashboard admin/operator with force:true may override
  return (STATUS_TRANSITIONS[from] ?? []).some(t => t.to === to && t.by === by);
}

// ─── Field name constants (criticals + incidents share this shape) ────────
export const INCIDENT_FIELDS = {
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
  medicalAssessment: 'medicalAssessment',
  medicalNotes: 'medicalNotes',
  enRouteAt: 'enRouteAt',
  arrivedAt: 'arrivedAt',
  toHospitalAt: 'toHospitalAt',
  completedAt: 'completedAt',
  createdAt: 'createdAt',
  updatedAt: 'updatedAt',
} as const;

export const AMBULANCE_FIELDS = {
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
} as const;

export const AMBULANCE_PRIVATE_FIELDS = {
  fcmToken: 'fcmToken',
  email: 'email',
  phone: 'phone',
} as const;

export const TRACKING_FIELDS = {
  latitude: 'latitude',
  longitude: 'longitude',
  bearing: 'bearing',
  speed: 'speed',
  accuracy: 'accuracy',
  updatedAt: 'updatedAt',
} as const;

export const CITIZEN_FIELDS = {
  role: 'role',
  phoneNumber: 'phoneNumber',
  firstName: 'firstName',
  lastName: 'lastName',
  nationalId: 'nationalId',
  medicalProfile: 'medicalProfile',
  emergencyContact: 'emergencyContact',
  fcmToken: 'fcmToken',
  createdAt: 'createdAt',
} as const;

export const NOTIFICATION_RECIPIENT_ROLE = {
  ambulance: 'ambulance',
  citizen: 'citizen',
  admin: 'admin',
} as const;

export const NOTIFICATION_FIELDS = {
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
} as const;

export const AMBULANCE_HISTORY_FIELDS = {
  ambulanceId: 'ambulanceId',
  incidentId: 'incidentId',
  incidentCollection: 'incidentCollection',
  patientName: 'patientName',
  address: 'address',
  status: 'status',
  completedAt: 'completedAt',
} as const;

export const DASHBOARD_USER_FIELDS = {
  role: 'role', // 'admin' | 'operator'
  name: 'name',
  email: 'email',
  active: 'active',
  createdAt: 'createdAt',
} as const;
