import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dacs4_werun_2_0/core/di/injection.dart';
import 'package:dacs4_werun_2_0/data/services/firebase_auth_service.dart';
import '../../../domain/entities/user.dart';
import 'bloc/chat_bloc.dart';

class ChatScreen extends StatelessWidget {
  final User friend; // Người mình đang chat cùng

  const ChatScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatBloc>()..add(LoadMessages(friend.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade300,
                child: Text(friend.fullName.isNotEmpty ? friend.fullName[0] : "?"),
              ),
              const SizedBox(width: 10),
              Text(friend.fullName, style: const TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [
            // 1. Danh sách tin nhắn
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state.isLoading) return const Center(child: CircularProgressIndicator());
                  
                  if (state.messages.isEmpty) {
                    return Center(child: Text("Say hello to ${friend.fullName}!"));
                  }

                  return ListView.builder(
                    reverse: true, // Tin mới nhất ở dưới cùng
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return _MessageBubble(message: message);
                    },
                  );
                },
              ),
            ),
            
            // 2. Ô nhập tin nhắn
            _ChatInput(),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message; // Dùng dynamic hoặc ChatMessage
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // Lấy ID của mình để biết tin nhắn nằm bên trái hay phải
    final myId = getIt<FirebaseAuthService>().currentUserId;
    final isMe = message.senderId == myId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFD0FD3E) : Colors.grey.shade200, // Xanh WeRun hoặc Xám
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isMe ? Colors.black : Colors.black87),
        ),
      ),
    );
  }
}

class _ChatInput extends StatefulWidget {
  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  final _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatBloc>().add(SendMessage(text));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFFD0FD3E)),
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}