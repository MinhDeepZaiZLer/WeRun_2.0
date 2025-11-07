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

    // Kiểm tra xem service vị trí có bật không
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false; // Người dùng không bật service
      }
    }

    // Kiểm tra quyền (permission)
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false; // Người dùng không cấp quyền
      }
    }
    
    // (Tùy chọn) Bật chế độ chạy ngầm (nếu bạn đã cấu hình)
    // await _location.enableBackgroundMode(enable: true);

    return true; // Sẵn sàng
  }

  // 2. Hàm để bắt đầu theo dõi GPS (trả về 1 Stream)
  Stream<LocationData> getLocationStream() {
    // Chỉ khởi tạo stream nếu nó chưa tồn tại
    _locationStream ??= _location.onLocationChanged;
    return _locationStream!;
  }

  // 3. Hàm (gọi 1 lần) để lấy vị trí hiện tại
  Future<LocationData?> getCurrentLocation() async {
    final hasPermission = await _initialize();
    if (!hasPermission) {
      return null;
    }
    return await _location.getLocation();
  }

  // 4. (Sau này dùng) Hàm để dừng theo dõi (ví dụ: khi app bị đóng)
  // (Chúng ta sẽ dùng Stream.cancel() ở BLoC nên hàm này có thể ko cần)
  void stopLocationStream() {
    _locationStream = null;
    // (Tùy chọn) Tắt chế độ chạy ngầm
    // _location.enableBackgroundMode(enable: false);
  }
}