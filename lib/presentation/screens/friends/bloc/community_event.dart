// lib/presentation/screens/friends/bloc/community_event.dart
part of 'community_bloc.dart'; 

abstract class CommunityEvent {}

// Sự kiện khi người dùng gõ vào ô tìm kiếm
class SearchQueryChanged extends CommunityEvent { 
  final String query; 
  SearchQueryChanged(this.query); 
}

// Sự kiện bấm nút Gửi kết bạn
class SendRequestPressed extends CommunityEvent { 
  final String receiverId; 
  SendRequestPressed(this.receiverId); 
}

// Sự kiện bấm nút Chấp nhận
class AcceptRequestPressed extends CommunityEvent { 
  final String requestId; 
  AcceptRequestPressed(this.requestId); 
}

// Sự kiện bấm nút Từ chối
class RejectRequestPressed extends CommunityEvent { 
  final String requestId; 
  RejectRequestPressed(this.requestId); 
}