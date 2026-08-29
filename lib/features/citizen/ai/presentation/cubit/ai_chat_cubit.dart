import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../../domain/entities/chat_message.dart';
import 'ai_chat_state.dart';

class AIChatCubit extends Cubit<AIChatState> {
  final AIChatRepository _repository;

  AIChatCubit({required AIChatRepository repository})
      : _repository = repository,
        super(const AIChatState());

  void init(String role, String welcomeMessage) {
    if (state.messages.isEmpty) {
      emit(state.copyWith(
        messages: [ChatMessage(text: welcomeMessage, isUser: false)],
      ));
    }
  }

  Future<void> sendMessage(String text, String role) async {
    if (text.trim().isEmpty || state.isLoading) return;

    final cleanText = text.replaceAll(RegExp(r'^[^\w\u0600-\u06FF]+'), '').trim();
    
    final newUserMessage = ChatMessage(text: text, isUser: true);
    emit(state.copyWith(
      messages: [...state.messages, newUserMessage],
      isLoading: true,
    ));

    try {
      final isTriage = role == 'citizen' &&
          (cleanText.contains('أعراض') ||
              cleanText.contains('قيّم') ||
              cleanText.contains('عندي') ||
              cleanText.contains('ألم') ||
              cleanText.contains('أشعر'));

      String reply;
      if (isTriage) {
        reply = await _repository.triageSymptoms(symptoms: cleanText);
      } else {
        reply = await _repository.askAssistant(
          message: cleanText,
          role: role,
          history: List.from(state.history),
        );
      }

      final newAssistantMessage = ChatMessage(text: reply, isUser: false);
      final newHistory = [
        ...state.history,
        {'role': 'user', 'content': cleanText},
        {'role': 'assistant', 'content': reply},
      ];

      emit(state.copyWith(
        messages: [...state.messages, newAssistantMessage],
        history: newHistory,
        isLoading: false,
      ));
    } catch (e) {
      String errorMsg = _mapError(e);
      final errorMessage = ChatMessage(text: errorMsg, isUser: false, isError: true);
      emit(state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      ));
    }
  }

  String _mapError(dynamic e) {
    final errStr = e.toString().toLowerCase();
    if (errStr.contains('unauthenticated') || errStr.contains('permission')) {
      return 'خطأ في الصلاحيات. تأكد من تسجيل الدخول.';
    } else if (errStr.contains('not-found') || errStr.contains('not found')) {
      return 'الخدمة غير متاحة حالياً. تأكد من نشر Firebase Functions.';
    } else if (errStr.contains('groq') || errStr.contains('api key') || errStr.contains('internal')) {
      return 'خطأ في خادم الذكاء الاصطناعي. تحقق من إعداد GROQ_API_KEY في Firebase.';
    } else if (errStr.contains('timeout') || errStr.contains('deadline')) {
      return 'انتهت مهلة الاتصال. حاول مرة أخرى.';
    } else if (errStr.contains('network') || errStr.contains('socket')) {
      return 'تحقق من اتصالك بالإنترنت.';
    } else {
      return 'خطأ: $e';
    }
  }
}
