import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:injectable/injectable.dart';

@lazySingleton // chỉ tạo class này 1 lần duy nhất khi nó được gọi lần đầu (ý nghĩa)
class FirebaseAuthService{
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  // lấy stream từ firebase trả về kiểu dl user của firebase
  Stream<auth.User?> get firebaseUserStream {
    return _firebaseAuth.authStateChanges();
  }
  // 2. Lấy user ID hiện tại
  String? get currentUserId {
    return _firebaseAuth.currentUser?.uid;
  }

  // 3. Đăng nhập
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
      // Bắt lỗi và ném ra (throw) để lớp Repository xử lý
      // (Bạn có thể custom lỗi sau, giờ cứ ném ra đã)
      throw Exception(e.message); 
    }
  }

  // 4. Đăng ký
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

  // 5. Đăng xuất
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}