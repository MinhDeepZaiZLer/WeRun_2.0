// lib/data/repositories/run_repository_impl.dart
import '../services/firestore_service.dart';

import '../../domain/entities/run_activity.dart';
import '../../domain/repositories/run_repository.dart';
import '../models/run_activity_model.dart';
import 'package:injectable/injectable.dart';
@LazySingleton(as: RunRepository) // <-- ĐÂY LÀ PHẦN SỬA LỖI
class RunRepositoryImpl implements RunRepository {
  final FirestoreService _firestoreService;

  RunRepositoryImpl(this._firestoreService);

  @override
  Stream<List<RunActivity>> getRunHistory() {
    // Lấy stream Model từ service và "dịch" nó sang Entity
    return _firestoreService.getRunHistoryStream().map((models) {
      // Vì Model extends Entity, chúng ta có thể trả về trực tiếp
      return models.cast<RunActivity>();
    });
  }

  @override
  Future<void> saveRun(RunActivity run) {
    // "Dịch" Entity sang Model để lưu
    final runModel = RunActivityModel(
      id: run.id,
      userId: run.userId,
      route: run.route,
      durationInSeconds: run.durationInSeconds,
      distanceInMeters: run.distanceInMeters,
      timestamp: run.timestamp,
      avgSpeedKmh: run.avgSpeedKmh,
      caloriesBurned: run.caloriesBurned,
    );
    return _firestoreService.saveRunActivity(runModel);
  }
}