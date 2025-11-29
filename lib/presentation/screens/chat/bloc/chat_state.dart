part of 'chat_bloc.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [], 
    this.isLoading = false, 
    this.error
  });
}