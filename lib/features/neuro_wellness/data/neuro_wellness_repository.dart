import 'package:get_storage/get_storage.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import 'models/game_session.dart';

class NeuroWellnessStats {
  final int streak;
  final int brainPower;
  final int totalSessions;

  const NeuroWellnessStats({
    required this.streak,
    required this.brainPower,
    required this.totalSessions,
  });
}

/// Local-first progress/streak tracking for Neuro Wellness games. Reads and
/// writes are all synchronous GetStorage disk access — the UI never waits on
/// a network call to know the user's streak. Session history is also synced
/// to the backend, but purely fire-and-forget for durability/future
/// cross-device support; a failed sync never affects what the user sees.
class NeuroWellnessRepository {
  static const _keyStreak = 'neuro_streak_count';
  static const _keyLastPlayedDate = 'neuro_last_played_date';
  static const _keyTotalSessions = 'neuro_total_sessions';
  static const _keyRecentScores = 'neuro_recent_scores';

  final GetStorage _storage;

  NeuroWellnessRepository({GetStorage? storage}) : _storage = storage ?? GetStorage();

  NeuroWellnessStats getStats() {
    final streak = _storage.read<int>(_keyStreak) ?? 0;
    final totalSessions = _storage.read<int>(_keyTotalSessions) ?? 0;
    final recentScores = (_storage.read<List>(_keyRecentScores) ?? const [])
        .whereType<num>()
        .map((n) => n.toDouble())
        .toList();
    final brainPower = recentScores.isEmpty
        ? 100
        : (recentScores.reduce((a, b) => a + b) / recentScores.length).round().clamp(0, 100).toInt();
    return NeuroWellnessStats(streak: streak, brainPower: brainPower, totalSessions: totalSessions);
  }

  Future<NeuroWellnessStats> recordSession(GameSession session) async {
    _updateStreak();
    _updateBrainPower(session.score);
    await _storage.write(_keyTotalSessions, (_storage.read<int>(_keyTotalSessions) ?? 0) + 1);

    _syncToBackend(session);

    return getStats();
  }

  void _updateStreak() {
    final today = _dateOnly(DateTime.now());
    final lastPlayedStr = _storage.read<String>(_keyLastPlayedDate);
    final currentStreak = _storage.read<int>(_keyStreak) ?? 0;

    if (lastPlayedStr == null) {
      _storage.write(_keyStreak, 1);
    } else {
      final lastPlayed = DateTime.tryParse(lastPlayedStr);
      if (lastPlayed == null) {
        _storage.write(_keyStreak, 1);
      } else {
        final daysSince = today.difference(_dateOnly(lastPlayed)).inDays;
        if (daysSince == 0) {
          // Already played today — streak unchanged.
        } else if (daysSince == 1) {
          _storage.write(_keyStreak, currentStreak + 1);
        } else {
          _storage.write(_keyStreak, 1);
        }
      }
    }
    _storage.write(_keyLastPlayedDate, today.toIso8601String());
  }

  void _updateBrainPower(int score) {
    final scores = (_storage.read<List>(_keyRecentScores) ?? const []).whereType<num>().toList();
    scores.add(score.clamp(0, 100));
    // Keep only the last 5 sessions so brain power reflects recent play, not
    // a lifetime average that barely moves after dozens of sessions.
    final trimmed = scores.length > 5 ? scores.sublist(scores.length - 5) : scores;
    _storage.write(_keyRecentScores, trimmed);
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  void _syncToBackend(GameSession session) {
    // Fire-and-forget — intentionally not awaited by callers. A dev server
    // being down, slow, or erroring must never surface in the game UI.
    () async {
      try {
        await DioClient().fastAPI.post(ApiEndpoints.neuroWellnessSessions, data: session.toJson());
      } catch (e) {
        print('[NeuroWellnessRepository] Failed to sync session: $e');
      }
    }();
  }
}
