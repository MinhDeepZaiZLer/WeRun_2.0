import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart'; // Để lấy UID

@LazySingleton(as: LeaderboardRepository)
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuthService _authService;

  LeaderboardRepositoryImpl(this._firestoreService, this._authService);
@override
  Future<List<LeaderboardEntry>> getRankings(LeaderboardFilter filter, {List<String>? friendIds}) async {
    print("📊 [Leaderboard] Bắt đầu lấy dữ liệu...");
    
    // 1. Lấy dữ liệu thô
    final snapshot = await _firestoreService.getAllRunsSnapshot();
    print("📊 [Leaderboard] Tìm thấy ${snapshot.docs.length} bản ghi chạy bộ trong Firestore.");

    if (snapshot.docs.isEmpty) {
      return []; // Trả về rỗng nếu DB chưa có gì
    }
    
    final myId = _authService.currentUserId;

    // 2. Thời gian
    DateTime now = DateTime.now();
    DateTime? startTime;
    switch (filter) {
      case LeaderboardFilter.week: startTime = now.subtract(const Duration(days: 7)); break;
      case LeaderboardFilter.month: startTime = now.subtract(const Duration(days: 30)); break;
      case LeaderboardFilter.year: startTime = now.subtract(const Duration(days: 365)); break;
      case LeaderboardFilter.total: startTime = null; break;
    }

    Map<String, List<DocumentSnapshot>> runsByUser = {};
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'] as String?; // Có thể null nếu dữ liệu cũ lỗi
      
      // Log từng dòng để kiểm tra
      // print("   -> Đang xem Run ID: ${doc.id}, User: $userId");

      if (userId == null) continue; 

      // Xử lý Timestamp (Quan trọng)
      DateTime timestamp;
      try {
         timestamp = (data['timestamp'] as Timestamp).toDate();
      } catch (e) {
         print("⚠️ [Leaderboard] Lỗi ngày tháng bản ghi ${doc.id}: $e");
         continue;
      }
      
      // Lọc thời gian
      if (startTime != null && timestamp.isBefore(startTime)) {
         // print("      -> Bỏ qua: Quá cũ");
         continue;
      }
      
      // Lọc bạn bè
      if (friendIds != null && !friendIds.contains(userId) && userId != myId) {
         // print("      -> Bỏ qua: Không phải bạn bè");
         continue;
      }

      if (runsByUser[userId] == null) runsByUser[userId] = [];
      runsByUser[userId]!.add(doc);
    }
    
    print("📊 [Leaderboard] Tổng hợp được ${runsByUser.length} người dùng có dữ liệu.");

    // 3. Tính toán
    List<LeaderboardEntry> leaderboard = [];
    
    for (var entry in runsByUser.entries) {
      final userId = entry.key;
      int totalDuration = 0;
      double totalDistance = 0.0;
      
      for (var runDoc in entry.value) {
        final data = runDoc.data() as Map<String, dynamic>;
        totalDuration += (data['durationInSeconds'] as num?)?.toInt() ?? 0; // Dùng num để an toàn int/double
        totalDistance += (data['distanceInMeters'] as num?)?.toDouble() ?? 0.0;
      }
      
      // Lấy tên người dùng (Nếu chưa có Usecase lấy tên, tạm dùng ID)
      // Để đẹp hơn, ta có thể gọi getUserProfile ở đây (tuy hơi chậm)
      String displayName = "Runner";
      try {
         final userProfile = await _firestoreService.getUserProfile(userId);
         if (userProfile != null && userProfile.fullName.isNotEmpty) {
           displayName = userProfile.fullName;
         }
      } catch (e) {
        print("Lỗi lấy tên user $userId: $e");
      }

      if (totalDuration > 0 || totalDistance > 0) {
        leaderboard.add(LeaderboardEntry(
          userId: userId, 
          fullName: displayName, 
          totalDistanceKm: totalDistance / 1000,
          totalDurationSeconds: totalDuration,
        ));
      }
    }
    
    // Sắp xếp (Giảm dần theo quãng đường)
    leaderboard.sort((a, b) => b.totalDistanceKm.compareTo(a.totalDistanceKm));
    
    print("✅ [Leaderboard] Hoàn tất: ${leaderboard.length} mục.");
    return leaderboard;
  }
}