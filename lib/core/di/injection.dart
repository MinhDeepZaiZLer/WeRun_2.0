import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import file này (sẽ được tạo ra ở Bước 3)
import 'injection.config.dart'; 

final getIt = GetIt.instance; // Biến global để truy cập

@InjectableInit(
  initializerName: 'init', // Tên hàm khởi tạo
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async => init(getIt);