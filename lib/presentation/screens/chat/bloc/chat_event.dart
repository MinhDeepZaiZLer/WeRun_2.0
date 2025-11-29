part of 'chat_bloc.dart';

abstract class ChatEvent {}

// Sự kiện khởi tạo: Bắt đầu lắng nghe tin nhắn của người bạn này
class LoadMessages extends ChatEvent {
  final String friendId;
  LoadMessages(this.friendId);
}

// Sự kiện gửi tin nhắn
class SendMessage extends ChatEvent {
  final String content;
  SendMessage(this.content);
}

// Sự kiện nội bộ: Khi có tin nhắn mới từ Firestore stream báo về
class _UpdateMessages extends ChatEvent {
  final List<ChatMessage> messages;
  _UpdateMessages(this.messages);
}