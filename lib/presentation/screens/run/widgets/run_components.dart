// lib/presentation/screens/run/widgets/run_components.dart
import 'package:flutter/material.dart';
import '../bloc/run_bloc.dart';

// ============================================================================
// COLORS - Định nghĩa màu sắc chung
// ============================================================================
class RunColors {
  static const Color lightGreen = Color(0xFFD0FD3E);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color textBlack = Color(0xFF000000);
  static const Color textGray = Color(0xFF8A8A8E);
  static const Color chipBackground = Color(0xFFE8F5E9);
}

// ============================================================================
// HELPERS - Các hàm tính toán chung
// ============================================================================
class RunHelpers {
  /// Format thời gian từ giây sang HH:MM:SS hoặc MM:SS
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  /// Tính pace (phút/km)
  static String calculatePace(int seconds, double distanceMeters) {
    if (distanceMeters <= 0 || seconds <= 0) return "0'00\"";

    final distanceKm = distanceMeters / 1000;
    final durationMinutes = seconds / 60;
    final paceMinutesPerKm = durationMinutes / distanceKm;

    final minutes = paceMinutesPerKm.floor();
    final secs = ((paceMinutesPerKm - minutes) * 60).round();

    return "$minutes'${secs.toString().padLeft(2, '0')}\"";
  }

  /// Tính calories (ước lượng: 0.75 cal/kg/km, giả sử 70kg)
  static int calculateCalories(double distanceMeters) {
    final distanceKm = distanceMeters / 1000;
    return (distanceKm * 0.75 * 70).round();
  }

  /// Lấy dữ liệu từ state
  static RunData getRunData(RunState state) {
    if (state is RunInProgress) {
      return RunData(
        elapsedSeconds: state.elapsedSeconds,
        distanceMeters: state.distanceMeters,
        isRunning: !state.isPaused,
        hasRoute: state.route.isNotEmpty,
      );
    }
    return RunData();
  }
}

/// Data class để truyền dữ liệu
class RunData {
  final int elapsedSeconds;
  final double distanceMeters;
  final bool isRunning;
  final bool hasRoute;

  RunData({
    this.elapsedSeconds = 0,
    this.distanceMeters = 0,
    this.isRunning = false,
    this.hasRoute = false,
  });

  String get duration => RunHelpers.formatDuration(elapsedSeconds);
  String get pace => RunHelpers.calculatePace(elapsedSeconds, distanceMeters);
  int get calories => RunHelpers.calculateCalories(distanceMeters);
  double get distanceKm => distanceMeters / 1000;
}

// ============================================================================
// WIDGETS - Các component UI tái sử dụng
// ============================================================================

/// Top Status Bar với Weather và GPS
class RunTopStatusBar extends StatelessWidget {
  const RunTopStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatusChip(icon: Icons.wb_sunny, text: "25°C"),
        // Progress indicator
        Container(
          height: 8,
          width: 60,
          decoration: BoxDecoration(
            color: RunColors.chipBackground,
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
              Expanded(
                flex: 6,
                child: Container(color: RunColors.lightGreen),
              ),
            ],
          ),
        ),
        _StatusChip(icon: Icons.gps_fixed, text: "GPS"),
      ],
    );
  }
}

/// Status Chip (Weather/GPS)
class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatusChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: RunColors.chipBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RunColors.textGray, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: RunColors.textBlack, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Hiển thị khoảng cách lớn
class RunDistanceDisplay extends StatelessWidget {
  final double distanceKm;
  final double fontSize;

  const RunDistanceDisplay({
    super.key,
    required this.distanceKm,
    this.fontSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          distanceKm.toStringAsFixed(2),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: RunColors.textBlack,
          ),
        ),
        const Text(
          "Distance (Km)",
          style: TextStyle(fontSize: 16, color: RunColors.textGray),
        ),
      ],
    );
  }
}

/// Hiển thị thông tin stats (Pace, Duration, Calories)
class RunStatsInfo extends StatelessWidget {
  final RunData data;
  final double iconSize;
  final double valueSize;

  const RunStatsInfo({
    super.key,
    required this.data,
    this.iconSize = 24,
    this.valueSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: Icons.directions_run,
          value: data.pace,
          label: "Avg Pace",
          iconSize: iconSize,
          valueSize: valueSize,
        ),
        _StatItem(
          icon: Icons.timer,
          value: data.duration,
          label: "Duration",
          iconSize: iconSize,
          valueSize: valueSize,
        ),
        _StatItem(
          icon: Icons.local_fire_department,
          value: "${data.calories} kcal",
          label: "Calories",
          iconSize: iconSize,
          valueSize: valueSize,
        ),
      ],
    );
  }
}

/// Stat Item
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final double iconSize;
  final double valueSize;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconSize,
    required this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: RunColors.textGray, size: iconSize),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.w600,
            color: RunColors.textBlack,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: RunColors.textGray),
        ),
      ],
    );
  }
}

/// Music Player placeholder
class RunMusicPlayer extends StatelessWidget {
  const RunMusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RunColors.lightGreen,
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
            child: Icon(Icons.music_note, color: RunColors.textBlack),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No music playing",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: RunColors.textBlack,
                  ),
                ),
                Text(
                  "Tap to select music",
                  style: TextStyle(fontSize: 12, color: RunColors.textGray),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.play_arrow, color: RunColors.textBlack),
            onPressed: () {
              print("Music control clicked");
            },
          ),
        ],
      ),
    );
  }
}

/// Circular Action Button
class RunCircularButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;
  final double size;
  final double iconSize;
  final bool isOutlined;

  const RunCircularButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
    this.size = 80,
    this.iconSize = 32,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: BorderSide(
            color: borderColor ?? RunColors.lightGreen,
            width: 2,
          ),
          padding: const EdgeInsets.all(0),
          fixedSize: Size(size, size),
          backgroundColor: backgroundColor ?? RunColors.chipBackground,
        ),
        child: Icon(
          icon,
          color: iconColor ?? RunColors.textBlack,
          size: iconSize,
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: backgroundColor ?? RunColors.lightGreen,
        fixedSize: Size(size, size),
      ),
      child: Icon(
        icon,
        color: iconColor ?? RunColors.textBlack,
        size: iconSize,
      ),
    );
  }
}

/// Dialog xác nhận Stop/Save Run
class RunStopDialog extends StatelessWidget {
  final RunData data;
  final VoidCallback onDiscard;
  final VoidCallback onSave;

  const RunStopDialog({
    super.key,
    required this.data,
    required this.onDiscard,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required RunData data,
    required VoidCallback onDiscard,
    required VoidCallback onSave,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => RunStopDialog(
        data: data,
        onDiscard: onDiscard,
        onSave: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Save Run?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Distance: ${data.distanceKm.toStringAsFixed(2)} km"),
          Text("Duration: ${data.duration}"),
          const SizedBox(height: 8),
          const Text("Do you want to save this run?"),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDiscard();
          },
          child: const Text("Discard"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onSave();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: RunColors.lightGreen,
          ),
          child: Text(
            "Save",
            style: TextStyle(color: RunColors.textBlack),
          ),
        ),
      ],
    );
  }
}