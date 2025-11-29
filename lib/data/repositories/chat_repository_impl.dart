import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../services/firebase_auth_service.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final FirebaseAuthService _authService;
  final Dio _dio;
  
  WebSocketChannel? _channel;
  // StreamController broadcast để nhiều nơi có thể lắng nghe (UI, Notif...)
  final _messageController = StreamController<dynamic>.broadcast();

  // === CẤU HÌNH URL (Dùng Ngrok của bạn) ===
  // Lưu ý: WebSocket dùng wss:// (nếu https) hoặc ws:// (nếu http)
  // Dùng đúng domain Ngrok bạn đang chạy cho AI
  static const String _domain = "zofia-autogenous-nonintroversively.ngrok-free.dev"; 
  static const String _wsUrl = "wss://$_domain/ws/chat"; 
  static const String _apiUrl = "https://$_domain/api/v1";

  ChatRepositoryImpl(this._authService) : _dio = Dio(BaseOptions(baseUrl: _apiUrl));

  @override
  Stream<dynamic> get messageStream => _messageController.stream;

  @override
  void connect(String currentUserId) {
    // Nếu đang kết nối rồi thì thôi
    if (_channel != null && _channel!.closeCode == null) return;

    print("🔌 [Socket] Connecting to $_wsUrl/$currentUserId");
    
    try {
      // Kết nối WebSocket
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl/$currentUserId'),
      );

      // Lắng nghe sự kiện từ Server
      _channel!.stream.listen(
        (data) {
          try {
            final jsonData = jsonDecode(data);
            
            // Kiểm tra nếu là thông báo lỗi (ví dụ: Spam)
            if (jsonData['type'] == 'error') {
               print("⚠️ Lỗi từ Server: ${jsonData['content']}");
               _messageController.add(jsonData['content']); // Gửi lỗi dạng String
            } else {
               // Tin nhắn chat bình thường
               final message = ChatMessage.fromJson(jsonData);
               _messageController.add(message); // Gửi object ChatMessage
               print("📩 [Socket] Nhận tin: ${message.content}");
            }
          } catch (e) {
            print("Lỗi parse message: $e");
          }
        },
        onError: (error) {
            print("Socket Error: $error");
            // Có thể implement logic tự động reconnect ở đây
        },
        onDone: () => print("Socket Closed"),
      );
    } catch (e) {
      print("Lỗi kết nối Socket: $e");
    }
  }

  @override
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }
  }

  @override
  void sendMessage(String receiverId, String content) {
    // Đảm bảo đã kết nối
    if (_channel == null || _channel!.closeCode != null) {
       final myId = _authService.currentUserId;
       if (myId != null) connect(myId);
       // Đợi 1 chút để connect (thực tế nên dùng Completer, nhưng tạm thời delay nhẹ)
       Future.delayed(const Duration(milliseconds: 500)); 
    }

    final payload = jsonEncode({
      "receiverId": receiverId,
      "content": content,
    });
    
    print("📤 [Socket] Sending: $payload");
    _channel?.sink.add(payload);
  }
  
  @override
  Future<List<ChatMessage>> getHistory(String friendId) async {
     final myId = _authService.currentUserId;
     if (myId == null) return [];
     
     try {
       // Gọi API HTTP để lấy lịch sử cũ
       final response = await _dio.get('/messages/$myId/$friendId');
       if (response.statusCode == 200) {
          final List<dynamic> list = response.data;
          return list.map((json) => ChatMessage.fromJson(json)).toList();
       }
     } catch (e) {
       print("Lỗi lấy lịch sử: $e");
     }
     return [];
  }
}