// lib/presentation/screens/friends/bloc/community_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Import các file Domain & Data cần thiết
import '../../../../data/services/firestore_service.dart';
import '../../../../data/services/firebase_auth_service.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/friend_request.dart';

// Kết nối với 2 file con (Event & State)
part 'community_event.dart';
part 'community_state.dart';

@injectable
class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final FirestoreService _firestoreService;
  final FirebaseAuthService _authService;

  CommunityBloc(this._firestoreService, this._authService) : super(CommunityState()) {
    
    // 1. Xử lý Tìm kiếm
    on<SearchQueryChanged>((event, emit) async {
      if (event.query.isEmpty) {
        // Nếu ô tìm kiếm rỗng -> Xóa kết quả, giữ nguyên các state khác
        emit(CommunityState(
          searchResults: [], 
          receivedRequests: state.receivedRequests
        ));
        return;
      }

      // Bật loading, giữ nguyên danh sách cũ để tránh nháy màn hình
      emit(CommunityState(
        isLoading: true, 
        searchResults: state.searchResults,
        receivedRequests: state.receivedRequests
      ));
      
      final results = await _firestoreService.searchUsers(event.query);
      
      // Lọc bỏ bản thân
      final myId = _authService.currentUserId;
      final filtered = results.where((u) => u.id != myId).toList();
      
      emit(CommunityState(
        searchResults: filtered, 
        isLoading: false,
        receivedRequests: state.receivedRequests
      ));
    });

    // 2. Xử lý Gửi lời mời
    on<SendRequestPressed>((event, emit) async {
      final myId = _authService.currentUserId;
      if (myId == null) return;
      
      final myUser = await _firestoreService.getUserProfile(myId);
      
      await _firestoreService.sendFriendRequest(
        myId, 
        myUser?.fullName ?? 'Unknown', 
        event.receiverId
      );
      
      // Emit state mới để hiện thông báo, giữ nguyên data cũ
      emit(CommunityState(
        searchResults: state.searchResults,
        receivedRequests: state.receivedRequests,
        message: "Đã gửi lời mời kết bạn!"
      ));
    });

    // 3. Xử lý Chấp nhận
    on<AcceptRequestPressed>((event, emit) async {
      await _firestoreService.respondToRequest(event.requestId, true);
      emit(CommunityState(
        searchResults: state.searchResults,
        receivedRequests: state.receivedRequests,
        message: "Đã chấp nhận kết bạn!"
      ));
    });
    
    // 4. Xử lý Từ chối
    on<RejectRequestPressed>((event, emit) async {
      await _firestoreService.respondToRequest(event.requestId, false);
      emit(CommunityState(
        searchResults: state.searchResults,
        receivedRequests: state.receivedRequests,
        message: "Đã từ chối lời mời."
      ));
    });
  }
  
  // Stream realtime cho danh sách lời mời
  Stream<List<FriendRequest>> get requestsStream {
     final myId = _authService.currentUserId;
     if (myId == null) return Stream.value([]);
     return _firestoreService.getReceivedRequestsStream(myId);
  }
}