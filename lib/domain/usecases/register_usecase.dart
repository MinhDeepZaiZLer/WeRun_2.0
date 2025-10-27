import 'package:dacs4_werun_2_0/domain/entities/user.dart';
import 'package:dacs4_werun_2_0/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository authRepository;
  RegisterUsecase(this.authRepository);

  Future<void> call({
    required String name,
    required String email,
    required String password,
  }) {
    return authRepository.registerWithEmailPassword(
      email: email,
      password: password,
      name: name,
    );
  }
}
