import 'package:dacs4_werun_2_0/presentation/screens/friends/other_user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dacs4_werun_2_0/core/di/injection.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/friend_request.dart';
import 'bloc/community_bloc.dart';
// (Import OtherUserProfileScreen nếu có)

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CommunityBloc>(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Community",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            bottom: const TabBar(
              labelColor: Colors.black,
              indicatorColor: Color(0xFFD0FD3E), // Màu xanh WeRun
              tabs: [
                Tab(text: "Find Friends"),
                Tab(text: "Requests"),
              ],
            ),
          ),
          body: BlocListener<CommunityBloc, CommunityState>(
            listenWhen: (previous, current) => current.message != null,
            listener: (context, state) {
              if (state.message != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message!)));
              }
            },
            child: const TabBarView(children: [_SearchTab(), _RequestsTab()]),
          ),
        ),
      ),
    );
  }
}

// --- TAB 1: TÌM KIẾM ---
class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search user by name...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: (value) =>
                context.read<CommunityBloc>().add(SearchQueryChanged(value)),
          ),
        ),
        Expanded(
          child: BlocBuilder<CommunityBloc, CommunityState>(
            builder: (context, state) {
              if (state.isLoading)
                return const Center(child: CircularProgressIndicator());
              if (state.searchResults.isEmpty)
                return const Center(child: Text("Type name to find friends"));

              return ListView.builder(
                itemCount: state.searchResults.length,
                itemBuilder: (context, index) {
                  final user = state.searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.fullName[0].toUpperCase()),
                    ),
                    title: Text(user.fullName),
                    subtitle: Text(user.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.blue),
                      onPressed: () {
                        context.read<CommunityBloc>().add(
                          SendRequestPressed(user.id),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OtherUserProfileScreen(user: user),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- TAB 2: LỜI MỜI KẾT BẠN ---
class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CommunityBloc>();

    return StreamBuilder<List<FriendRequest>>(
      stream: bloc.requestsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text("Error loading requests"));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final requests = snapshot.data!;
        if (requests.isEmpty)
          return const Center(child: Text("No pending requests"));

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text("${req.senderName} wants to be friends"),
                subtitle: Text("Received recently"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                      onPressed: () => bloc.add(AcceptRequestPressed(req.id)),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 32,
                      ),
                      onPressed: () => bloc.add(RejectRequestPressed(req.id)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.group), // Icon nhóm bạn
                      title: const Text('Friends'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/friends'); // Sửa đường dẫn
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
