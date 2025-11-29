class LeaderboardEntry {
  final String userId;
  final String fullName;
  final double totalDistanceKm;
  final int totalDurationSeconds;

  const LeaderboardEntry({
    required this.userId,
    required this.fullName,
    this.totalDistanceKm = 0.0,
    this.totalDurationSeconds = 0,
  });
}