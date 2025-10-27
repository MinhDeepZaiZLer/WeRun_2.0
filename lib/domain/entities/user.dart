class User {
  final String id; // Lấy từ 'uid'
  final String email;
  final String name; // Lấy từ 'fullName'
  final String role;
  final DateTime? createdAt; // Thời gian tạo
  final String? address;
  final String? gender;
  final String? phoneNumber;
  final String? dob; // Ngày sinh (tạm dùng String cho giống bản Kotlin)
  final double? lastRunLat; // Vĩ độ lần chạy cuối
  final double? lastRunLng; // Kinh độ lần chạy cuối
  final bool isPublic; // Lấy từ 'public' (đổi tên cho chuẩn Dart)

  User({
    required this.id,
    required this.email,
    required this.name,
    this.role = "Customer", // Đặt giá trị mặc định
    this.createdAt,
    this.address,
    this.gender,
    this.phoneNumber,
    this.dob,
    this.lastRunLat,
    this.lastRunLng,
    this.isPublic = false, // Đặt giá trị mặc định
  });
}
