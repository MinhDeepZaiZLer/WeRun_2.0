// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../data/repositories/run_repository_impl.dart' as _i282;
import '../../data/services/firebase_auth_service.dart' as _i734;
import '../../data/services/firestore_service.dart' as _i367;
import '../../data/services/gps_service.dart' as _i1059;
import '../../domain/repositories/auth_repository.dart' as _i1073;
import '../../domain/repositories/run_repository.dart' as _i633;
import '../../domain/usecases/get_current_user_usecase.dart' as _i771;
import '../../domain/usecases/get_run_history_usecase.dart' as _i460;
import '../../domain/usecases/login_usecase.dart' as _i253;
import '../../domain/usecases/logout_usecase.dart' as _i981;
import '../../domain/usecases/register_usecase.dart' as _i35;
import '../../domain/usecases/save_run_usecase.dart' as _i725;
import '../../presentation/screens/auth/bloc/auth_bloc.dart' as _i253;
import '../../presentation/screens/history/bloc/history_bloc.dart' as _i818;
import '../../presentation/screens/home/home_bloc.dart' as _i812;
import '../../presentation/screens/run/bloc/run_bloc.dart' as _i169;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.factory<_i812.HomeBloc>(() => _i812.HomeBloc());
  gh.lazySingleton<_i734.FirebaseAuthService>(
    () => _i734.FirebaseAuthService(),
  );
  gh.lazySingleton<_i1059.GpsService>(() => _i1059.GpsService());
  gh.lazySingleton<_i1073.AuthRepository>(
    () => _i895.AuthRepositoryImpl(gh<_i734.FirebaseAuthService>()),
  );
  gh.lazySingleton<_i367.FirestoreService>(
    () => _i367.FirestoreService(gh<_i734.FirebaseAuthService>()),
  );
  gh.lazySingleton<_i633.RunRepository>(
    () => _i282.RunRepositoryImpl(gh<_i367.FirestoreService>()),
  );
  gh.lazySingleton<_i771.GetCurrentUserUsecase>(
    () => _i771.GetCurrentUserUsecase(gh<_i1073.AuthRepository>()),
  );
  gh.lazySingleton<_i253.LoginUsecase>(
    () => _i253.LoginUsecase(gh<_i1073.AuthRepository>()),
  );
  gh.lazySingleton<_i981.LogoutUsecase>(
    () => _i981.LogoutUsecase(gh<_i1073.AuthRepository>()),
  );
  gh.lazySingleton<_i35.RegisterUsecase>(
    () => _i35.RegisterUsecase(gh<_i1073.AuthRepository>()),
  );
  gh.lazySingleton<_i460.GetRunHistoryUsecase>(
    () => _i460.GetRunHistoryUsecase(gh<_i633.RunRepository>()),
  );
  gh.lazySingleton<_i725.SaveRunUsecase>(
    () => _i725.SaveRunUsecase(gh<_i633.RunRepository>()),
  );
  gh.factory<_i169.RunBloc>(
    () => _i169.RunBloc(gh<_i1059.GpsService>(), gh<_i725.SaveRunUsecase>()),
  );
  gh.factory<_i253.AuthBloc>(
    () => _i253.AuthBloc(
      gh<_i771.GetCurrentUserUsecase>(),
      gh<_i253.LoginUsecase>(),
      gh<_i35.RegisterUsecase>(),
      gh<_i981.LogoutUsecase>(),
    ),
  );
  gh.factory<_i818.HistoryBloc>(
    () => _i818.HistoryBloc(gh<_i460.GetRunHistoryUsecase>()),
  );
  return getIt;
}
