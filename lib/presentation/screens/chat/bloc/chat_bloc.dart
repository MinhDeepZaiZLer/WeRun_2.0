import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/chat_message.dart';
import '../../../../domain/repositories/chat_repository.dart';
import '../../../../data/services/firebase_auth_service.dart'; // Thêm import này

part 'chat_event.dart';
part 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final FirebaseAuthService _authService; // Cần service này để lấy ID mình kết nối Socket
  
  StreamSubscription? _socketSubscription;
  String? _currentFriendId; 

  ChatBloc(this._chatRepository, this._authService) : super(ChatState()) {
    
    // 1. Khởi tạo: Kết nối Socket & Tải lịch sử
    on<LoadMessages>((event, emit) async {
      _currentFriendId = event.friendId;
      emit(ChatState(isLoading: true));

      // A. Kết nối Socket
      final myId = _authService.currentUserId;
      if (myId != null) {
        _chatRepository.connect(myId);
      }

      // B. Tải lịch sử tin nhắn (API)
      try {
        final history = await _chatRepository.getHistory(event.friendId);
        // Đảo ngược danh sách vì ListView của chúng ta là reverse: true (tin mới nhất ở index 0)
        // Server thường trả về [Cũ nhất ... Mới nhất]
        // Nên ta đảo thành [Mới nhất ... Cũ nhất]
        final reversedHistory = List<ChatMessage>.from(history.reversed);
        
        emit(ChatState(isLoading: false, messages: reversedHistory));
      } catch (e) {
        print("Lỗi tải lịch sử chat: $e");
        emit(ChatState(isLoading: false, messages: []));
      }

      // C. Lắng nghe tin nhắn mới (Real-time Socket)
      _socketSubscription?.cancel();
      _socketSubscription = _chatRepository.messageStream.listen((data) {
        if (data is ChatMessage) {
           // Kiểm tra xem tin nhắn này có thuộc cuộc hội thoại hiện tại không
           // (Là tin mình gửi cho bạn, hoặc bạn gửi cho mình)
           if (data.senderId == _currentFriendId || data.receiverId == _currentFriendId) {
              // Thêm tin nhắn mới vào ĐẦU danh sách (vì ListView reverse)
              final currentMessages = List<ChatMessage>.from(state.messages);
              currentMessages.insert(0, data); 
              
              // Cập nhật UI bằng cách gọi event nội bộ
              add(_UpdateMessages(currentMessages));
           }
        } else if (data is String) {
           // Đây là thông báo lỗi từ Server (ví dụ: SPAM)
           // Bạn có thể xử lý hiển thị SnackBar ở đây nếu muốn
           print("Thông báo từ Server: $data");
        }
      });
    });

    // 2. Cập nhật danh sách tin nhắn (Event nội bộ)
    on<_UpdateMessages>((event, emit) {
      emit(ChatState(messages: event.messages, isLoading: false));
    });

    // 3. Gửi tin nhắn
    on<SendMessage>((event, emit) {
      if (_currentFriendId != null && event.content.trim().isNotEmpty) {
        _chatRepository.sendMessage(_currentFriendId!, event.content);
      }
    });
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    // _chatRepository.disconnect(); // Tùy chọn: Ngắt kết nối khi thoát màn hình chat
    return super.close();
  }
}