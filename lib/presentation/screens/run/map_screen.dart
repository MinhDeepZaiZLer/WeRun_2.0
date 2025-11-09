// lib/presentation/screens/run/map_screen.dart
// import 'dart:async'; // <- Lỗi 5: Đã xóa (không dùng)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart'; // <-- Đã dùng gói mới

import 'bloc/run_bloc.dart';
// Import các màu (đã xóa textGray không dùng)
import 'run_screen.dart' show lightGreen, textBlack, chipBackground; 

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // "Dùng ké" BLoC từ RunScreen
    return BlocProvider.value(
      value: BlocProvider.of<RunBloc>(context),
      child: const MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // Lỗi 8: Sửa Case Sensitivity
  MapLibreMapController? _mapController; 
  bool _hasInitialZoom = false;

  // Lỗi 8: Sửa Case Sensitivity
  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  // Hàm cập nhật đường vẽ (giống file Kotlin)
  void _updateRoute(List<LatLng> routePoints) {
    _mapController?.setGeoJsonSource(
      "route-source",
      {
        'type': 'Feature',
        'geometry': {
          'type': 'LineString',
          'coordinates': routePoints.map((p) => [p.longitude, p.latitude]).toList(),
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RunBloc, RunState>(
        listener: (context, state) {
          if (state is RunInProgress && state.route.isNotEmpty) {
            final routeLatLng = state.route
                .map((p) => LatLng(p.latitude, p.longitude))
                .toList();
            _updateRoute(routeLatLng); // Vẽ đường

            // Di chuyển camera
            final latestPoint = routeLatLng.last;
            if (!_hasInitialZoom) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(latestPoint, 18.0),
              );
              _hasInitialZoom = true;
            } else {
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(latestPoint),
              );
            }
          }
        },
        child: Stack(
          children: [
            // === BẢN ĐỒ MAPLIBRE ===
            // Lỗi 9: Sửa Case Sensitivity
            MapLibreMap( 
              // Lỗi 1: Xóa 'accessToken' (không cần cho style miễn phí)
              
              // Lỗi 2 & 10: Sửa tên Style và Case
              styleString: "https://demotiles.maplibre.org/style.json",

              
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(10.762622, 106.660172), 
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              
              // Lỗi 3: Sửa tên Enum
              myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS, 
              
              trackCameraPosition: true,
              onStyleLoadedCallback: () {
                _mapController?.addSource(
                  "route-source",
                  const GeojsonSourceProperties(data: {
                    'type': 'Feature',
                    'geometry': {'type': 'LineString', 'coordinates': []}
                  }),
                );
                _mapController?.addLayer(
                  "route-layer",
                  "route-source",
                  const LineLayerProperties(
                    lineColor: "#FF4081",
                    lineWidth: 5.0,
                    lineOpacity: 0.8,
                  ),
                );
              },
            ),

            // === CÁC NÚT ĐIỀU KHIỂN ===
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: _buildMapActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  // Dịch lại UI MapActionButtons từ file Kotlin
  Widget _buildMapActionButtons(BuildContext context) {
    final runBloc = context.watch<RunBloc>();
    final state = runBloc.state;

    bool isRunning = false;
    bool hasRoute = false; // Lỗi 7: Sửa lỗi (biến này sẽ được dùng)

    if (state is RunInProgress) {
      isRunning = !state.isPaused;
      hasRoute = state.route.isNotEmpty;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // Lỗi 4: Sửa 'verticalAlignment' -> 'crossAxisAlignment'
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        // Nút Quay về (Giống Kotlin)
        OutlinedButton(
          onPressed: () => context.pop(), // Dùng GoRouter
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            side: const BorderSide(color: lightGreen, width: 2),
            padding: const EdgeInsets.all(0),
            fixedSize: const Size(70, 70),
            backgroundColor: chipBackground,
          ),
          child: const Icon(Icons.arrow_back, color: textBlack, size: 24),
        ),

        // Nút Start/Pause (Giống Kotlin)
        ElevatedButton(
          onPressed: () {
            if (isRunning) {
              runBloc.add(PauseRun());
            } else {
              // Ở màn map, không thể Start, chỉ có thể Resume
              if (hasRoute) { 
                runBloc.add(ResumeRun());
              }
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: isRunning ? Colors.red : lightGreen,
            fixedSize: const Size(90, 90),
          ),
          child: Icon(
            isRunning ? Icons.pause : Icons.play_arrow,
            color: isRunning ? Colors.white : textBlack,
            size: 40,
          ),
        ),

        // Nút Reset (Thêm từ file Kotlin, sử dụng 'hasRoute')
        OutlinedButton(
          onPressed: () {
            // Chỉ reset khi đang tạm dừng và có đường chạy
            if (hasRoute && !isRunning) {
              runBloc.add(DiscardRun());
            }
          },
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            side: BorderSide(color: (hasRoute && !isRunning) ? lightGreen : Colors.grey, width: 2),
            padding: const EdgeInsets.all(0),
            fixedSize: const Size(70, 70),
            backgroundColor: chipBackground,
          ),
          child: Icon(
            Icons.refresh, 
            color: (hasRoute && !isRunning) ? textBlack : Colors.grey, 
            size: 24
          ),
        ),

        // Nút Stop (Giống Kotlin, nhưng gọi Dialog từ RunScreen)
        ElevatedButton(
          onPressed: () {
            // Chỉ quay về, RunScreen sẽ xử lý dialog
            context.pop(); 
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.grey,
            fixedSize: const Size(70, 70),
          ),
          child: const Icon(Icons.stop, color: Colors.white, size: 28),
        ),
      ],
    );
  }
}