// lib/data/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/run_activity_model.dart';
// (Bạn có thể cần import firebase_auth_service để lấy userId)
import 'firebase_auth_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/friend_request.dart';

@lazySingleton
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuthService _authService;

  FirestoreService(this._authService);
  Future<QuerySnapshot> getAllRunsSnapshot() async {
    return await _db.collectionGroup('runs').get();
  }

  // --- HÀM MỚI (để lưu Run) ---
  Future<void> saveRunActivity(RunActivityModel run) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception("User not logged in");
    }

    // Tạo một document mới trong collection 'runs'
    await _db
        .collection('users')
        .doc(userId)
        .collection('runs')
        .add(run.toJson());
  }

  // --- HÀM MỚI (để lấy Lịch sử Run) ---
  Stream<List<RunActivityModel>> getRunHistoryStream() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.value([]); // Trả về stream rỗng nếu chưa login
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('runs')
        .orderBy('timestamp', descending: true) // Sắp xếp (mới nhất trước)
        .snapshots() // Lắng nghe real-time
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RunActivityModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<User?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return User.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Lỗi lấy user: $e");
      return null;
    }
  }

  // 2. Cập nhật thông tin User
  Future<void> updateUserProfile(User user) async {
    // Dùng set với merge: true:
    // - Nếu chưa có: Tạo mới.
    // - Nếu đã có: Cập nhật đè lên.
    await _db
        .collection('users')
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<List<User>> getAllUsers(String currentUserId) async {
    try {
      final snapshot = await _db.collection('users').get();

      return snapshot.docs
          .map((doc) => User.fromMap(doc.data(), doc.id))
          .where((user) => user.id != currentUserId) // Lọc bỏ chính mình
          .toList();
    } catch (e) {
      print("Lỗi lấy danh sách user: $e");
      return [];
    }
  }
  // === TÍNH NĂNG KẾT BẠN (FRIEND SYSTEM) ===

  // 1. Tìm kiếm User theo tên
  Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    try {
      // CÁCH SỬA: Lấy dữ liệu về rồi mới lọc
      // (Cách này phù hợp với quy mô đồ án, nếu app thực tế hàng triệu user thì cần giải pháp khác như Algolia)

      final snapshot = await _db.collection('users').get();

      final lowerQuery = query
          .toLowerCase()
          .trim(); // Chuyển từ khóa tìm kiếm về chữ thường

      return snapshot.docs.map((doc) => User.fromMap(doc.data(), doc.id)).where(
        (user) {
          // Lấy tên và email, chuyển về chữ thường để so sánh
          final name = user.fullName.toLowerCase();
          final email = user.email.toLowerCase();

          // Kiểm tra xem tên hoặc email có CHỨA từ khóa không
          return name.contains(lowerQuery) || email.contains(lowerQuery);
        },
      ).toList();
    } catch (e) {
      print("Lỗi tìm kiếm: $e");
      return [];
    }
  }

  // 2. Gửi lời mời kết bạn
  Future<void> sendFriendRequest(
    String senderId,
    String senderName,
    String receiverId,
  ) async {
    // Kiểm tra xem đã gửi chưa để tránh spam
    final existing = await _db
        .collection('friend_requests')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existing.docs.isNotEmpty) return; // Đã có lời mời pending rồi

    await _db.collection('friend_requests').add({
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 3. Lấy danh sách lời mời ĐÃ NHẬN (Realtime Stream)
  Stream<List<FriendRequest>> getReceivedRequestsStream(String currentUserId) {
    return _db
        .collection('friend_requests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending') // Chỉ lấy lời mời đang chờ
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return FriendRequest(
              id: doc.id,
              senderId: data['senderId'],
              senderName: data['senderName'] ?? 'Unknown',
              receiverId: data['receiverId'],
              status: data['status'],
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList(),
        );
  }

  // 4. Phản hồi lời mời (Chấp nhận / Từ chối)
  Future<void> respondToRequest(String requestId, bool accept) async {
    final status = accept ? 'accepted' : 'rejected';

    // Cập nhật trạng thái lời mời
    await _db.collection('friend_requests').doc(requestId).update({
      'status': status,
    });

    // Nếu chấp nhận -> Thêm vào friend list của cả 2 người (Tuỳ chọn mở rộng sau này)
    // Logic thêm friend list phức tạp hơn chút, tạm thời ta chỉ đổi status.
  }

  // 5. Lấy danh sách bạn bè (Đã chấp nhận)
  Future<List<User>> getFriends(String currentUserId) async {
    try {
      List<String> friendIds = [];

      // A. Tìm trường hợp mình là SENDER
      final sentQuery = await _db
          .collection('friend_requests')
          .where('senderId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'accepted')
          .get();

      for (var doc in sentQuery.docs) {
        friendIds.add(doc['receiverId']);
      }

      // B. Tìm trường hợp mình là RECEIVER
      final receivedQuery = await _db
          .collection('friend_requests')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'accepted')
          .get();

      for (var doc in receivedQuery.docs) {
        friendIds.add(doc['senderId']);
      }

      // C. Lấy thông tin User từ danh sách ID
      if (friendIds.isEmpty) return [];

      // Firestore 'whereIn' chỉ hỗ trợ tối đa 10 phần tử.
      // Nếu danh sách > 10, cần chia nhỏ (tạm thời làm đơn giản loop qua để lấy từng người)
      List<User> friends = [];
      for (var id in friendIds) {
        final userDoc = await _db.collection('users').doc(id).get();
        if (userDoc.exists) {
          friends.add(User.fromMap(userDoc.data()!, userDoc.id));
        }
      }

      return friends;
    } catch (e) {
      print("Lỗi lấy bạn bè: $e");
      return [];
    }
  }
}
