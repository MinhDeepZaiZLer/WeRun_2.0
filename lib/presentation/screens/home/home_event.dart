// lib/presentation/screens/home/home_event.dart
part of 'home_bloc.dart';



@immutable
abstract class HomeEvent {}

// Event được gọi khi màn hình Home được tải lần đầu
class LoadHomeData extends HomeEvent {}

// Event được gọi khi người dùng bấm "START"
class StartRun extends HomeEvent {}

// Event được gọi khi người dùng bấm "Settings"
class OpenSettings extends HomeEvent {}

// Event được gọi khi người dùng bấm "Music"
class OpenMusic extends HomeEvent {}

// Event được gọi để làm mới thời tiết (có thể gọi tự động)
class RefreshWeather extends HomeEvent {}