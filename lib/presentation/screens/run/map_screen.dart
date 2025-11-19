// lib/presentation/screens/run/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

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

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  // Cập nhật đường User (Màu hồng)
  void _updateRoute(List<LatLng> routePoints) {
    if (_mapController == null || !_isStyleLoaded) return;
    _updateGeoJsonSource("route-source", routePoints);
  }

  // Cập nhật đường AI (Màu xanh)
  void _updateAiRoute(List<LatLng> routePoints) {
    if (_mapController == null || !_isStyleLoaded) return;
    _updateGeoJsonSource("ai-route-source", routePoints);
  }

  void _updateGeoJsonSource(String sourceId, List<LatLng> points) {
    Map<String, dynamic> geoJsonCollection;
    if (points.isEmpty) {
      geoJsonCollection = {'type': 'FeatureCollection', 'features': []};
    } else if (points.length == 1) {
      final point = points.first;
      geoJsonCollection = {
        'type': 'FeatureCollection',
        'features': [{'type': 'Feature', 'geometry': {'type': 'Point', 'coordinates': [point.longitude, point.latitude]}}]
      };
    } else {
      geoJsonCollection = {
        'type': 'FeatureCollection',
        'features': [{'type': 'Feature', 'geometry': {'type': 'LineString', 'coordinates': points.map((p) => [p.longitude, p.latitude]).toList()}}]
      };
    }
    _mapController?.setGeoJsonSource(sourceId, geoJsonCollection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RunColors.lightGray,
      body: BlocConsumer<RunBloc, RunState>(
        listener: (context, state) {
          if (!_isStyleLoaded) return;

          // 1. Khi NHẬN ĐƯỢC đường AI MỚI (State thay đổi)
          if (state is RunInitial && state.suggestedRoute != null) {
            _updateAiRoute(state.suggestedRoute!.routePoints);
            // Zoom ngay
            if (state.suggestedRoute!.routePoints.isNotEmpty) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(state.suggestedRoute!.routePoints.first, 16.0)
              );
            }
          }

          // 2. Khi đang chạy (Vẽ cả 2 đường)
          if (state is RunInProgress) {
            // Vẽ đường User
            if (state.route.isNotEmpty) {
              final routeLatLng = state.route.map((p) => LatLng(p.latitude, p.longitude)).toList();
              _updateRoute(routeLatLng);
              
              // Camera bám theo user
              if (!_hasInitialZoom) {
                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(routeLatLng.last, 18.0));
                _hasInitialZoom = true;
              } else {
                _mapController?.animateCamera(CameraUpdate.newLatLng(routeLatLng.last));
              }
            }
            // Vẽ lại đường AI (để không mất)
            if (state.suggestedRoute != null) {
              _updateAiRoute(state.suggestedRoute!.routePoints);
            }
          }

          // Thoát
          if (state is RunInitial || state is RunFinished) {
            if (ModalRoute.of(context)?.isCurrent ?? false) context.go('/home');
          }
        },
        builder: (context, state) {
          final data = RunHelpers.getRunData(state);
          return Stack(
            children: [
              _buildMap(context),
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
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return MapLibreMap(
      styleString: _maptilerStyleUrl,
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: LatLng(10.762622, 106.660172),
        zoom: 15.0,
      ),
      myLocationEnabled: true,
      myLocationTrackingMode: MyLocationTrackingMode.trackingGps,
      trackCameraPosition: true,
      
      // === QUAN TRỌNG: VẼ VÀ ZOOM NGAY KHI MAP LOAD XONG ===
      onStyleLoadedCallback: () async {
        if (_mapController == null) return;

        final Map<String, dynamic> emptyGeoJson = {'type': 'FeatureCollection', 'features': []};

        // 1. Layer AI (Màu Xanh - Vẽ trước để nằm dưới)
        await _mapController?.addSource("ai-route-source", GeojsonSourceProperties(data: emptyGeoJson));
        await _mapController?.addLayer("ai-route-layer", "ai-route-source", 
          const LineLayerProperties(lineColor: "#00AAFF", lineWidth: 5.0, lineOpacity: 0.7)); // Đậm hơn chút

        // 2. Layer User (Màu Hồng - Vẽ sau để nằm trên)
        await _mapController?.addSource("route-source", GeojsonSourceProperties(data: emptyGeoJson));
        await _mapController?.addLayer("route-layer", "route-source", 
          const LineLayerProperties(lineColor: "#FF4081", lineWidth: 5.0, lineOpacity: 0.9));
        
        setState(() => _isStyleLoaded = true);

        // 3. KIỂM TRA STATE VÀ VẼ NGAY
        final state = context.read<RunBloc>().state;
        
        // Trường hợp A: Có đường AI (từ màn hình trước)
        if (state.suggestedRoute != null) {
           final points = state.suggestedRoute!.routePoints;
           _updateAiRoute(points);
           
           // === THÊM DÒNG NÀY: ZOOM VÀO ĐƯỜNG AI NGAY ===
           if (points.isNotEmpty) {
             // Zoom vào điểm đầu tiên của đường AI
             _mapController?.animateCamera(CameraUpdate.newLatLngZoom(points.first, 16.0));
           }
        }

        // Trường hợp B: Đang chạy
        if (state is RunInProgress && state.route.isNotEmpty) {
          final points = state.route.map((p) => LatLng(p.latitude, p.longitude)).toList();
          _updateRoute(points);
        }
      },
    );
  }
}

// (Giữ nguyên _MapActionButtons của bạn, nó đã đúng)
class _MapActionButtons extends StatelessWidget {
  final RunData data;
  const _MapActionButtons({required this.data});
  @override
  Widget build(BuildContext context) {
    final runBloc = context.read<RunBloc>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RunCircularButton(
          onPressed: () => context.pop(),
          icon: Icons.arrow_back, size: 70, iconSize: 24, isOutlined: true,
        ),
        RunCircularButton(
          onPressed: () {
            if (data.isRunning) runBloc.add(PauseRun());
            else if (data.hasRoute) runBloc.add(ResumeRun());
            else runBloc.add(StartRun());
          },
          icon: data.isRunning ? Icons.pause : Icons.play_arrow,
          backgroundColor: data.isRunning ? Colors.red : RunColors.lightGreen,
          iconColor: data.isRunning ? Colors.white : RunColors.textBlack,
          size: 90, iconSize: 40,
        ),
        RunCircularButton(
          onPressed: (data.hasRoute && !data.isRunning) ? () => runBloc.add(DiscardRun()) : null,
          icon: Icons.refresh, size: 70, iconSize: 24, isOutlined: true,
          borderColor: (data.hasRoute && !data.isRunning) ? RunColors.lightGreen : Colors.grey,
          iconColor: (data.hasRoute && !data.isRunning) ? RunColors.textBlack : Colors.grey,
        ),
        RunCircularButton(
          onPressed: data.hasRoute ? () => _showStopDialog(context, runBloc) : () => context.pop(),
          icon: Icons.stop, backgroundColor: Colors.grey, iconColor: Colors.white, size: 70, iconSize: 28,
        ),
      ],
    );
  }
  
  void _showStopDialog(BuildContext context, RunBloc runBloc) {
    RunStopDialog.show(context: context, data: data, onDiscard: () => runBloc.add(DiscardRun()), onSave: () => runBloc.add(StopRun()));
  }
}