import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../screens/auth/bloc/auth_bloc.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/sign_up_screen.dart'; // Đổi tên nếu cần
import '../screens/placeholder_screen.dart'; // Tạo file này nếu chưa có
import '../screens/home/home_screen.dart';
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
// AppRouter.dart
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final onAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authState is AuthInitial) return null;
      if (authState is Authenticated) return onAuthRoute ? '/home' : null;
      if (authState is Unauthenticated) return onAuthRoute ? null : '/login';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider.value(value: authBloc, child: child);
        },
        routes: [
          GoRoute(path: '/login', builder: (context, state) => LoginScreen(onBackClicked: () {}, onLoginSuccess: () {})),
          GoRoute(path: '/register', builder: (context, state) => SignUpScreen(onBackClicked: () {}, onSignUpSuccess: () {})),
        ],
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
}

