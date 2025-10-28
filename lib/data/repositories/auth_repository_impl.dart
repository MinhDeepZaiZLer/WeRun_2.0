import 'package:firebase_auth/firebase_auth.dart' as auth; // SDK của Firebase
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart'; // Lớp User (Domain)
import '../../domain/repositories/auth_repository.dart'; // Hợp đồng (Domain)
import '../services/firebase_auth_service.dart'; // Dịch vụ (Data)
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;

  // Lớp này cần FirebaseAuthService để hoạt động
  AuthRepositoryImpl(this._authService);

  @override
  Stream<User?> get currentUser {
    // 1. Lắng nghe stream từ Firebase Service (trả về auth.User?)
    return _authService.firebaseUserStream.map((auth.User? firebaseUser) {
      // 2. "Dịch" nó
      if (firebaseUser == null) {
        return null; // Nếu user là null (đã logout), trả về null
      }
      
      // Nếu có user (đã login), "dịch" auth.User -> domain.User
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '', // Email không bao giờ null khi đã login
        name: firebaseUser.displayName ?? '', // Lấy tên ta đã set lúc đăng ký
        
        // Các trường còn lại (address, gender...) sẽ là null/default.
        // Chúng ta sẽ cập nhật chúng từ Firestore ở các ngày sau
        // khi làm chức năng Profile.
      );
    });
  }

  @override
  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) {
    // Đơn giản là chuyển tiếp cuộc gọi đến Service
    return _authService.loginWithEmailPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() {
    // Đơn giản là chuyển tiếp cuộc gọi đến Service
    return _authService.logout();
  }

  @override
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) {
    // Gọi hàm service đã được cập nhật (có 'name')
    return _authService.registerWithEmailPassword(
      email: email,
      password: password,
      name: name,
    );
  }
}