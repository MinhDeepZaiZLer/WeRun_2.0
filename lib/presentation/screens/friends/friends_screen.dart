import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dacs4_werun_2_0/core/di/injection.dart';
import 'friends_bloc/friends_bloc.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FriendsBloc>()..add(LoadFriends()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "My Friends",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            // Nút tắt để sang màn hình Community kết bạn thêm
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Color(0xFFD0FD3E)),
              onPressed: () => context.push('/community'),
            )
          ],
        ),
        body: BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
            }

            if (state.friends.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_off, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text("You have no friends yet.", style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () => context.push('/community'),
                      child: const Text("Find friends now"),
                    )
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.friends.length,
              itemBuilder: (context, index) {
                final friend = state.friends[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFD0FD3E),
                      child: Text(
                        friend.fullName.isNotEmpty ? friend.fullName[0].toUpperCase() : "?",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    title: Text(
                      friend.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(friend.email),
                    trailing: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                    onTap: () {
                     
                      context.push('/chat', extra: friend);
                     
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}