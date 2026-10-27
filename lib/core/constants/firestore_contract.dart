/// Canonical Firestore schema contract — single source of truth.
///
/// Mirrored (by hand, kept in sync) in:
///   - najda_functions/src/contract.ts   (Cloud Functions)
///   - src/lib/contract.js               (dashboard)
///   - firebase/CONTRACT.md              (human-readable docs)
///
/// `scripts/check-contract.mjs` parses the CONTRACT:*:START/END blocks in all
/// three source files and fails if the collection names or status enums ever
/// drift apart. Run `npm run check:contract` from the repo root after editing
/// any of them.
library;

// CONTRACT:COLLECTIONS:START
class FirestoreCollections {
  FirestoreCollections._();

  static const criticals = 'criticals';
  static const incidents = 'incidents';
  static const ambulances = 'ambulances';
  static const ambulancePrivate = 'ambulance_private';
  static const tracking = 'tracking';
  static const citizens = 'citizens';
  static const notifications = 'notifications';
  static const ambulanceHistory = 'ambulance_history';
  static const hospitals = 'hospitals';
  static const dashboardUsers = 'dashboard_users';
  static const counters = '_counters';
}
// CONTRACT:COLLECTIONS:END

// CONTRACT:INCIDENT_STATUS:START
class IncidentStatus {
  IncidentStatus._();

  static const pending = 'pending';
  static const assigned = 'assigned';
  static const onMission = 'on_mission';
  static const arrived = 'arrived';
  static const toHospital = 'to_hospital';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const duplicate = 'duplicate';
}
// CONTRACT:INCIDENT_STATUS:END

// CONTRACT:AMBULANCE_STATUS:START
class AmbulanceStatus {
  AmbulanceStatus._();

  static const available = 'available';
  static const assigned = 'assigned';
  static const onMission = 'on_mission';
  static const arrived = 'arrived';
  static const toHospital = 'to_hospital';
}
// CONTRACT:AMBULANCE_STATUS:END

enum IncidentKind { critical, incident }

/// Which collection a [IncidentKind.critical] vs [IncidentKind.incident] lives
/// in. ONE helper, used everywhere instead of ad-hoc ternaries.
String incidentCollectionFor(IncidentKind kind) {
  return kind == IncidentKind.critical
      ? FirestoreCollections.criticals
      : FirestoreCollections.incidents;
}

/// Inverse of [incidentCollectionFor] — used when only the collection name
/// (or the legacy `reportType` string) is known.
IncidentKind incidentKindFor(String collectionOrReportType) {
  return (collectionOrReportType == FirestoreCollections.criticals ||
          collectionOrReportType == 'critical')
      ? IncidentKind.critical
      : IncidentKind.incident;
}

// CONTRACT:INCIDENT_FIELDS:START
class IncidentFields {
  IncidentFields._();

  static const shortId = 'shortId';
  static const incidentType = 'incidentType';
  static const accidentType = 'accidentType';
  static const source = 'source';
  static const patientUid = 'patientUid';
  static const patientName = 'patientName';
  static const nationalId = 'nationalId';
  static const phoneNumber = 'phoneNumber';
  static const emergencyContact = 'emergencyContact';
  static const emergencyContactName = 'emergencyContactName';
  static const bloodType = 'bloodType';
  static const chronicDiseases = 'chronicDiseases';
  static const allergies = 'allergies';
  static const currentMedications = 'currentMedications';
  static const additionalInfo = 'additionalInfo';
  static const consciousnessLevel = 'consciousnessLevel';
  static const injuryLocation = 'injuryLocation';
  static const painLevel = 'painLevel';
  static const imageUrl = 'imageUrl';
  static const latitude = 'latitude';
  static const longitude = 'longitude';
  static const address = 'address';
  static const accuracy = 'accuracy';
  static const status = 'status';
  static const assignedAmbulanceId = 'assignedAmbulanceId';
  static const assignedAmbulanceName = 'assignedAmbulanceName';
  static const assignedDriverName = 'assignedDriverName';
  static const assignedVehicleId = 'assignedVehicleId';
  static const assignedAt = 'assignedAt';
  static const assignedBy = 'assignedBy';
  static const retryCount = 'retryCount';
  static const dedupeKey = 'dedupeKey';
  static const suggestedHospitalName = 'suggestedHospitalName';
  static const hospitalId = 'hospitalId';
  static const medicalReportSubmitted = 'medicalReportSubmitted';
  static const medicalAssessment = 'medicalAssessment';
  static const medicalNotes = 'medicalNotes';
  static const enRouteAt = 'enRouteAt';
  static const arrivedAt = 'arrivedAt';
  static const toHospitalAt = 'toHospitalAt';
  static const completedAt = 'completedAt';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}
