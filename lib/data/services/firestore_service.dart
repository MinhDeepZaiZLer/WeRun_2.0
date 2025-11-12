// lib/data/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/run_activity_model.dart';
// (Bạn có thể cần import firebase_auth_service để lấy userId)
import 'firebase_auth_service.dart'; 

@lazySingleton
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuthService _authService;

  FirestoreService(this._authService);

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
  
  // (Bạn có thể có các hàm khác ở đây, ví dụ: saveUser, getUser...)
}