import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_constants.dart';

/// ═══════════════════════════════════════════════════════════════════
/// NajdaAIService — direct Groq calls, gated behind AppConstants.aiEnabled
/// (AI is cancelled for v1; this code stays in the repo, fully disabled).
///
/// Previously this class also wrapped 5 Firebase Callable Functions
/// (askAssistant, triageSymptoms, selectHospital, createAmbulanceAccount,
/// releaseAmbulance). All five were dead code — never called from anywhere
/// in the app — and three of them (najdaAIAssistant, triageSymptoms,
/// selectHospitalWithAI) called Cloud Functions that were never actually
/// defined on the backend to begin with. Removed rather than ported:
/// createAmbulanceAccount/releaseAmbulance were also architecturally
/// misplaced here (fleet management is a dashboard-only admin action, not
/// something the citizen/paramedic app does).
/// ═══════════════════════════════════════════════════════════════════
class NajdaAIService {
  NajdaAIService._();
  static final instance = NajdaAIService._();

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

  /// Direct Groq API call. Guarded by [AppConstants.aiEnabled] — AI is
  /// cancelled for v1, so this throws immediately instead of making any
  /// network call when the flag is off (defense-in-depth on top of the UI
  /// entry points already being gated in app_routes.dart/main.dart).
  Future<String> askAssistantDirect({
    required String message,
    required String role,
    List<Map<String, String>> history = const [],
  }) async {
    if (!AppConstants.aiEnabled) {
      throw Exception('AI is disabled for v1');
    }
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

  /// Direct symptom triage via Groq. Guarded by [AppConstants.aiEnabled].
  Future<Map<String, dynamic>> triageSymptomsDirect({
    required String symptoms,
    int? patientAge,
    List<String> chronicDiseases = const [],
  }) async {
    if (!AppConstants.aiEnabled) {
      throw Exception('AI is disabled for v1');
    }
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
