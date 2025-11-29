import 'package:dacs4_werun_2_0/presentation/screens/home/home_bloc.dart';
import 'package:injectable/injectable.dart';
import '../repositories/run_repository.dart';
import '../entities/run_activity.dart';
 // Để dùng class Stats

@lazySingleton
class GetRunStatsUsecase {
  final RunRepository _runRepository;

  GetRunStatsUsecase(this._runRepository);

  Future<Stats> call(String userId) async {
    // 1. Lấy toàn bộ lịch sử chạy
    final history = await _runRepository.getRunHistory().first; // Lấy snapshot đầu tiên

    if (history.isEmpty) return const Stats();

    // 2. Tính toán
    double totalDistance = 0;
    double bestPaceVal = 999999; // Số rất lớn
    
    for (var run in history) {
      totalDistance += run.distanceInMeters;
      
      // Tính pace (min/km)
      if (run.distanceInMeters > 0) {
        double pace = (run.durationInSeconds / 60) / (run.distanceInMeters / 1000);
        if (pace < bestPaceVal) bestPaceVal = pace;
      }
    }

    // Format Best Pace
    String bestPaceStr = "0:00";
    if (bestPaceVal < 999999) {
      int min = bestPaceVal.floor();
      int sec = ((bestPaceVal - min) * 60).round();
      bestPaceStr = "$min:${sec.toString().padLeft(2, '0')}";
    }

    // (Logic Consecutive Days hơi phức tạp, tạm thời để 0 hoặc tính sau)
    
    return Stats(
      todayGoal: 5000.0, // Hardcode mục tiêu hoặc lấy từ User Setting
      goalProgress: 0.0, // Cần lọc history theo ngày hôm nay để tính
      totalDistance: totalDistance,
      bestPace: bestPaceStr,
      consecutiveDays: 0,
    );
  }
}