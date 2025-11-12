import 'package:dacs4_werun_2_0/presentation/screens/run/map_screen.dart';
import 'package:dacs4_werun_2_0/presentation/screens/run/run_screen.dart';
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
class AppRouter {
  
  // KHÔNG CẦN AuthBloc ở đây nữa
  
  static final GoRouter router = GoRouter(
    initialLocation: '/login', 
    
    // 1. Lắng nghe AuthBloc từ Context
    refreshListenable: GoRouterRefreshStream(getIt<AuthBloc>().stream),
    
    // 2. Logic redirect giữ nguyên, nhưng lấy bloc từ context
    redirect: (BuildContext context, GoRouterState state) {
      final authState = context.read<AuthBloc>().state; // <-- Lấy từ Context
      
      final bool onAuthRoute = state.matchedLocation == '/login' ||
                               state.matchedLocation == '/register';

      if (authState is AuthInitial) return null; 
      
      if (authState is Authenticated) {
        return onAuthRoute ? '/home' : null;
      }

      if (authState is Unauthenticated) {
        return onAuthRoute ? null : '/login';
      }
      
      return null;
    },
    
    routes: [
      // 3. XÓA ShellRoute, vì Bloc đã được cung cấp ở main.dart
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(), 
      ),
      GoRoute(
        path: '/run',
        builder: (context, state) => const RunScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
      // TODO: Thêm các route '/profile', '/run_history', v.v.
    ],
  );
}