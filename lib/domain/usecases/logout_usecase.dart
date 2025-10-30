import 'package:dacs4_werun_2_0/domain/entities/user.dart';
import 'package:dacs4_werun_2_0/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
@lazySingleton
class LogoutUsecase {
  final AuthRepository authRepository;
  LogoutUsecase(this.authRepository);

  Future<void> call() {
    return authRepository.logout();
  }
}
