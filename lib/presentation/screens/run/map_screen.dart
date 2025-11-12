// lib/presentation/screens/run/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart'; // <-- Dùng MapLibre

import 'bloc/run_bloc.dart';

// Import các màu từ RunScreen
import 'run_screen.dart' show lightGreen, textBlack, chipBackground; 

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // RẤT QUAN TRỌNG:
    // Chúng ta KHÔNG tạo BLoC mới,
    // mà "tìm" BLoC đã được tạo bởi RunScreen.
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
  MapLibreMapController? _mapController;
  
  // 1. XÓA BIẾN _mapboxPublicToken
  // final String _mapboxPublicToken = "pk.YOUR_PUBLIC_KEY_HERE"; 
  
  // 2. TẠO BIẾN CHỨA URL CỦA MAPTILER
  // !! Dán KEY MIỄN PHÍ của bạn vào đây !!
  final String _maptilerStyleUrl = 
        "https://api.maptiler.com/maps/base-v4/style.json?key=J61Qnzu5FaqnGm9Z6yPo";
        
        
  // (Bạn cũng có thể dùng style "streets":
  // final String _maptilerStyleUrl = 
  //       "https://api.maptiler.com/maps/streets-v2/style.json?key=YOUR_FREE_MAPTILER_KEY_HERE";

  bool _hasInitialZoom = false;
  bool _isStyleLoaded = false;


  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  // Hàm cập nhật đường vẽ (giống file Kotlin)
 void _updateRoute(List<LatLng> routePoints) {
    if (_mapController == null || !_isStyleLoaded) return; 

    Map<String, dynamic> geoJsonCollection; // Phải là Collection

    if (routePoints.isEmpty) {
      // Trường hợp 1: Rỗng -> Gửi Collection rỗng
      geoJsonCollection = {
        'type': 'FeatureCollection',
        'features': []
      };
    } else if (routePoints.length == 1) {
      // Trường hợp 2: 1 điểm -> Gửi Collection chứa 1 Point
      final point = routePoints.first;
      geoJsonCollection = {
        'type': 'FeatureCollection',
        'features': [ // Bọc trong 1 list
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point', 
              'coordinates': [point.longitude, point.latitude]
            }
          }
        ]
      };
    } else {
      // Trường hợp 3: 2+ điểm -> Gửi Collection chứa 1 LineString
      geoJsonCollection = {
        'type': 'FeatureCollection',
        'features': [ // Bọc trong 1 list
          {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates': routePoints.map((p) => [p.longitude, p.latitude]).toList(),
            }
          }
        ]
      };
    }
    
    // Cập nhật source
    _mapController?.setGeoJsonSource("route-source", geoJsonCollection);
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RunBloc, RunState>(
        listener: (context, state) {
          if (state is RunInProgress && state.route.isNotEmpty && _isStyleLoaded) {
            final routeLatLng = state.route
                .map((p) => LatLng(p.latitude, p.longitude))
                .toList();
            _updateRoute(routeLatLng); 

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
            MapLibreMap( 
             styleString: _maptilerStyleUrl,
             
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(10.762622, 106.660172), 
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.trackingGps, 
              trackCameraPosition: true,
              
              // === SỬA HÀM NÀY ===
              onStyleLoadedCallback: () async {
                if (_mapController == null) return;
                
                // 1. Tạo một FeatureCollection RỖNG
                final Map<String, dynamic> emptyGeoJsonCollection = {
                  'type': 'FeatureCollection',
                  'features': []
                };

                // 2. Thêm source (an toàn)
                await _mapController?.addSource(
                  "route-source",
                  GeojsonSourceProperties(data: emptyGeoJsonCollection), 
                );
                
                // 3. Thêm layer
                await _mapController?.addLayer(
                  "route-layer",
                  "route-source",
                  const LineLayerProperties(
                    lineColor: "#FF4081",
                    lineWidth: 5.0,
                    lineOpacity: 0.8,
                  ),
                );
                
                // 4. Báo rằng style đã sẵn sàng
                setState(() {
                  _isStyleLoaded = true;
                });
                
                // 5. Vẽ đường ngay nếu BLoC đã có data
                final currentState = context.read<RunBloc>().state;
                if (currentState is RunInProgress && currentState.route.isNotEmpty) {
                   final routeLatLng = currentState.route
                      .map((p) => LatLng(p.latitude, p.longitude))
                      .toList();
                   _updateRoute(routeLatLng);
                }
              },
            ),

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
  Widget _buildMapActionButtons(BuildContext context) {
    final runBloc = context.watch<RunBloc>();
    final state = runBloc.state;

    bool isRunning = false;
    bool hasRoute = false;

    if (state is RunInProgress) {
      isRunning = !state.isPaused;
      hasRoute = state.route.isNotEmpty;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

        // Nút Reset (Thêm từ file Kotlin)
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