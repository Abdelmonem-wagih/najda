import 'package:cloud_functions/cloud_functions.dart';

/// ═══════════════════════════════════════════════════════════════════
/// NajdaAIService — wraps all Groq-powered Firebase Callable Functions
/// ═══════════════════════════════════════════════════════════════════
class NajdaAIService {
  NajdaAIService._();
  static final instance = NajdaAIService._();

  final _functions = FirebaseFunctions.instance;

  // ── 1. General AI Assistant (citizen & paramedic) ──────────────────

  Future<String> askAssistant({
    required String message,
    required String role, // 'citizen' | 'paramedic'
    List<Map<String, String>> history = const [],
    String? context,
  }) async {
    try {
      final result = await _functions.httpsCallable('najdaAIAssistant').call({
        'message': message,
        'role': role,
        'history': history,
        if (context != null) 'context': context,
      });
      return (result.data['reply'] as String?) ??
          'عذراً، لم يتمكن المساعد من الرد. حاول مرة أخرى.';
    } on FirebaseFunctionsException catch (e) {
      throw _mapError(e);
    }
  }

  // ── 2. Symptom Triage (citizen) ────────────────────────────────────

  Future<TriageResult> triageSymptoms({
    required String symptoms,
    int? patientAge,
    List<String> chronicDiseases = const [],
  }) async {
    try {
      final result = await _functions.httpsCallable('triageSymptoms').call({
        'symptoms': symptoms,
        if (patientAge != null) 'patientAge': patientAge,
        'chronicDiseases': chronicDiseases,
      });
      return TriageResult.fromMap(
          Map<String, dynamic>.from(result.data['triage']));
    } on FirebaseFunctionsException catch (e) {
      throw _mapError(e);
    }
  }

  // ── 3. AI Hospital Selection (paramedic after medical report) ──────

  Future<HospitalSuggestion> selectHospital({
    required String reportId,
    required String reportType,
    required double patientLat,
    required double patientLng,
    required Map<String, String> medicalAnswers,
    String? additionalNotes,
    List<String> chronicDiseases = const [],
    List<String> allergies = const [],
    List<String> currentMedications = const [],
    String? incidentType,
  }) async {
    try {
      final result = await _functions.httpsCallable('selectHospitalWithAI').call({
        'reportId': reportId,
        'reportType': reportType,
        'patientLat': patientLat,
        'patientLng': patientLng,
        'medicalAnswers': medicalAnswers,
        if (additionalNotes != null) 'additionalNotes': additionalNotes,
        'chronicDiseases': chronicDiseases,
        'allergies': allergies,
        'currentMedications': currentMedications,
        if (incidentType != null) 'incidentType': incidentType,
      });
      return HospitalSuggestion.fromMap(
          Map<String, dynamic>.from(result.data['hospital']));
    } on FirebaseFunctionsException catch (e) {
      throw _mapError(e);
    }
  }

  // ── 4. Create Paramedic Account (admin/dashboard) ──────────────────

  Future<Map<String, dynamic>> createParamedicAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String licenseNumber,
    required String ambulanceId,
  }) async {
    try {
      final result = await _functions.httpsCallable('createParamedicAccount').call({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'licenseNumber': licenseNumber,
        'ambulanceId': ambulanceId,
      });
      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseFunctionsException catch (e) {
      throw _mapError(e);
    }
  }

  // ── 5. Release Ambulance (admin) ───────────────────────────────────

  Future<void> releaseAmbulance(String paramedicId) async {
    try {
      await _functions.httpsCallable('releaseAmbulance').call({
        'paramedicId': paramedicId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw _mapError(e);
    }
  }

  // ── Error mapping ──────────────────────────────────────────────────

  Exception _mapError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return Exception('يجب تسجيل الدخول أولاً');
      case 'permission-denied':
        return Exception('ليس لديك صلاحية لهذا الإجراء');
      case 'invalid-argument':
        return Exception('بيانات غير صحيحة: ${e.message}');
      case 'internal':
        return Exception('خطأ في الخادم. حاول مرة أخرى.');
      default:
        return Exception(e.message ?? 'خطأ غير متوقع');
    }
  }
}

/* ═══════════════════════════════════════════════════════════════════
   Data Models
═══════════════════════════════════════════════════════════════════ */

class TriageResult {
  final String urgencyLevel; // critical | high | medium | low
  final String urgencyLabel; // Arabic label
  final bool callAmbulance;
  final List<String> firstAidSteps;
  final List<String> doNotDo;
  final String waitingInstructions;
  final List<String> possibleConditions;

  const TriageResult({
    required this.urgencyLevel,
    required this.urgencyLabel,
    required this.callAmbulance,
    required this.firstAidSteps,
    required this.doNotDo,
    required this.waitingInstructions,
    required this.possibleConditions,
  });

  factory TriageResult.fromMap(Map<String, dynamic> m) {
    return TriageResult(
      urgencyLevel: m['urgencyLevel'] ?? 'medium',
      urgencyLabel: m['urgencyLabel'] ?? 'متوسطة',
      callAmbulance: m['callAmbulance'] ?? false,
      firstAidSteps: List<String>.from(m['firstAidSteps'] ?? []),
      doNotDo: List<String>.from(m['doNotDo'] ?? []),
      waitingInstructions: m['waitingInstructions'] ?? '',
      possibleConditions: List<String>.from(m['possibleConditions'] ?? []),
    );
  }

  bool get isCritical => urgencyLevel == 'critical';
  bool get isHigh => urgencyLevel == 'high';
}

class HospitalSuggestion {
  final String name;
  final String address;
  final String distance;
  final String reason;
  final List<String> specialties;
  final String estimatedArrival;
  final String? urgencyLevel;
  final String? notes;

  const HospitalSuggestion({
    required this.name,
    required this.address,
    required this.distance,
    required this.reason,
    required this.specialties,
    required this.estimatedArrival,
    this.urgencyLevel,
    this.notes,
  });

  factory HospitalSuggestion.fromMap(Map<String, dynamic> m) {
    return HospitalSuggestion(
      name: m['name'] ?? 'مستشفى قريب',
      address: m['address'] ?? '',
      distance: m['distance'] ?? 'غير محدد',
      reason: m['reason'] ?? '',
      specialties: List<String>.from(m['specialties'] ?? []),
      estimatedArrival: m['estimatedArrival'] ?? 'غير محدد',
      urgencyLevel: m['urgencyLevel'],
      notes: m['notes'],
    );
  }
}
