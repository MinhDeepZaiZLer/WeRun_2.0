part of "auth_bloc.dart";

@immutable
abstract class AuthState {
  const AuthState();
}

// trạng thái ban đầu khi app vừa mở (Initial)
class AuthInitial extends AuthState{

}


// trạng thái đang xử lý (hiện vòng loading)
class AuthLoading extends AuthState {

}


// trạng thái đăng nhập thành công
class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}


// trạng thái chưa đăng nhập

class Unauthenticated extends AuthState{

}

// trạng thái lỗi (thông báo lỗi)

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
} 