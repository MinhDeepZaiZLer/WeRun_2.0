import '../entities/leaderboard_entry.dart';

enum LeaderboardFilter { total, year, month, week }

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntry>> getRankings(LeaderboardFilter filter, {List<String>? friendIds});
}