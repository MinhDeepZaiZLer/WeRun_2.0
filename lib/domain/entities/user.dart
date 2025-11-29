// lib/domain/entities/user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final String address;
  final DateTime? dob; // Ngày sinh
  final String phoneNumber;
  final String gender; // "Male", "Female", "Other"
  final String role;   // "Premium", "Free"
  final bool isPublic; // Cho phép người khác tìm thấy không?

  // Các trường cũ (để tương thích map)
  final double? lastRunLat;
  final double? lastRunLng;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.address = '',
    this.dob,
    this.phoneNumber = '',
    this.gender = 'Male',
    this.role = 'Free',
    this.isPublic = true,
    this.lastRunLat,
    this.lastRunLng,
  });

  // CopyWith để update state dễ dàng
  User copyWith({
    String? fullName,
    String? address,
    DateTime? dob,
    String? phoneNumber,
    String? gender,
    String? role,
    bool? isPublic,
    double? lastRunLat,
    double? lastRunLng,
  }) {
    return User(
      id: this.id,
      email: this.email,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      isPublic: isPublic ?? this.isPublic,
      lastRunLat: lastRunLat ?? this.lastRunLat,
      lastRunLng: lastRunLng ?? this.lastRunLng,
    );
  }

  // Chuyển từ Firestore JSON sang Object
  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      address: data['address'] ?? '',
      dob: (data['dob'] as Timestamp?)?.toDate(),
      phoneNumber: data['phoneNumber'] ?? '',
      gender: data['gender'] ?? 'Male',
      role: data['role'] ?? 'Free',
      isPublic: data['isPublic'] ?? true,
      lastRunLat: data['lastRunLat']?.toDouble(),
      lastRunLng: data['lastRunLng']?.toDouble(),
    );
  }

  // Chuyển từ Object sang JSON để lưu
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'address': address,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'role': role,
      'isPublic': isPublic,
      'lastRunLat': lastRunLat,
      'lastRunLng': lastRunLng,
    };
  }
}