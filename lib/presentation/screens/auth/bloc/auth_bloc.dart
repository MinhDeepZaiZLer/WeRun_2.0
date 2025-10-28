// lib/presentation/screens/auth/bloc/auth_bloc.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/entities/user.dart';
import '../../../../domain/usecases/get_current_user_usecase.dart';
import '../../../../domain/usecases/login_usecase.dart';
import '../../../../domain/usecases/logout_usecase.dart';
import '../../../../domain/usecases/register_usecase.dart';

// Import 2 file bạn vừa tạo
part 'auth_event.dart';
part 'auth_state.dart';

@injectable // <-- Đánh dấu để DI biết
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // 1. Khai báo các Usecases mà Bloc này cần
  final GetCurrentUserUsecase _getCurrentUserUsecase;
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final LogoutUsecase _logoutUsecase;

  StreamSubscription<User?>? _userSubscription;

  // 2. Yêu cầu DI "tiêm" các Usecases vào
  AuthBloc(
    this._getCurrentUserUsecase,
    this._loginUsecase,
    this._registerUsecase,
    this._logoutUsecase,
  ) : super(AuthInitial()) { // Trạng thái ban đầu
    
    // 3. Lắng nghe stream user từ Usecase
    _userSubscription = _getCurrentUserUsecase.call().listen((user) {
      // Mỗi khi trạng thái user thay đổi (login/logout),
      // add sự kiện nội bộ _AuthStateChanged
      add(_AuthStateChanged(user));
    });

    // 4. Đăng ký các trình xử lý sự kiện
    on<_AuthStateChanged>(_onAuthStateChanged);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel(); // Hủy stream khi Bloc bị đóng
    return super.close();
  }

  // === CÁC HÀM XỬ LÝ EVENT ===

  void _onAuthStateChanged(_AuthStateChanged event, Emitter<AuthState> emit) {
    // Khi stream báo có user -> emit Authenticated
    // Khi stream báo null -> emit Unauthenticated
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Báo UI "đang tải"
    try {
      await _loginUsecase.call(email: event.email, password: event.password);
      // KHÔNG cần emit Authenticated, vì stream _onAuthStateChanged sẽ tự làm
    } catch (e) {
      emit(AuthFailure(e.toString())); // Báo lỗi
      emit(Unauthenticated()); // Quay về trạng thái chưa đăng nhập
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _registerUsecase.call(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      // KHÔNG cần emit Authenticated, vì stream _onAuthStateChanged sẽ tự làm
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _logoutUsecase.call();
      // KHÔNG cần emit Unauthenticated, vì stream _onAuthStateChanged sẽ tự làm
    } catch (e) {
      emit(AuthFailure(e.toString()));
      // (Nếu logout lỗi thì vẫn giữ state Authenticated cũ)
      final currentState = state;
      if (currentState is Authenticated) {
        emit(Authenticated(currentState.user));
      }
    }
  }
}