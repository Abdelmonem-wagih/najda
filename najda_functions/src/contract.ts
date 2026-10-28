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
  hospitalPrivate: 'hospital_private',
  staff: 'staff',
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
// CONTRACT:INCIDENT_FIELDS:START
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
// CONTRACT:INCIDENT_FIELDS:END

// CONTRACT:AMBULANCE_FIELDS:START
export const AMBULANCE_FIELDS = {
  uid: 'uid',
  ambulanceId: 'ambulanceId',
  plateNumber: 'plateNumber',
  driverName: 'driverName',
  paramedicName: 'paramedicName',
  name: 'name',
  area: 'area',
  baseLocation: 'baseLocation',
  isOnline: 'isOnline',
  status: 'status',
  serviceType: 'serviceType', // 'ambulance' today; reserved for future fire/police vehicles
  currentIncidentId: 'currentIncidentId',
  currentIncidentType: 'currentIncidentType',
  lastActiveAt: 'lastActiveAt',
  createdAt: 'createdAt',
  updatedAt: 'updatedAt',
} as const;
// CONTRACT:AMBULANCE_FIELDS:END

/** Service types a dispatchable vehicle can have. Only 'ambulance' is built today. */
export const SERVICE_TYPES = {
  ambulance: 'ambulance',
} as const;

// CONTRACT:AMBULANCE_PRIVATE_FIELDS:START
export const AMBULANCE_PRIVATE_FIELDS = {
  fcmToken: 'fcmToken',
  email: 'email',
  phone: 'phone',
} as const;
// CONTRACT:AMBULANCE_PRIVATE_FIELDS:END

// CONTRACT:TRACKING_FIELDS:START
export const TRACKING_FIELDS = {
  latitude: 'latitude',
  longitude: 'longitude',
  bearing: 'bearing',
  speed: 'speed',
  accuracy: 'accuracy',
  updatedAt: 'updatedAt',
} as const;
// CONTRACT:TRACKING_FIELDS:END

// CONTRACT:CITIZEN_FIELDS:START
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
// CONTRACT:CITIZEN_FIELDS:END

// CONTRACT:NOTIFICATION_FIELDS:START
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
// CONTRACT:NOTIFICATION_FIELDS:END

// CONTRACT:AMBULANCE_HISTORY_FIELDS:START
export const AMBULANCE_HISTORY_FIELDS = {
  ambulanceId: 'ambulanceId',
  incidentId: 'incidentId',
  incidentCollection: 'incidentCollection',
  patientName: 'patientName',
  address: 'address',
  status: 'status',
  completedAt: 'completedAt',
} as const;
// CONTRACT:AMBULANCE_HISTORY_FIELDS:END

// CONTRACT:HOSPITAL_FIELDS:START
export const HOSPITAL_FIELDS = {
  name: 'name',
  address: 'address',
  latitude: 'latitude',
  longitude: 'longitude',
  phoneNumber: 'phoneNumber',
  specialties: 'specialties',
  hasER: 'hasER',
  isGovernment: 'isGovernment',
  bedsAvailable: 'bedsAvailable',
  is24Hours: 'is24Hours',
  hours: 'hours',
  createdAt: 'createdAt',
  updatedAt: 'updatedAt',
} as const;
// CONTRACT:HOSPITAL_FIELDS:END

// CONTRACT:HOSPITAL_PRIVATE_FIELDS:START
export const HOSPITAL_PRIVATE_FIELDS = {
  email: 'email',
  uid: 'uid',
} as const;
// CONTRACT:HOSPITAL_PRIVATE_FIELDS:END

// CONTRACT:STAFF_ROLES:START
export const STAFF_ROLES = ['paramedic', 'driver'] as const;
// CONTRACT:STAFF_ROLES:END
export type StaffRole = typeof STAFF_ROLES[number];

// CONTRACT:STAFF_FIELDS:START
export const STAFF_FIELDS = {
  name: 'name',
  phone: 'phone',
  role: 'role', // one of STAFF_ROLES
  assignedAmbulanceId: 'assignedAmbulanceId',
  createdAt: 'createdAt',
  updatedAt: 'updatedAt',
} as const;
// CONTRACT:STAFF_FIELDS:END

// CONTRACT:DASHBOARD_ROLES:START
export const DASHBOARD_ROLES = ['admin', 'operator', 'hospital'] as const;
// CONTRACT:DASHBOARD_ROLES:END
export type DashboardRole = typeof DASHBOARD_ROLES[number];

// CONTRACT:DASHBOARD_USER_FIELDS:START
export const DASHBOARD_USER_FIELDS = {
  role: 'role', // one of DASHBOARD_ROLES
  name: 'name',
  email: 'email',
  active: 'active',
  createdAt: 'createdAt',
} as const;
// CONTRACT:DASHBOARD_USER_FIELDS:END
