import 'package:dacs4_werun_2_0/domain/entities/user.dart';
import 'package:dacs4_werun_2_0/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository authRepository;
  LoginUsecase(this.authRepository);

  Future<void> call({required String password, required String email}) {
    return authRepository.loginWithEmailPassword(email: email, password: password);
  }
}