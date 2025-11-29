// lib/data/repositories/user_repository_impl.dart
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart'; 

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuthService _authService; // 2. Khai báo
  @override
  Future<List<User>> getFriends() async {
    final currentId = _authService.currentUserId;
    if (currentId == null) return [];
    return _firestoreService.getFriends(currentId);
  }
  // 3. Inject vào constructor
  UserRepositoryImpl(this._firestoreService, this._authService);

  @override
  Future<User?> getUser(String userId) {
    return _firestoreService.getUserProfile(userId);
  }

  @override
  Future<void> updateUser(User user) {
    return _firestoreService.updateUserProfile(user);
  }

  // 4. Implement hàm mới
  @override
  Future<List<User>> getAllUsers() async {
    final currentId = _authService.currentUserId;
    if (currentId == null) return [];
    return _firestoreService.getAllUsers(currentId);
  }
}