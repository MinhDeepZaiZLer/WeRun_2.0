import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:location/location.dart';

import 'package:dacs4_werun_2_0/core/di/injection.dart';
import '../../../../data/services/gps_service.dart';
import 'bloc/run_bloc.dart';
import 'widgets/run_components.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapView();
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapLibreMapController? _mapController;
  final String _maptilerStyleUrl = "https://api.maptiler.com/maps/basic-v2/style.json?key=J61Qnzu5FaqnGm9Z6yPo";
  
  bool _isStyleLoaded = false;
  late Future<LocationData?> _initialLocationFuture;
  
  // Các object vẽ
  Line? _aiRouteLine;
  Line? _userRouteLine;

  @override
  void initState() {
    super.initState();
    _initialLocationFuture = getIt<GpsService>().getCurrentLocation();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  // Vẽ đường AI (Màu xanh)
  Future<void> _drawAiRoute(List<LatLng> points) async {
    print("🎨 [MAP] Vẽ AI: ${points.length} điểm");
    if (_mapController == null || points.isEmpty) return;
    
    if (_aiRouteLine != null) await _mapController?.removeLine(_aiRouteLine!);
    
    _aiRouteLine = await _mapController?.addLine(LineOptions(
        geometry: points,
        lineColor: "#00AAFF", lineWidth: 6.0, lineOpacity: 0.8,
    ));
    
    // Zoom vào đường AI
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(points.first, 14.5));
  }

  // Vẽ đường User (Màu hồng)
  Future<void> _drawUserRoute(List<LatLng> points) async {
    if (_mapController == null || points.isEmpty) return;
    
    if (_userRouteLine != null) {
       await _mapController?.updateLine(_userRouteLine!, LineOptions(geometry: points));
    } else {
       _userRouteLine = await _mapController?.addLine(LineOptions(
          geometry: points, lineColor: "#FF4081", lineWidth: 6.0, lineOpacity: 1.0
       ));
    }
    _mapController?.animateCamera(CameraUpdate.newLatLng(points.last));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RunColors.lightGray,
      body: BlocConsumer<RunBloc, RunState>(
        listener: (context, state) {
          // 1. Lắng nghe kết quả AI (Khi loading = false và có route)
          if (state is RunInitial && !state.isLoadingAi && state.suggestedRoute != null) {
             print("👂 [BLoC] Nhận được đường AI! Đang vẽ...");
             if (_isStyleLoaded) _drawAiRoute(state.suggestedRoute!.routePoints);
          }

          // 2. Lắng nghe đường User
          if (state is RunInProgress && state.route.isNotEmpty && _isStyleLoaded) {
             _drawUserRoute(state.route.map((p) => LatLng(p.latitude, p.longitude)).toList());
             
             // Vẽ lại đường AI nếu bị mất
             if (state.suggestedRoute != null && _aiRouteLine == null) {
               _drawAiRoute(state.suggestedRoute!.routePoints);
             }
          }

          // 3. Thoát
          if (state is RunInitial && state.suggestedRoute == null && !state.isLoadingAi) {
             if (ModalRoute.of(context)?.isCurrent ?? false) context.go('/home');
          }
        },
        builder: (context, state) {
          final data = RunHelpers.getRunData(state);
          
          return Stack(
            children: [
              FutureBuilder<LocationData?>(
                future: _initialLocationFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  return MapLibreMap(
                    styleString: _maptilerStyleUrl,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(snapshot.data!.latitude!, snapshot.data!.longitude!),
                      zoom: 15.0,
                    ),
                    myLocationEnabled: true,
                    trackCameraPosition: true,
                    onStyleLoadedCallback: () {
                      print("👉 [MAP] Style Loaded.");
                      setState(() => _isStyleLoaded = true);
                      
                      // Vẽ lại nếu đã có data
                      final currentState = context.read<RunBloc>().state;
                      if (currentState.suggestedRoute != null) {
                         _drawAiRoute(currentState.suggestedRoute!.routePoints);
                      }
                    },
                  );
                }
              ),

              // === UI HIỂN THỊ LOADING AI ===
              if (state is RunInitial && state.isLoadingAi)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text("AI đang tìm đường chạy...", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

              // UI Stats & Buttons (Chỉ hiện khi không loading)
              if (!(state is RunInitial && state.isLoadingAi)) ...[
                 Positioned(
                    top: 0, left: 0, right: 0,
                    child: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: RunDistanceDisplay(distanceKm: data.distanceKm, fontSize: 60))),
                 ),
                 Positioned(
                    bottom: 30, left: 0, right: 0,
                    child: _MapActionButtons(data: data),
                 ),
              ]
            ],
          );
        },
      ),
    );
  }
}

// (_MapActionButtons giữ nguyên)
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