part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {
  
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

}
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  RegisterRequested({required this.name, required this.password, required this.email});
}

class LogoutRequested extends AuthEvent{

}

class _AuthStateChanged extends AuthEvent {
  final User? user;
  _AuthStateChanged(this.user);
}