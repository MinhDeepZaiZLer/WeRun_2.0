// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/auth_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy user từ state (để chào)
    final user = (context.watch<AuthBloc>().state as Authenticated).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('WeRun'),
        actions: [
          // Nút Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Gửi sự kiện Đăng xuất
              context.read<AuthBloc>().add(LogoutRequested());
            },
          )
        ],
      ),
      body: Center(
        child: Text(
          'Chào mừng, ${user.name}!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}