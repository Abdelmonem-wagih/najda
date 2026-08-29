import '../../../../../core/services/groq_service.dart';
import '../../domain/repositories/ai_chat_repository.dart';

class AIChatRepositoryImpl implements AIChatRepository {
  @override
  Future<String> askAssistant({
    required String message,
    required String role,
    required List<Map<String, String>> history,
  }) async {
    return await NajdaAIService.instance.askAssistantDirect(
      message: message,
      role: role,
      history: history,
    );
  }

  @override
  Future<String> triageSymptoms({
    required String symptoms,
  }) async {
    final rawResult = await NajdaAIService.instance.triageSymptomsDirect(
      symptoms: symptoms,
    );
    final r = TriageResult.fromMap(rawResult);
    return _formatTriage(r);
  }

  String _formatTriage(TriageResult r) {
    final sb = StringBuffer();
    final emoji = r.isCritical ? '🚨' : r.isHigh ? '⚠️' : '✅';
    sb.writeln('$emoji *${r.urgencyLabel}*');
    if (r.callAmbulance) sb.writeln('\n📞 **اتصل بالإسعاف 123 فوراً!**');
    if (r.firstAidSteps.isNotEmpty) {
      sb.writeln('\n**إرشادات الإسعاف:**');
      for (var i = 0; i < r.firstAidSteps.length; i++) {
        sb.writeln('${i + 1}. ${r.firstAidSteps[i]}');
      }
    }
    return sb.toString().trim();
  }
}
