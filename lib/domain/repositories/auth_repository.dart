import 'package:dacs4_werun_2_0/domain/entities/user.dart';

abstract class AuthRepository {
  // trả về 1 stream để nghe thông tin user để UI check đã đăng nhập hay chưa
  Stream<User?> get currentUser;

  //  đăng nhập
  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  });
  // đăng ký
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();

}
