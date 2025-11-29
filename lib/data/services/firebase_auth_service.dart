import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:injectable/injectable.dart';

@lazySingleton
class FirebaseAuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  // 1. Lấy stream user (để lắng nghe trạng thái đăng nhập)
  Stream<auth.User?> get firebaseUserStream {
    return _firebaseAuth.authStateChanges();
  }

  // 2. Lấy user ID hiện tại
  String? get currentUserId {
    return _firebaseAuth.currentUser?.uid;
  }

  // 3. Lấy đối tượng User hiện tại (CẦN THÊM CÁI NÀY)
  auth.User? get currentUser {
    return _firebaseAuth.currentUser;
  }

  // 4. Đăng nhập
  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on auth.FirebaseAuthException catch (e) {
      throw Exception(e.message); 
    }
  }

  // 5. Đăng ký
  Future<auth.UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      return credential;
    } on auth.FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // 6. Đăng xuất
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}