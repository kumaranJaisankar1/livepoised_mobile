/// Result of one completed Neuro Wellness game session. Purely a local +
/// outgoing-sync shape (not an API DTO consumed elsewhere), so this is a
/// plain class rather than a build_runner-managed freezed model.
class GameSession {
  final String gameId;
  final int score;
  final int durationSeconds;
  final DateTime completedAt;

  const GameSession({
    required this.gameId,
    required this.score,
    required this.durationSeconds,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'score': score,
        'durationSeconds': durationSeconds,
        'completedAt': completedAt.toIso8601String(),
      };
}
