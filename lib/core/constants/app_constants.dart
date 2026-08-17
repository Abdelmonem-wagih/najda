class AppConstants {
  AppConstants._();

  // ─── Firebase Collections ────────────────────────────────────────────────
  static const String paramedicCollection        = 'paramedics';
  static const String citizensCollection         = 'citizens';
  static const String reportsCollection          = 'reports';
  static const String emergencyReportsCollection = 'emergency_reports';
  static const String medicalReportsCollection   = 'medical_reports';
  static const String ambulancesCollection       = 'ambulances';
  static const String notificationsCollection    = 'notifications';
  static const String paramedicHistoryCollection = 'paramedic_history';
  static const String missionCancellationsCollection = 'mission_cancellations';

  // ─── User Roles (stored in Firestore doc & SharedPrefs) ─────────────────
  static const String roleCitizen   = 'citizen';
  static const String roleParamedic = 'paramedic';

  // ─── Report Status ───────────────────────────────────────────────────────
  static const String statusPending           = 'pending';
  static const String statusPendingAssignment = 'pending_assignment';
  static const String statusAssigned          = 'assigned';
  static const String statusInProgress        = 'in_progress';
  static const String statusArrived           = 'arrived';
  static const String statusCompleted         = 'completed';
  static const String statusDuplicate         = 'duplicate';
  static const String statusCancelled         = 'cancelled';

  // ─── Paramedic Status Workflow ───────────────────────────────────────────
  static const String paramedicAvailable         = 'available';
  static const String paramedicOnMission         = 'OnMission';
  static const String paramedicArrived           = 'arrived';
  static const String paramedicOnWayToHospital   = 'onTheWayToHospital';

  // ─── Shared Preferences Keys ─────────────────────────────────────────────
  static const String keyIsLoggedIn  = 'is_logged_in';
  static const String keyUserId      = 'user_id';
  static const String keyUserRole    = 'user_role';
  static const String keyUserEmail   = 'user_email';
  static const String keyLocale      = 'locale';

  // ─── Location ────────────────────────────────────────────────────────────
  static const int locationUpdateIntervalSeconds = 30;
  static const int duplicateTimeWindowMinutes    = 5;
  static const int duplicateDistanceMeters       = 100;

  // ─── Supported Locales ───────────────────────────────────────────────────
  static const String localeAr = 'ar';
  static const String localeEn = 'en';
}
