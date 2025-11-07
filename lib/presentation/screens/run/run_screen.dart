import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // <-- 1. THÊM import GoRouter

// 2. XÓA import 'package:maplibre_gl/maplibre_gl.dart'; (Không cần ở màn này)

// 3. THÊM import cho Event

// (Giả sử đường dẫn DI của bạn là đây)
import 'package:dacs4_werun_2_0/core/di/injection.dart'; 
import 'bloc/run_bloc.dart';

// Color palette
const Color lightGreen = Color(0xFFD0FD3E);
const Color lightGray = Color(0xFFF5F5F5);
const Color textBlack = Color(0xFF000000);
const Color textGray = Color(0xFF8A8A8E);
const Color chipBackground = Color(0xFFE8F5E9);

class RunScreen extends StatelessWidget {
 const RunScreen({super.key});

 @override
 Widget build(BuildContext context) {
  return BlocProvider(
   create: (context) => getIt<RunBloc>(),
   child: const RunView(),
  );
 }
}

class RunView extends StatefulWidget {
 const RunView({super.key});

 @override
 State<RunView> createState() => _RunViewState();
}

class _RunViewState extends State<RunView> {
  // 4. XÓA các biến/hàm liên quan đến bản đồ (vì chúng ở màn hình /map)
  // MapboxMapController? _mapController;
  // final String _mapboxPublicToken = "pk.YOUR_PUBLIC_KEY_HERE";
  // bool _showSaveDialog = false;
  // void _onMapCreated(MapboxMapController controller) { ... }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   backgroundColor: lightGray,
   body: BlocConsumer<RunBloc, RunState>(
    listener: (context, state) {
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
     return SafeArea(
      child: Padding(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
       child: Column(
        children: [
         _buildTopStatusBar(state),
         const SizedBox(height: 48),
         _buildDistanceDisplay(state),
         const SizedBox(height: 32),
         _buildStatsInfo(state),
         const SizedBox(height: 24),
         _buildMusicPlayer(),
         const Spacer(),
                // 5. SỬA: Truyền context vào
         _buildActionButtons(context, state), 
        ],
       ),
      ),
     );
    },
   ),
  );
 }

  // ... (Toàn bộ code _buildTopStatusBar, _buildStatusChip, _buildDistanceDisplay, 
  //     _buildStatsInfo, _buildStatItem, _buildMusicPlayer 
  //     GIỮ NGUYÊN - BẠN ĐÃ LÀM RẤT TỐT) ...

  // Widget _buildMusicPlayer() { ... }
  // Top Status Bar with Weather and GPS

  Widget _buildTopStatusBar(RunState state) {

    return Row(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [

        _buildStatusChip(Icons.wb_sunny, "25°C"),

        // Progress indicator

        Container(

          height: 8,

          width: 60,

          decoration: BoxDecoration(

            color: chipBackground,

            borderRadius: BorderRadius.circular(4),

          ),

          child: Row(

            children: [

              Expanded(

                flex: 4,

                child: Container(

                  decoration: const BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.only(

                      topLeft: Radius.circular(4),

                      bottomLeft: Radius.circular(4),

                    ),

                  ),

                ),

              ),

              Expanded(flex: 6, child: Container(color: lightGreen)),

            ],

          ),

        ),

        _buildStatusChip(Icons.gps_fixed, "GPS"),

      ],

    );

  }



  Widget _buildStatusChip(IconData icon, String text) {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(

        color: chipBackground,

        borderRadius: BorderRadius.circular(16),

      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(icon, color: textGray, size: 18),

          const SizedBox(width: 6),

          Text(text, style: const TextStyle(color: textBlack, fontSize: 14)),

        ],

      ),

    );

  }



  // Distance Display

  Widget _buildDistanceDisplay(RunState state) {

    double distance = 0.0;

    if (state is RunInProgress) {

      distance = state.distanceMeters / 1000;

    }



    return Column(

      children: [

        Text(

          distance.toStringAsFixed(2),

          style: const TextStyle(

            fontSize: 80,

            fontWeight: FontWeight.bold,

            color: textBlack,

          ),

        ),

        const Text(

          "Distance (Km)",

          style: TextStyle(fontSize: 16, color: textGray),

        ),

      ],

    );

  }



  // Stats Info (Pace, Duration, Calories)

  Widget _buildStatsInfo(RunState state) {

    String duration = "00:00";

    double distance = 0.0;

    String pace = "0'00\"";

    int calories = 0;



    if (state is RunInProgress) {

      distance = state.distanceMeters;

      duration = _formatDuration(state.elapsedSeconds);

      pace = _calculatePace(state.elapsedSeconds, distance);

      calories = _calculateCalories(distance);

    }



    return Row(

      mainAxisAlignment: MainAxisAlignment.spaceAround,

      children: [

        _buildStatItem(Icons.directions_run, pace, "Avg Pace"),

        _buildStatItem(Icons.timer, duration, "Duration"),

        _buildStatItem(

          Icons.local_fire_department,

          "$calories kcal",

          "Calories",

        ),

      ],

    );

  }



  Widget _buildStatItem(IconData icon, String value, String label) {

    return Column(

      children: [

        Icon(icon, color: textGray, size: 24),

        const SizedBox(height: 8),

        Text(

          value,

          style: const TextStyle(

            fontSize: 20,

            fontWeight: FontWeight.w600,

            color: textBlack,

          ),

        ),

        Text(label, style: const TextStyle(fontSize: 12, color: textGray)),

      ],

    );

  }



  // Enhanced Music Player (Placeholder)

  Widget _buildMusicPlayer() {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: lightGreen,

        borderRadius: BorderRadius.circular(16),

      ),

      child: Row(

        children: [

          Container(

            width: 48,

            height: 48,

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(8),

            ),

            child: const Icon(Icons.music_note, color: textBlack),

          ),

          const SizedBox(width: 12),

          const Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  "No music playing",

                  style: TextStyle(

                    fontWeight: FontWeight.w600,

                    color: textBlack,

                  ),

                ),

                Text(

                  "Tap to select music",

                  style: TextStyle(fontSize: 12, color: textGray),

                ),

              ],

            ),

          ),

          IconButton(

            icon: const Icon(Icons.play_arrow, color: textBlack),

            onPressed: () {

              print("Music control clicked");

            },

          ),

        ],

      ),

    );

  }


 // Action Buttons (Đã sửa lỗi điều hướng)
 Widget _buildActionButtons(BuildContext context, RunState state) { // 5. SỬA: Nhận context
  bool isTracking = false;
  bool hasRoute = false;

  if (state is RunInProgress) {
   isTracking = !state.isPaused;
   hasRoute = true;
  }

  return Row(
   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
   children: [
    // Map Button
    OutlinedButton(
     onPressed: () {
            // 6. SỬA LỖI ĐIỀU HƯỚNG
      context.go('/map'); // Dùng GoRouter
     },
     style: OutlinedButton.styleFrom(
      shape: const CircleBorder(),
      side: const BorderSide(color: lightGreen, width: 2),
      padding: const EdgeInsets.all(20),
      fixedSize: const Size(80, 80),
     ),
     child: const Icon(Icons.map_outlined, color: textBlack, size: 36),
    ),

    // Start/Pause Button (Giữ nguyên, code của bạn đã đúng)
    ElevatedButton(
     onPressed: () {
      if (isTracking) {
       context.read<RunBloc>().add(PauseRun());
      } else {
       if (hasRoute) {
        context.read<RunBloc>().add(ResumeRun());
       } else {
        context.read<RunBloc>().add(StartRun());
       }
      }
     },
     style: ElevatedButton.styleFrom(
      shape: const CircleBorder(),
      backgroundColor: isTracking ? Colors.red : lightGreen,
      padding: const EdgeInsets.all(30),
      fixedSize: const Size(100, 100),
     ),
     child: Text(
      isTracking ? "PAUSE" : (hasRoute ? "RESUME" : "START"),
      style: TextStyle(
       color: isTracking ? Colors.white : textBlack,
       fontSize: 13,
       fontWeight: FontWeight.bold,
      ),
     ),
    ),

    // Stop Button (Giữ nguyên)
    if (hasRoute)
     ElevatedButton(
      onPressed: () {
              // 7. SỬA: Phải truyền context vào
       _showStopDialog(context, state); 
      },
      style: ElevatedButton.styleFrom(
       shape: const CircleBorder(),
       backgroundColor: Colors.grey,
       padding: const EdgeInsets.all(20),
       fixedSize: const Size(80, 80),
      ),
      child: const Icon(Icons.stop, color: Colors.white, size: 32),
     )
    else
     const SizedBox(width: 80), // Giữ chỗ
   ],
  );
 }

 // Show Stop Dialog (Sửa lỗi điều hướng)
 void _showStopDialog(BuildContext blocContext, RunState state) { // 7. SỬA: Nhận BLoC context
  if (state is! RunInProgress) return;

  showDialog(
   context: blocContext, // Dùng BLoC context để show
   builder: (BuildContext dialogContext) { // Context mới chỉ của Dialog
    return AlertDialog(
     title: const Text("Save Run?"),
     content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Text(
        "Distance: ${(state.distanceMeters / 1000).toStringAsFixed(2)} km",
       ),
       Text("Duration: ${_formatDuration(state.elapsedSeconds)}"),
       const SizedBox(height: 8),
       const Text("Do you want to save this run?"),
      ],
     ),
     actions: [
      OutlinedButton(
       onPressed: () {
                // 8. SỬA: Dùng BLoC context để gọi BLoC
        blocContext.read<RunBloc>().add(DiscardRun());
        Navigator.of(dialogContext).pop(); // Đóng Dialog
        blocContext.pop(); // Đóng RunScreen
       },
       child: const Text("Discard"),
      ),
      ElevatedButton(
       onPressed: () {
        blocContext.read<RunBloc>().add(StopRun());
        Navigator.of(dialogContext).pop(); // Đóng Dialog
                blocContext.pop(); // Đóng RunScreen
       },
       style: ElevatedButton.styleFrom(backgroundColor: lightGreen),
       child: const Text("Save", style: TextStyle(color: textBlack)), // 9. SỬA: Màu chữ
      ),
     ],
    );
   },
  );
 }

  // Helper Functions
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  String _calculatePace(int seconds, double distanceMeters) {
    if (distanceMeters <= 0 || seconds <= 0) return "0'00\"";

    final distanceKm = distanceMeters / 1000;
    final durationMinutes = seconds / 60;
    final paceMinutesPerKm = durationMinutes / distanceKm;

    final minutes = paceMinutesPerKm.floor();
    final secs = ((paceMinutesPerKm - minutes) * 60).round();

    return "$minutes'${secs.toString().padLeft(2, '0')}\"";
  }

  int _calculateCalories(double distanceMeters) {
    // Rough estimate: 0.75 calories per kg per km, assuming 70kg
    final distanceKm = distanceMeters / 1000;
    return (distanceKm * 0.75 * 70).round();
  }
}
