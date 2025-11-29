import 'package:injectable/injectable.dart';
import '../entities/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';

@lazySingleton
class GetLeaderboardUsecase {
  final LeaderboardRepository _repository;

  GetLeaderboardUsecase(this._repository);

  Future<List<LeaderboardEntry>> call({
    required LeaderboardFilter filter,
    List<String>? friendIds, // Nếu null -> Lấy Global
  }) {
    return _repository.getRankings(filter, friendIds: friendIds);
  }
}