class AppConstants {
  AppConstants._();

  // ─── Feature flags ───────────────────────────────────────────────────────
  // AI (chatbot, AI FAB, Groq calls, AI hospital selection) is CANCELLED for
  // v1 per product decision — code stays in the repo, fully gated behind
  // this single flag. Every AI entry point must check this before doing
  // anything network-visible or UI-visible. Flip back to true to restore.
  static const bool aiEnabled = false;

  // ─── Firebase Collections ────────────────────────────────────────────────
  static const String citizensCollection         = 'citizens';
  static const String ambulancesCollection       = 'ambulances';
  static const String incidentsCollection        = 'incidents';
  static const String trackingCollection         = 'tracking';
  static const String hospitalsCollection        = 'hospitals';
  static const String assignmentsCollection       = 'assignments';
  static const String notificationsCollection    = 'notifications';
  static const String joinRequestsCollection     = 'join_requests';
  static const String medicalReportsCollection   = 'medical_reports';

  // ─── User Roles ──────────────────────────────────────────────────────────
  static const String roleCitizen    = 'citizen';
  static const String roleAmbulances = 'ambulances';
  static const String roleAdmin      = 'admin';

  // ─── Incident Status ─────────────────────────────────────────────────────
  static const String statusReported    = 'reported';
  static const String statusAiAssigning = 'ai_assigning';
  static const String statusAssigned    = 'assigned';
  static const String statusEnRoute     = 'en_route';
  static const String statusArrived     = 'arrived';
  static const String statusResolved    = 'resolved';
  static const String statusUnassigned  = 'unassigned';
  static const String statusReassigned  = 'reassigned';

  // ─── Ambulance Status ────────────────────────────────────────────────────
  static const String ambulanceAvailable    = 'available';
  static const String ambulanceDispatched   = 'dispatched';
  static const String ambulanceEnRoute      = 'en_route_to_incident';
  static const String ambulanceOnScene       = 'on_scene';
  static const String ambulanceToHospital   = 'to_hospital';
  static const String ambulanceAtHospital   = 'at_hospital';
  static const String ambulanceOffline      = 'offline';
  static const String ambulanceMaintenance  = 'maintenance';


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
