import 'package:get/get.dart';
import '../../data/models/game_session.dart';
import '../../data/neuro_wellness_repository.dart';

class NeuroWellnessController extends GetxController {
  final NeuroWellnessRepository _repository;

  NeuroWellnessController({NeuroWellnessRepository? repository})
      : _repository = repository ?? NeuroWellnessRepository();

  final streak = 0.obs;
  final brainPower = 100.obs;
  final totalSessions = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _refreshStats();
  }

  void _refreshStats() {
    final stats = _repository.getStats();
    streak.value = stats.streak;
    brainPower.value = stats.brainPower;
    totalSessions.value = stats.totalSessions;
  }

  Future<void> recordSession(GameSession session) async {
    await _repository.recordSession(session);
    _refreshStats();
  }

  void startGame(String gameId) {
    switch (gameId) {
      case 'memory_recall':
        Get.toNamed('/neuro-wellness/memory-recall');
        break;
      case 'zen_flow':
        Get.toNamed('/neuro-wellness/zen-flow');
        break;
      case 'fog_clearer':
        Get.toNamed('/neuro-wellness/fog-clearer');
        break;
      case 'number_match':
        Get.toNamed('/neuro-wellness/number-match');
        break;
      case 'reaction_time':
        Get.toNamed('/neuro-wellness/reaction-time');
        break;
      default:
        Get.snackbar("Coming Soon", "This game is currently under development.");
    }
  }
}
