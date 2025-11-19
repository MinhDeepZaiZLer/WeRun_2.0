// lib/presentation/screens/run/run_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:dacs4_werun_2_0/core/di/injection.dart';
import 'bloc/run_bloc.dart';
import 'widgets/run_components.dart';

class RunScreen extends StatelessWidget {
  const RunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RunView();
  }
}

class RunView extends StatelessWidget {
  const RunView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RunColors.lightGray,
      body: BlocConsumer<RunBloc, RunState>(
        listener: (context, state) {
          // Xử lý lỗi
          if (state is RunFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          
          // Tự động thoát khi lưu/hủy xong
          if ((state is RunInitial && state.suggestedRoute == null)|| state is RunFinished) {
            if (ModalRoute.of(context)?.isCurrent ?? false) {
              // Kiểm tra xem có thể pop không, nếu không thì dùng go
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home'); // Hoặc route home của bạn
              }
            }
          }
        },
        builder: (context, state) {
          final data = RunHelpers.getRunData(state);
          
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                children: [
                  // Top status bar
                  const RunTopStatusBar(),
                  const SizedBox(height: 48),
                  
                  // Distance display (lớn)
                  RunDistanceDisplay(
                    distanceKm: data.distanceKm,
                    fontSize: 80,
                  ),
                  const SizedBox(height: 32),
                  
                  // Stats info
                  RunStatsInfo(
                    data: data,
                    iconSize: 24,
                    valueSize: 20,
                  ),
                  const SizedBox(height: 24),
                  
                  // Music player
                  const RunMusicPlayer(),
                  const Spacer(),
                  
                  // Action buttons
                  _RunActionButtons(data: data),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget chứa các nút action (Map, Start/Pause, Stop)
class _RunActionButtons extends StatelessWidget {
  final RunData data;

  const _RunActionButtons({required this.data});

  @override
  Widget build(BuildContext context) {
    final runBloc = context.read<RunBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Map Button
        RunCircularButton(
          onPressed: () => context.push('/map'),
          icon: Icons.map_outlined,
          size: 80,
          iconSize: 36,
          isOutlined: true,
        ),

        // Start/Pause/Resume Button
        RunCircularButton(
          onPressed: () {
            if (data.isRunning) {
              runBloc.add(PauseRun());
            } else {
              if (data.hasRoute) {
                runBloc.add(ResumeRun());
              } else {
                runBloc.add(StartRun());
              }
            }
          },
          icon: data.isRunning ? Icons.pause : Icons.play_arrow,
          backgroundColor: data.isRunning ? Colors.red : RunColors.lightGreen,
          iconColor: data.isRunning ? Colors.white : RunColors.textBlack,
          size: 100,
          iconSize: 40,
        ),

        // Stop Button (chỉ hiển thị khi có route)
        if (data.hasRoute)
          RunCircularButton(
            onPressed: () => _showStopDialog(context, runBloc),
            icon: Icons.stop,
            backgroundColor: Colors.grey,
            iconColor: Colors.white,
            size: 80,
            iconSize: 32,
          )
        // Nếu CHƯA CHẠY -> Hiển thị nút AI
        else
          RunCircularButton(
            onPressed: () {
              // GỌI EVENT MỚI
              runBloc.add(SuggestRouteRequested(distanceKm: 5.0));

              context.push("/map");
            },
            icon: Icons.auto_awesome, // Icon AI
            backgroundColor: Colors.blueAccent,
            iconColor: Colors.white,
            size: 80,
            iconSize: 32,
          ), // Giữ chỗ
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