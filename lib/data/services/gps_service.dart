import 'package:injectable/injectable.dart';
import 'package:location/location.dart';
@lazySingleton
class GpsService {
  final Location _location;

  GpsService() : _location = Location();

  Stream<LocationData>? _locationStream;

  // 1. Hàm để xin quyền và bật service
 Future<bool> _initialize() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }

  // === SỬA HÀM NÀY ===
  Future<LocationData?> getCurrentLocation() async {
    print("📡 [GpsService] Bắt đầu lấy vị trí...");
    try {
      final hasPermission = await _initialize();
      if (!hasPermission) {
        print("❌ [GpsService] Không có quyền GPS");
        return null;
      }

      print("📡 [GpsService] Đang đợi bản tin GPS đầu tiên...");
      final locationData = await _location.onLocationChanged.first.timeout(
        const Duration(seconds: 10), // Tăng lên 10s cho chắc
        onTimeout: () {
           throw Exception("Timeout: GPS không phản hồi sau 10s");
        },
      );
      
      print("✅ [GpsService] Đã lấy được: ${locationData.latitude}, ${locationData.longitude}");
      return locationData;

    } catch (e) {
      print("⚠️ [GpsService] Lỗi: $e");
      return null; // Trả về null để BLoC dùng fallback
    }
  }

  // 2. Hàm để bắt đầu theo dõi GPS (trả về 1 Stream)
  Stream<LocationData> getLocationStream() {
    // Chỉ khởi tạo stream nếu nó chưa tồn tại
    _locationStream ??= _location.onLocationChanged;
    return _locationStream!;
  }

  // 4. (Sau này dùng) Hàm để dừng theo dõi (ví dụ: khi app bị đóng)
  // (Chúng ta sẽ dùng Stream.cancel() ở BLoC nên hàm này có thể ko cần)
  void stopLocationStream() {
    _locationStream = null;
    // (Tùy chọn) Tắt chế độ chạy ngầm
    // _location.enableBackgroundMode(enable: false);
  }
}