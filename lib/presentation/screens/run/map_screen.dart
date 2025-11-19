// lib/presentation/screens/run/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:location/location.dart'; // Import LocationData

// Import các file nội bộ
import 'package:dacs4_werun_2_0/core/di/injection.dart';
import '../../../../data/services/gps_service.dart';
import 'bloc/run_bloc.dart';
import 'widgets/run_components.dart';
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
  
  final String _maptilerStyleUrl = 
      "https://api.maptiler.com/maps/base-v4/style.json?key=J61Qnzu5FaqnGm9Z6yPo";
      
  bool _hasInitialZoom = false;
  bool _isStyleLoaded = false;
  
  // Cache để tránh vẽ lại không cần thiết
  List<LatLng>? _lastUserRoute;
  List<LatLng>? _lastAiRoute;
  late Future<LocationData?> _initialLocationFuture;

  @override
  void initState() {
    super.initState();
    // Gọi GpsService để lấy vị trí ngay khi mở màn hình
    _initialLocationFuture = getIt<GpsService>().getCurrentLocation();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }
 

  // Cập nhật đường User (Màu hồng - liền nét)
// Trong file lib/presentation/screens/run/map_screen.dart


  // Cập nhật đường AI (Màu xanh - đứt nét)
  

  void _updateGeoJsonSource(String sourceId, List<LatLng> points) {
    if (_mapController == null || !_isStyleLoaded) return;
    
    Map<String, dynamic> geoJsonCollection;
    if (points.isEmpty) {
      geoJsonCollection = {'type': 'FeatureCollection', 'features': []};
    } else if (points.length == 1) {
      final point = points.first;
      geoJsonCollection = {
        'type': 'FeatureCollection', 'features': [{
          'type': 'Feature', 'geometry': {'type': 'Point', 'coordinates': [point.longitude, point.latitude]}
        }]
      };
    } else {
      geoJsonCollection = {
        'type': 'FeatureCollection', 'features': [{
          'type': 'Feature', 'geometry': {
            'type': 'LineString', 
            'coordinates': points.map((p) => [p.longitude, p.latitude]).toList()
          }
        }]
      };
    }
    _mapController?.setGeoJsonSource(sourceId, geoJsonCollection);
  }
  void _updateAiRoute(List<LatLng> points) => _updateGeoJsonSource("ai-route-source", points);
  void _updateRoute(List<LatLng> points) => _updateGeoJsonSource("route-source", points);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RunColors.lightGray,
      // Dùng FutureBuilder để chờ vị trí
      body: FutureBuilder<LocationData?>(
        future: _initialLocationFuture,
        builder: (context, snapshot) {
          
          // 1. Đang lấy vị trí -> Hiện Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: RunColors.lightGreen),
                  SizedBox(height: 16),
                  Text("Đang tìm vị trí của bạn..."),
                ],
              ),
            );
          }

          // 2. Đã có kết quả (hoặc null/error) -> Hiển thị Map
          // Lấy tọa độ từ snapshot, nếu lỗi thì dùng mặc định (Đà Nẵng)
          final initialLat = snapshot.data?.latitude ?? 15.977;
          final initialLng = snapshot.data?.longitude ?? 108.257;

          return BlocConsumer<RunBloc, RunState>(
            listener: (context, state) {
              if (!_isStyleLoaded) return;

              // 1. Vẽ đường AI
              if (state.suggestedRoute != null) {
                 _updateAiRoute(state.suggestedRoute!.routePoints);
              }

              // 2. Vẽ đường User & Camera follow
              if (state is RunInProgress && state.route.isNotEmpty) {
                final points = state.route.map((p) => LatLng(p.latitude, p.longitude)).toList();
                _updateRoute(points);
                
                // Camera luôn bám theo điểm mới nhất
                _mapController?.animateCamera(CameraUpdate.newLatLng(points.last));
              }
              
              // 3. Thoát
              if (state is RunInitial && state.suggestedRoute == null) {
                if (ModalRoute.of(context)?.isCurrent ?? false) context.go('/home');
              }
            },
            builder: (context, state) {
              final data = RunHelpers.getRunData(state);
              return Stack(
                children: [
                  // Truyền tọa độ khởi tạo vào _buildMap
                  _buildMap(context, LatLng(initialLat, initialLng)),
                  
                  // Top Overlay
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            RunDistanceDisplay(distanceKm: data.distanceKm, fontSize: 60),
                            const SizedBox(height: 24),
                            RunStatsInfo(data: data, iconSize: 20, valueSize: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom Action Buttons
                  Positioned(
                    bottom: 30, left: 0, right: 0,
                    child: _MapActionButtons(data: data),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMap(BuildContext context, LatLng initialPos) {
    return MapLibreMap(
      styleString: _maptilerStyleUrl,
      onMapCreated: _onMapCreated,
      
      // === INIT TẠI VỊ TRÍ CỦA BẠN ===
      initialCameraPosition: CameraPosition(
        target: initialPos, // Dùng tọa độ vừa lấy được từ FutureBuilder
        zoom: 15.0,
      ),
      
      myLocationEnabled: true,
      myLocationTrackingMode: MyLocationTrackingMode.trackingGps,
      trackCameraPosition: true,
      
      onStyleLoadedCallback: () async {
        if (_mapController == null) return;

        final Map<String, dynamic> emptyGeoJson = {'type': 'FeatureCollection', 'features': []};

        // Layer AI (Xanh)
       await _mapController?.addSource("ai-route-source", GeojsonSourceProperties(data: emptyGeoJson));
        await _mapController?.addLayer("ai-route-layer", "ai-route-source", 
          const LineLayerProperties(lineColor: "#00AAFF", lineWidth: 5.0, lineOpacity: 0.7));

        // 2. Layer User (Màu Hồng - ĐƯỜNG KẺ) - Giữ nguyên
        await _mapController?.addSource("route-source", GeojsonSourceProperties(data: emptyGeoJson));
        await _mapController?.addLayer("route-layer", "route-source", 
          const LineLayerProperties(lineColor: "#FF4081", lineWidth: 5.0, lineOpacity: 0.9));
        
        // === 3. THÊM LAYER MỚI: CHẤM TRÒN (CIRCLE) ===
        // Layer này giúp hiển thị vị trí ngay cả khi chưa có đường kẻ
        await _mapController?.addLayer(
            "route-circle-layer", 
            "route-source", // Dùng chung source với đường kẻ
            const CircleLayerProperties(
              circleColor: "#FF4081", // Cùng màu hồng
              circleRadius: 6.0,      // Kích thước chấm
              circleStrokeWidth: 2.0, 
              circleStrokeColor: "#FFFFFF" // Viền trắng cho nổi
            )
        );
        setState(() => _isStyleLoaded = true);

        // Kiểm tra state để vẽ ngay
        final state = context.read<RunBloc>().state;
        
        // A. Có đường AI -> Vẽ và Zoom vào đường AI (ưu tiên xem đường gợi ý)
        if (state.suggestedRoute != null) {
           final points = state.suggestedRoute!.routePoints;
           _updateAiRoute(points);
           
           if (points.isNotEmpty) {
             _mapController?.animateCamera(CameraUpdate.newLatLngZoom(points.first, 16.0));
           }
        }
        // B. Đang chạy -> Vẽ đường User
        else if (state is RunInProgress && state.route.isNotEmpty) {
          final points = state.route.map((p) => LatLng(p.latitude, p.longitude)).toList();
          _updateRoute(points);
        }
      },
    );
  }
}

class _MapActionButtons extends StatelessWidget {
  final RunData data;
  const _MapActionButtons({required this.data});

  @override
  Widget build(BuildContext context) {
    final runBloc = context.read<RunBloc>();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Back
        RunCircularButton(
          onPressed: () => context.pop(),
          icon: Icons.arrow_back,
          size: 70,
          iconSize: 24,
          isOutlined: true,
        ),
        
        // Play/Pause
        RunCircularButton(
          onPressed: () {
            if (data.isRunning) {
              runBloc.add(PauseRun());
            } else if (data.hasRoute) {
              runBloc.add(ResumeRun());
            } else {
              runBloc.add(StartRun());
            }
          },
          icon: data.isRunning ? Icons.pause : Icons.play_arrow,
          backgroundColor: data.isRunning 
              ? Colors.red 
              : RunColors.lightGreen,
          iconColor: data.isRunning 
              ? Colors.white 
              : RunColors.textBlack,
          size: 90,
          iconSize: 40,
        ),
        
        // Refresh
        RunCircularButton(
          onPressed: (data.hasRoute && !data.isRunning)
              ? () => runBloc.add(DiscardRun())
              : null,
          icon: Icons.refresh,
          size: 70,
          iconSize: 24,
          isOutlined: true,
          borderColor: (data.hasRoute && !data.isRunning)
              ? RunColors.lightGreen
              : Colors.grey,
          iconColor: (data.hasRoute && !data.isRunning)
              ? RunColors.textBlack
              : Colors.grey,
        ),
        
        // Stop
        RunCircularButton(
          onPressed: data.hasRoute
              ? () => _showStopDialog(context, runBloc)
              : () => context.pop(),
          icon: Icons.stop,
          backgroundColor: Colors.grey,
          iconColor: Colors.white,
          size: 70,
          iconSize: 28,
        ),
      ],
    );
  }

  void _showStopDialog(BuildContext context, RunBloc runBloc) {
    RunStopDialog.show(
      context: context,
      data: data,
      onDiscard: () => runBloc.add(DiscardRun()),
      onSave: () => runBloc.add(StopRun()),
    );
  }
}