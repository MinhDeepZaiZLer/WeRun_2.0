import 'package:dacs4_werun_2_0/domain/entities/user.dart';
import 'package:dacs4_werun_2_0/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetCurrentUserUsecase {
  final AuthRepository authRepository;
  GetCurrentUserUsecase(this.authRepository);

  Stream<User?> call() => authRepository.currentUser;
}
