// lib/core/di/injection.dart

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

// --- THÊM IMPORT THỦ CÔNG ---
import '../../domain/repositories/run_repository.dart';
import '../../data/repositories/run_repository_impl.dart';
// ---------------------------

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async {
  // 1. Để injectable tự đăng ký các cái khác trước
  await init(getIt);

  // 2. ĐĂNG KÝ THỦ CÔNG RUN REPOSITORY (NẾU TỰ ĐỘNG THẤT BẠI)
  // Nếu GetIt chưa có RunRepository thì đăng ký nó
  if (!getIt.isRegistered<RunRepository>()) {
      getIt.registerLazySingleton<RunRepository>(
          () => RunRepositoryImpl(getIt())); // getIt() sẽ tự tìm FirestoreService
  }
}