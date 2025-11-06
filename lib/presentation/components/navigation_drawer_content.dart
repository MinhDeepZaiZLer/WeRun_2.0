import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '/presentation/screens/auth/bloc/auth_bloc.dart';

class NavigationDrawerContent extends StatelessWidget {
  const NavigationDrawerContent({super.key});
  @override
  Widget build(BuildContext context) {
    final AuthState = context.watch<AuthBloc>().state;
    String userName = "User Name";
    String userEmail = "user@example.com";

    if (AuthState is Authenticated) {
      userName = AuthState.user.name;
      userEmail = AuthState.user.email;
    }
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFC4FF53), // Màu #C4FF53
            ),
            accountName: Text(
              userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            accountEmail: Text(
              userEmail,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.run_circle_outlined,
                color: Colors.black,
                size: 40,
              ),
            ),
          ),

          //menu items
          ListTile(
            leading: const Icon(Icons.person_outlined),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              //context.go("/profile")
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Run History"),
            onTap: () {
              Navigator.pop(context);
              // context.go("/history");
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text("Friends"),
            onTap: () {
              Navigator.pop(context);
              // context.go("/friend");
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard_outlined),
            title: const Text('Statistics'),
            onTap: () {
              Navigator.pop(context);
              // context.go('/statistics'); // Sẽ mở ở ngày sau
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // context.go('/settings'); // Sẽ mở ở ngày sau
            },
          ),

          const Spacer(), // Đẩy Logout xuống cuối
          // Sign Out
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sign Out'),
            onTap: () {
              // *** KẾT NỐI VỚI AUTHBLOC ***
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pop(context); // Đóng drawer
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
