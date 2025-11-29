class FriendRequest {
  final String id;
  final String senderId;
  final String senderName; // Lưu tên để hiển thị nhanh
  final String receiverId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime timestamp;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.status,
    required this.timestamp,
  });
}