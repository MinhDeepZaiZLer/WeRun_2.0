// lib/presentation/screens/friends/other_user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:dacs4_werun_2_0/domain/entities/user.dart';

class OtherUserProfileScreen extends StatelessWidget {
  final User user;

  const OtherUserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(user.fullName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : "?",
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tên và Vai trò
            Text(
              user.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user.role.toUpperCase(),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
            ),
            
            const SizedBox(height: 32),

            // KIỂM TRA QUYỀN RIÊNG TƯ
            if (user.isPublic) ...[
              // Nếu Public -> Hiện thông tin
              _buildInfoTile(Icons.email, "Email", user.email),
              _buildInfoTile(Icons.phone, "Phone", user.phoneNumber.isNotEmpty ? user.phoneNumber : "Hidden"),
              _buildInfoTile(Icons.location_on, "Address", user.address.isNotEmpty ? user.address : "Hidden"),
              _buildInfoTile(Icons.person, "Gender", user.gender),
              
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              
              // Thống kê chạy bộ (Có thể lấy từ Firestore sau này)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("Runs", "0"), // Placeholder
                  _buildStatItem("Distance", "0.0 km"),
                ],
              ),
            ] else ...[
              // Nếu Private -> Hiện khóa
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "This profile is private.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            
            // Nút kết bạn (Sẽ làm chức năng ở bước sau)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Feature coming soon: Add Friend"))
                   );
                },
                icon: const Icon(Icons.person_add),
                label: const Text("Add Friend"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD0FD3E),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}