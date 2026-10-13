import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// ═══════════════════════════════════════════════════════════════════
/// NajdaAIService — wraps all Groq-powered Firebase Callable Functions
/// ═══════════════════════════════════════════════════════════════════
class NajdaAIService {
  NajdaAIService._();
  static final instance = NajdaAIService._();

  // Change 'us-central1' to wherever your functions are deployed
  // Common: 'us-central1', 'europe-west1', 'me-central1' (Middle East)
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  static const List<String> _groqModels = [
    'openai/gpt-oss-120b',
    'mixtral-8x7b-32768',
    'whisper-large-v3-turbo',
    'openai/gpt-oss-20b',
    'canopylabs/orpheus-v1-english',
    'meta-llama/llama-prompt-guard-2-22m',
    'canopylabs/orpheus-arabic-saudi',
    'allam-2-7b',
    'openai/gpt-oss-safeguard-20b',
    'whisper-large-v3',
    'groq/compound-mini',
    'meta-llama/llama-prompt-guard-2-86m',
    'groq/compound',
    'qwen/qwen3.6-27b',
    'gemma2-9b-it',
    'llama-3.3-70b-versatile',
    'llama-3.1-8b-instant',
  ];
  
  // ── 1. General AI Assistant (citizen & paramedic) ──────────────────

  Future<String> askAssistant({
    required String message,
    required String role, // 'citizen' | 'ambulances'
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

  /// Direct Groq API call — faster than Firebase Functions, no cold start
  Future<String> askAssistantDirect({
    required String message,
    required String role,
    List<Map<String, String>> history = const [],
  }) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY not found in .env file');
    }

    final systemPrompt = role == 'ambulances'
        ? '''أنت مساعد طبي متخصص لمسعفي الإسعاف في نظام نجدة للطوارئ بمصر.
تقدم: دعم القرار الإكلينيكي، الجرعات، بروتوكولات الإسعاف الميداني.
أجب بالعربية بإيجاز ووضوح مناسبَين للعمل الميداني.
في الحالات الحرجة جداً وجّه المسعف للتواصل مع طبيب.'''
        : '''أنت مساعد طوارئ طبي للمواطنين في نظام نجدة بمصر.
تقدم: إرشادات الإسعافات الأولية، تقييم الأعراض، ماذا تفعل قبل وصول الإسعاف.
لا تشخّص الأمراض. دائماً أوصِ بالاتصال بـ 123 في الحالات الطارئة.
أجب بالعربية بلغة بسيطة يفهمها المواطن العادي.''';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history,
      {'role': 'user', 'content': message},
    ];

    Exception? lastError;
    for (final model in _groqModels) {
      try {
        final response = await http.post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,

            'temperature': role == 'paramedic' ? 0.1 : 0.3,

            // GPT-OSS
            'reasoning_effort': 'low',
            'include_reasoning': false,

            // Give the model enough room for the final answer
            'max_completion_tokens': 1200,
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final messageData = data['choices']?[0]?['message'];
          final content = messageData?['content'];

          if (content is String && content.trim().isNotEmpty) {
            return content.trim();
          }

          throw Exception(
            'Groq returned empty content for model $model.',
          );
        }

        // إن كان 400 أو 404 (model مش متاح) جرّب التالي
        if (response.statusCode == 400 || response.statusCode == 404) {
          lastError = Exception('Model $model: ${response.statusCode}');
          continue;
        }

        // أي error تاني — ارمي exception
        throw Exception('Groq API error ${response.statusCode}: ${response.body}');

      } on TimeoutException {
        lastError = Exception('Timeout on model $model');
        continue;
      }
    }

    throw lastError ?? Exception('All Groq models failed');
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

  /// Direct symptom triage — calls Groq API directly
  Future<Map<String, dynamic>> triageSymptomsDirect({
    required String symptoms,
    int? patientAge,
    List<String> chronicDiseases = const [],
  }) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty) throw Exception('GROQ_API_KEY not found in .env');

    final prompt = '''أنت نظام طوارئ طبي ذكي لتقييم الأعراض في مصر.

الأعراض: $symptoms
العمر: ${patientAge ?? 'غير محدد'}
أمراض مزمنة: ${chronicDiseases.join('، ').isEmpty ? 'لا يوجد' : chronicDiseases.join('، ')}

أجب بـ JSON فقط بدون أي نص خارجه:
{
  "urgencyLevel": "critical | high | medium | low",
  "urgencyLabel": "حرجة | عاجلة | متوسطة | خفيفة",
  "callAmbulance": true,
  "firstAidSteps": ["خطوة 1", "خطوة 2"],
  "doNotDo": ["لا تفعل 1"],
  "waitingInstructions": "ما يفعله أثناء انتظار الإسعاف",
  "possibleConditions": ["احتمال 1"]
}''';

    Exception? lastError;
    for (final model in _groqModels) {
      try {
        final response = await http
            .post(
              Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': model,
                'messages': [
                  {'role': 'user', 'content': prompt}
                ],
                'temperature': 0.1,
                'reasoning_effort': 'low',
                'include_reasoning': false,
                'max_completion_tokens': 1200,
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices']?[0]?['message']?['content'];

          if (content is String && content.trim().isNotEmpty) {
            final clean = content.replaceAll('```json', '').replaceAll('```', '').trim();
            return jsonDecode(clean) as Map<String, dynamic>;
          }
        }

        if (response.statusCode == 400 || response.statusCode == 404) {
          lastError = Exception('Model $model unavailable');
          continue;
        }

        throw Exception('Groq error ${response.statusCode}: ${response.body}');
      } on TimeoutException {
        lastError = Exception('Timeout');
        continue;
      } catch (e) {
        lastError = Exception('Parse error or other: $e');
        continue;
      }
    }
    throw lastError ?? Exception('All models failed');
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

  // ── 4. Create Ambulance Account (admin/dashboard) ──────────────────

  Future<Map<String, dynamic>> createAmbulanceAccount({
    required String ambulancesId,
    required String email,
    required String password,
    required String driverName,
    required String phone,
    required String area,
    required Map<String, double> baseLocation,
  }) async {
    try {
      final result = await _functions.httpsCallable('createAmbulancesAccount').call({
        'ambulancesId': ambulancesId,
        'email': email,
        'password': password,
        'driverName': driverName,
        'phone': phone,
        'area': area,
        'baseLocation': baseLocation,
      });
      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseFunctionsException catch (e) {
      throw _mapError(e);
    }
  }

  // ── 5. Release Ambulance (admin) ───────────────────────────────────

  Future<void> releaseAmbulance(String ambulanceId) async {
    try {
      await _functions.httpsCallable('releaseAmbulance').call({
        'ambulanceId': ambulanceId,
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