// CONTRACT:INCIDENT_FIELDS:END

// CONTRACT:AMBULANCE_FIELDS:START
class AmbulanceFields {
  AmbulanceFields._();

  static const uid = 'uid';
  static const ambulanceId = 'ambulanceId';
  static const plateNumber = 'plateNumber';
  static const driverName = 'driverName';
  static const name = 'name';
  static const area = 'area';
  static const baseLocation = 'baseLocation';
  static const isOnline = 'isOnline';
  static const status = 'status';
  static const serviceType = 'serviceType'; // 'ambulance' today; reserved for future fire/police vehicles
  static const currentIncidentId = 'currentIncidentId';
  static const currentIncidentType = 'currentIncidentType';
  static const lastActiveAt = 'lastActiveAt';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}
// CONTRACT:AMBULANCE_FIELDS:END

/// Service types a dispatchable vehicle can have. Only 'ambulance' is built today.
class ServiceTypes {
  ServiceTypes._();

  static const ambulance = 'ambulance';
}

// CONTRACT:AMBULANCE_PRIVATE_FIELDS:START
class AmbulancePrivateFields {
  AmbulancePrivateFields._();

  static const fcmToken = 'fcmToken';
  static const email = 'email';
  static const phone = 'phone';
}
// CONTRACT:AMBULANCE_PRIVATE_FIELDS:END

// CONTRACT:TRACKING_FIELDS:START
class TrackingFields {
  TrackingFields._();

  static const latitude = 'latitude';
  static const longitude = 'longitude';
  static const bearing = 'bearing';
  static const speed = 'speed';
  static const accuracy = 'accuracy';
  static const updatedAt = 'updatedAt';
}
// CONTRACT:TRACKING_FIELDS:END

// CONTRACT:CITIZEN_FIELDS:START
class CitizenFields {
  CitizenFields._();

  static const role = 'role';
  static const phoneNumber = 'phoneNumber';
  static const firstName = 'firstName';
  static const lastName = 'lastName';
  static const nationalId = 'nationalId';
  static const medicalProfile = 'medicalProfile';
  static const emergencyContact = 'emergencyContact';
  static const fcmToken = 'fcmToken';
  static const createdAt = 'createdAt';
}
// CONTRACT:CITIZEN_FIELDS:END

// CONTRACT:NOTIFICATION_FIELDS:START
class NotificationRecipientRole {
  NotificationRecipientRole._();

  static const ambulance = 'ambulance';
  static const citizen = 'citizen';
  static const admin = 'admin';
}

class NotificationFields {
  NotificationFields._();

  static const recipientId = 'recipientId';
  static const recipientRole = 'recipientRole';
  static const type = 'type';
  static const title = 'title';
  static const body = 'body';
  static const incidentId = 'incidentId';
  static const incidentCollection = 'incidentCollection';
  static const isRead = 'isRead';
  static const readAt = 'readAt';
  static const createdAt = 'createdAt';
}
// CONTRACT:NOTIFICATION_FIELDS:END

// CONTRACT:AMBULANCE_HISTORY_FIELDS:START
class AmbulanceHistoryFields {
  AmbulanceHistoryFields._();

  static const ambulanceId = 'ambulanceId';
  static const incidentId = 'incidentId';
  static const incidentCollection = 'incidentCollection';
  static const patientName = 'patientName';
  static const address = 'address';
  static const status = 'status';
  static const completedAt = 'completedAt';
}
// CONTRACT:AMBULANCE_HISTORY_FIELDS:END
