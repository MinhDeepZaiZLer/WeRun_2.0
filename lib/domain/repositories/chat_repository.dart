import '../entities/chat_message.dart';

abstract class ChatRepository {
  // Kết nối Socket
  void connect(String currentUserId);
  
  // Ngắt kết nối
  void disconnect();

  // Gửi tin nhắn
  void sendMessage(String receiverId, String content);

  // Luồng nhận tin nhắn realtime
  Stream<dynamic> get messageStream; // Stream trả về Message hoặc Error (String)
  
  // Lấy lịch sử tin nhắn cũ (qua API HTTP)
  Future<List<ChatMessage>> getHistory(String friendId);
}