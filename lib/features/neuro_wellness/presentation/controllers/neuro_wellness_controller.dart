import 'package:get/get.dart';

class NeuroWellnessController extends GetxController {
  final streak = 0.obs;
  final brainPower = 100.obs; // A metric representing cognitive freshness

  void startGame(String gameId) {
    if (gameId == 'memory_recall') {
      Get.toNamed('/neuro-wellness/memory-recall');
    } else if (gameId == 'zen_flow') {
      Get.toNamed('/neuro-wellness/zen-flow');
    } else {
      Get.snackbar("Coming Soon", "This game is currently under development.");
    }
  }
}
