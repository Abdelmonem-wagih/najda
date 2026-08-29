import '../entities/chat_message.dart';

abstract class AIChatRepository {
  Future<String> askAssistant({
    required String message,
    required String role,
    required List<Map<String, String>> history,
  });

  Future<String> triageSymptoms({
    required String symptoms,
  });
}
