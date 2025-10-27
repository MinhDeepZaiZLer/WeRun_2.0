import 'package:dacs4_werun_2_0/domain/entities/user.dart';
import 'package:dacs4_werun_2_0/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository authRepository;
  GetCurrentUserUsecase(this.authRepository);

  //  từ luồng dữ liệu stream trả về user theo thời gian thực
  Stream<User?> call() {
    return authRepository.currentUser;
  }
}
