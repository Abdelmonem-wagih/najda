import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

class AIChatState extends Equatable {
  final List<ChatMessage> messages;
  final List<Map<String, String>> history;
  final bool isLoading;

  const AIChatState({
    this.messages = const [],
    this.history = const [],
    this.isLoading = false,
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    List<Map<String, String>>? history,
    bool? isLoading,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [messages, history, isLoading];
}
