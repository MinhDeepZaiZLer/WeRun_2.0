// lib/presentation/screens/home/home_screen.dart
import 'package:dacs4_werun_2_0/presentation/components/navigation_drawer_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:dacs4_werun_2_0/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            title: Text(
              state.user?.fullName.isEmpty ?? true ? 'WeRun' : state.user!.fullName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            actions: const [
              SizedBox(width: 68),
            ],
          ),
          drawer: const NavigationDrawerContent(),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          
                          // Goal Circle and Map
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GoalCircleProgress(
                                goal: _safeGoal(state.stats.todayGoal),
                                progress: _safeProgress(state.stats.goalProgress),
                              ),
                              MapPlaceholder(
                                lastLat: state.user?.lastRunLat ?? 0.0,
                                lastLng: state.user?.lastRunLng ?? 0.0,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Weather Section
                          _buildWeatherSection(state.weatherState),
                          
                          const SizedBox(height: 16),
                          
                          // Today's Goal
                          const Text(
                            "Today's Goal",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Run ${_formatDistance(state.stats.todayGoal)} KM',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Motivational Message
                          Text(
                            state.motivationalMessage.isEmpty
                                ? "Let's start your journey!"
                                : state.motivationalMessage,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Statistics
                          StatisticsRow(
                            totalDistance: _safeTotalDistance(state.stats.totalDistance),
                            bestPace: state.stats.bestPace.isEmpty
                                ? '0:00'
                                : state.stats.bestPace,
                            consecutiveDays: math.max(0, state.stats.consecutiveDays),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Controls
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: RunControls(
                      onStartClick: () {

                        context.read<HomeBloc>().add(StartRun());

                       context.go('/run');

                      },
                      onSettingsClick: () {
                        context.read<HomeBloc>().add(OpenSettings());
                        Navigator.pushNamed(context, '/settings');
                      },
                      onMusicClick: () {
                        context.read<HomeBloc>().add(OpenMusic());
                      },
                    ),
                  ),
                ],
              ),
              
              // Loading indicator
              if (state.isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFC4FF53),
                  ),
                ),
              
              // Error message
              if (state.error != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.error!.isEmpty ? 'An error occurred' : state.error!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _safeGoal(double goal) {
    return goal.isFinite ? goal / 1000 : 0.0;
  }

  double _safeProgress(double progress) {
    return progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0;
  }

  double _safeTotalDistance(double distance) {
    return distance.isFinite ? distance / 1000 : 0.0;
  }

  String _formatDistance(double meters) {
    final km = meters.isFinite ? meters / 1000 : 0.0;
    return km.toStringAsFixed(1);
  }

  Widget _buildWeatherSection(WeatherState weatherState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (weatherState.isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.grey,
                strokeWidth: 2,
              ),
            )
          else ...[
            Icon(
              _getWeatherIcon(weatherState.weatherCode),
              color: const Color(0xFFFFD700),
              size: 24,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weatherState.temperature,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weatherState.condition,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
          if (weatherState.error != null)
            Text(
              weatherState.error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny; // Sunny
      case 1:
      case 2:
      case 3:
        return Icons.cloud; // Cloudy
      case 45:
      case 48:
        return Icons.cloud; // Fog
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
        return Icons.water_drop; // Rain
      case 71:
      case 73:
      case 75:
        return Icons.ac_unit; // Snow
      case 95:
      case 96:
      case 99:
        return Icons.flash_on; // Storm
      default:
        return Icons.water_drop; // Unknown
    }
  }
}

// Goal Circle Progress Widget
class GoalCircleProgress extends StatelessWidget {
  final double goal;
  final double progress;

  const GoalCircleProgress({
    super.key,
    required this.goal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: const Size(140, 140),
            painter: CircleProgressPainter(
              progress: 1.0,
              color: Colors.grey.shade300,
              strokeWidth: 12,
            ),
          ),
          // Progress circle
          CustomPaint(
            size: const Size(140, 140),
            painter: CircleProgressPainter(
              progress: progress,
              color: const Color(0xFFC4FF53),
              strokeWidth: 12,
            ),
          ),
          // Goal text
          Text(
            goal.isFinite ? goal.toStringAsFixed(1) : '0.0',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Circle Progress
class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// Map Placeholder Widget
class MapPlaceholder extends StatelessWidget {
  final double lastLat;
  final double lastLng;

  const MapPlaceholder({
    super.key,
    required this.lastLat,
    required this.lastLng,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement actual map widget using google_maps_flutter or similar
    return Container(
      width: 180,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Lat: ${lastLat.toStringAsFixed(4)}\nLng: ${lastLng.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Statistics Row Widget
class StatisticsRow extends StatelessWidget {
  final double totalDistance;
  final String bestPace;
  final int consecutiveDays;

  const StatisticsRow({
    super.key,
    required this.totalDistance,
    required this.bestPace,
    required this.consecutiveDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatItem(
          value: totalDistance.isFinite
              ? totalDistance.toStringAsFixed(1)
              : '0.0',
          label: 'KM',
        ),
        StatItem(
          value: bestPace,
          label: 'BEST PACE',
        ),
        StatItem(
          value: consecutiveDays.toString(),
          label: 'CONSECUTIVE\nDAYS',
        ),
      ],
    );
  }
}

// Stat Item Widget
class StatItem extends StatelessWidget {
  final String value;
  final String label;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Home Top Bar Widget
class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback onMenuClick;

  const HomeTopBar({
    super.key,
    required this.userName,
    required this.onMenuClick,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: onMenuClick,
      ),
      title: Text(
        userName.isEmpty ? 'WeRun' : userName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      actions: const [
        SizedBox(width: 68),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Run Controls Widget
class RunControls extends StatelessWidget {
  final VoidCallback onStartClick;
  final VoidCallback onSettingsClick;
  final VoidCallback onMusicClick;

  const RunControls({
    super.key,
    required this.onStartClick,
    required this.onSettingsClick,
    required this.onMusicClick,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFC4FF53);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RoundIconButton(
            icon: Icons.settings,
            borderColor: accentColor,
            onPressed: onSettingsClick,
          ),
          StartRunButton(
            backgroundColor: accentColor,
            onPressed: onStartClick,
          ),
          RoundIconButton(
            icon: Icons.music_note,
            borderColor: accentColor,
            onPressed: onMusicClick,
          ),
        ],
      ),
    );
  }
}

// Round Icon Button Widget
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color borderColor;
  final VoidCallback onPressed;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 32),
        onPressed: onPressed,
      ),
    );
  }
}

// Start Run Button Widget
class StartRunButton extends StatelessWidget {
  final Color backgroundColor;
  final VoidCallback onPressed;

  const StartRunButton({
    super.key,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.black,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'START',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}