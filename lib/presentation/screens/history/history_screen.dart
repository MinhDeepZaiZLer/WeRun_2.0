// lib/presentation/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dacs4_werun_2_0/core/di/injection.dart';
import 'package:intl/intl.dart'; 
import '../../../domain/entities/run_activity.dart';
import 'bloc/history_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HistoryBloc>()..add(LoadHistory()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 1,
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            // 1. Trạng thái Đang tải
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Trạng thái Lỗi
            if (state is HistoryError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            // 3. Trạng thái Đã tải
            if (state is HistoryLoaded) {
              if (state.activities.isEmpty) {
                return const Center(child: Text('No runs yet. Go for a run!'));
              }
              
              // Hiển thị Column + ListView
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần Thống kê
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildSummarySection(context, state.activities),
                  ),
                  
                  // Phần Danh sách
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: state.activities.length,
                      itemBuilder: (context, index) {
                        final activity = state.activities[index];
                        return RunHistoryCard(activity: activity);
                      },
                    ),
                  ),
                ],
              );
            }
            
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }

  // Widget Thống kê (Giống file Kotlin)
  Widget _buildSummarySection(BuildContext context, List<RunActivity> activities) {
    final theme = Theme.of(context);
    
    // Tính toán thống kê
    double totalDistanceKm = 0;
    double totalDurationSeconds = 0;
    // double totalPaceMinPerKm = 0; // <-- SỬA LỖI 2: Xóa biến không dùng

    for (var run in activities) {
      totalDistanceKm += run.distanceInMeters / 1000;
      totalDurationSeconds += run.durationInSeconds;
    }
    
    // Tính Pace trung bình
    String avgPace = "--";
    if (totalDistanceKm > 0 && totalDurationSeconds > 0) {
      final avgPaceMinPerKm = (totalDurationSeconds / 60) / totalDistanceKm;
      final minutes = avgPaceMinPerKm.floor();
      final secs = ((avgPaceMinPerKm - minutes) * 60).round();
      avgPace = "$minutes'${secs.toString().padLeft(2, '0')}\"";
    }

    // Tính Thời gian tổng
    final duration = Duration(seconds: totalDurationSeconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    String totalTime = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          totalDistanceKm.toStringAsFixed(2),
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary, 
          ),
        ),
        Text(
          "Kilometers",
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SummaryItem(label: "Runs", value: activities.length.toString()),
            _SummaryItem(label: "Average Pace", value: avgPace),
            _SummaryItem(label: "Time", value: totalTime),
          ],
        ),
      ],
    );
  }
}

// === SỬA LỖI 1: CHUYỂN TỪ `fun` (KOTLIN) SANG `StatelessWidget` (DART) ===
class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    // Context giờ đã hợp lệ
    final theme = Theme.of(context); 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
// === KẾT THÚC SỬA LỖI 1 ===


// Widget Card (Đã sửa lỗi string interpolation)
class RunHistoryCard extends StatelessWidget {
  final RunActivity activity;
  const RunHistoryCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final String date = DateFormat.yMMMd().format(activity.timestamp);
    final String distance = (activity.distanceInMeters / 1000).toStringAsFixed(2);
    final String duration = Duration(seconds: activity.durationInSeconds)
        .toString()
        .split('.')
        .first
        .padLeft(8, "0");
    
    final paceInMinPerKm = (activity.durationInSeconds / 60) / (activity.distanceInMeters / 1000);
    
    String pace = "--";
    if (paceInMinPerKm.isFinite && !paceInMinPerKm.isNegative) {
      final minutes = paceInMinPerKm.floor();
      final secs = ((paceInMinPerKm - minutes) * 60).round();
      // SỬA LỖI 3: Sửa lỗi linter (không ảnh hưởng)
      pace = "$minutes'${secs.toString().padLeft(2, '0')}\""; 
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(title: 'Distance', value: '$distance km'),
                _StatItem(title: 'Duration', value: duration),
                _StatItem(title: 'Avg. Pace', value: pace),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget con cho mỗi chỉ số
class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}