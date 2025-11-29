import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dacs4_werun_2_0/core/di/injection.dart';
import 'package:intl/intl.dart'; 
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
// 1. THÊM IMPORT NÀY (Để lấy User ID trực tiếp)
import '../../../data/services/firebase_auth_service.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _gender = 'Male';
  DateTime? _dob;
  bool _isPublic = true;
  String _role = 'Free';
  
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 2. SỬA HÀM NÀY
  Future<void> _loadUserData() async {
    // Thay vì lấy từ AuthBloc (gây lỗi), ta lấy trực tiếp từ Service
    final userId = getIt<FirebaseAuthService>().currentUserId;
    
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final user = await getIt<UserRepository>().getUser(userId);
      
      if (user != null) {
        // Nếu đã có thông tin trong DB -> Load lên
        setState(() {
          _currentUser = user;
          _nameController.text = user.fullName;
          _phoneController.text = user.phoneNumber;
          _addressController.text = user.address;
          _gender = user.gender;
          _dob = user.dob;
          _isPublic = user.isPublic;
          _role = user.role;
          _isLoading = false;
        });
      } else {
        // Nếu chưa có thông tin (lần đầu) -> Tạo User mới từ thông tin Auth
        // (Ví dụ: Lấy email/tên từ Google Sign In nếu có)
        final authUser = getIt<FirebaseAuthService>().currentUser; // Lấy Firebase User
        setState(() {
            _currentUser = User(
                id: userId, 
                email: authUser?.email ?? '', 
                fullName: authUser?.displayName ?? ''
            );
            _nameController.text = authUser?.displayName ?? '';
            _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi load profile: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    // Nếu _currentUser null (lỗi load), ta thử tạo tạm một cái
    if (_currentUser == null) {
        final userId = getIt<FirebaseAuthService>().currentUserId;
        if (userId == null) return;
        _currentUser = User(id: userId, email: '', fullName: '');
    }

    final updatedUser = _currentUser!.copyWith(
      fullName: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      gender: _gender,
      dob: _dob,
      isPublic: _isPublic,
    );

    setState(() => _isLoading = true);
    try {
      await getIt<UserRepository>().updateUser(updatedUser);
      // Cập nhật lại state cục bộ
      _currentUser = updatedUser;
      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green)
         );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 8),
            Text(_role.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 24),

            // Full Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Phone & Gender
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                    items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date of Birth
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dob ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _dob = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date of Birth', border: OutlineInputBorder()),
                child: Text(_dob == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(_dob!)),
              ),
            ),
            const SizedBox(height: 16),

            // Address
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Public Switch
            SwitchListTile(
              title: const Text("Public Profile"),
              subtitle: const Text("Allow others to find you"),
              value: _isPublic,
              onChanged: (v) => setState(() => _isPublic = v),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E), foregroundColor: Colors.black),
                child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}