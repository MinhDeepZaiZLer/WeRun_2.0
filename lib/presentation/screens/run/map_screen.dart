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
    // QUAN TRỌNG: Tìm BLoC đã được tạo bởi RunScreen
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

  void _updateRoute(List<LatLng> routePoints) {
    if (_mapController == null || !_isStyleLoaded) return;

    Map<String, dynamic> geoJsonCollection;

    if (routePoints.isEmpty) {
      geoJsonCollection = {
        'type': 'FeatureCollection',
        'features': []
      };
    } else if (routePoints.length == 1) {
      final point = routePoints.first;
      geoJsonCollection = {
        'type': 'FeatureCollection',
        'features': [
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
      geoJsonCollection = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates': routePoints
                  .map((p) => [p.longitude, p.latitude])
                  .toList(),
            }
          }
        ]
      };
    }
    
    _mapController?.setGeoJsonSource("route-source", geoJsonCollection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RunColors.lightGray,
      body: BlocConsumer<RunBloc, RunState>(
        listener: (context, state) {
          // Cập nhật route và camera khi đang chạy
          if (state is RunInProgress && 
              state.route.isNotEmpty && 
              _isStyleLoaded) {
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
          
          // Tự động pop khi discard hoặc finish
          if (state is RunInitial || state is RunFinished) {
            if (ModalRoute.of(context)?.isCurrent ?? false) {
              context.go('/home');
            }
          }
          
          // Hiển thị lỗi
          if (state is RunFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final data = RunHelpers.getRunData(state);
          
          return Stack(
            children: [
              // Map
              _buildMap(context),
              
              // Top overlay với stats
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        RunDistanceDisplay(
                          distanceKm: data.distanceKm,
                          fontSize: 60, // Nhỏ hơn để fit với MapScreen
                        ),
                        const SizedBox(height: 24),
                        RunStatsInfo(
                          data: data,
                          iconSize: 20, // Nhỏ hơn để fit
                          valueSize: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom action buttons
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
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
      onStyleLoadedCallback: () async {
        if (_mapController == null) return;
        
        // Tạo source và layer cho route
        final Map<String, dynamic> emptyGeoJson = {
          'type': 'FeatureCollection',
          'features': []
        };

        await _mapController?.addSource(
          "route-source",
          GeojsonSourceProperties(data: emptyGeoJson),
        );
        
        await _mapController?.addLayer(
          "route-layer",
          "route-source",
          const LineLayerProperties(
            lineColor: "#FF4081",
            lineWidth: 5.0,
            lineOpacity: 0.8,
          ),
        );
        
        setState(() {
          _isStyleLoaded = true;
        });
        
        // Cập nhật route nếu đã có
        final currentState = context.read<RunBloc>().state;
        if (currentState is RunInProgress && currentState.route.isNotEmpty) {
          final routeLatLng = currentState.route
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
          _updateRoute(routeLatLng);
        }
      },
    );
  }
}

/// Widget chứa các nút action cho Map (Back, Play/Pause, Reset, Stop)
class _MapActionButtons extends StatelessWidget {
  final RunData data;

  const _MapActionButtons({required this.data});

  @override
  Widget build(BuildContext context) {
    final runBloc = context.read<RunBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Nút Quay về
        RunCircularButton(
        onPressed: () => context.pop(),
          icon: Icons.arrow_back,
          size: 70,
          iconSize: 24,
          isOutlined: true,
        ),

        // Nút Start/Pause/Resume
        RunCircularButton(
          onPressed: () {
            if (data.isRunning) {
              runBloc.add(PauseRun());
            } else {
              if (data.hasRoute) {
                runBloc.add(ResumeRun());
              } else {
                runBloc.add(StartRun()); // Cho phép Start từ MapScreen
              }
            }
          },
          icon: data.isRunning ? Icons.pause : Icons.play_arrow,
          backgroundColor: data.isRunning ? Colors.red : RunColors.lightGreen,
          iconColor: data.isRunning ? Colors.white : RunColors.textBlack,
          size: 90,
          iconSize: 40,
        ),

        // Nút Reset
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

        // Nút Stop
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