import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';

class MemoryRecallGameView extends StatefulWidget {
  const MemoryRecallGameView({super.key});

  @override
  State<MemoryRecallGameView> createState() => _MemoryRecallGameViewState();
}

class _MemoryRecallGameViewState extends State<MemoryRecallGameView> {
  final List<IconData> icons = [
    Icons.favorite, Icons.star, Icons.wb_sunny, Icons.nightlight_round,
    Icons.eco, Icons.water_drop, Icons.bolt, Icons.local_fire_department
  ];
  
  List<int> sequence = [];
  List<int> userSequence = [];
  bool isShowingSequence = false;
  bool isGameOver = false;
  int level = 1;

  @override
  void initState() {
    super.initState();
    _startNewLevel();
  }

  void _startNewLevel() async {
    setState(() {
      sequence = List.generate(level + 2, (_) => Random().nextInt(icons.length));
      userSequence = [];
      isShowingSequence = true;
      isGameOver = false;
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    _showSequence();
  }

  void _showSequence() async {
    // In a real implementation, we would animate each icon. 
    // For this MVP, we show them for a duration then hide.
    await Future.delayed(Duration(milliseconds: 1000 + (level * 200)));
    if (mounted) {
      setState(() {
        isShowingSequence = false;
      });
    }
  }

  void _onIconTap(int index) {
    if (isShowingSequence || isGameOver) return;

    setState(() {
      userSequence.add(index);
    });

    if (userSequence.last != sequence[userSequence.length - 1]) {
      setState(() {
        isGameOver = true;
      });
      _showGameOverDialog();
    } else if (userSequence.length == sequence.length) {
      _showSuccessSnippet();
    }
  }

  void _showSuccessSnippet() {
    Get.snackbar(
      "Excellent Focus!", 
      "Level $level completed. Moving to level ${level + 1}.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          level++;
          _startNewLevel();
        });
      }
    });
  }

  void _showGameOverDialog() {
    Get.defaultDialog(
      title: "Recalibration Incomplete",
      middleText: "You reached Level $level. Daily practice clears the fog!",
      textConfirm: "Try Again",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        setState(() {
          level = 1;
          _startNewLevel();
        });
      },
      textCancel: "Lobby",
      onCancel: () => Get.back(closeOverlays: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                    ? [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withBlue(20),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFF1F5F9), // Very light cool grey
                      ],
                ),
              ),
            ),
          ),
          // Pattern Overlay
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.05 : 0.03,
              child: Image.asset(
                'assets/images/live_poised_pattern.png',
                repeat: ImageRepeat.repeat,
                scale: 16,
                errorBuilder: (context, _, __) => const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, theme),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProgressHeader(theme),
                      const Spacer(),
                      _buildGameBoard(theme),
                      const Spacer(),
                      _buildGameInstructions(theme),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          Text(
            "Memory Recalibration", 
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(ThemeData theme) {
    return Column(
      children: [
        Text("Level $level", style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isShowingSequence ? "MEMORIZE THE SEQUENCE" : "RECALL THE SEQUENCE",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 12, color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard(ThemeData theme) {
    if (isShowingSequence) {
      return Wrap(
        spacing: 12, runSpacing: 12,
        alignment: WrapAlignment.center,
        children: sequence.map((idx) => _buildAnimatedIcon(icons[idx], theme)).toList(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _onIconTap(index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
              ),
              child: Icon(icons[index], color: theme.colorScheme.primary.withOpacity(0.8), size: 32),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, ThemeData theme) {
    // Simplified static display for MVP sequence showing
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Icon(icon, color: theme.colorScheme.primary, size: 30),
    );
  }

  Widget _buildGameInstructions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        isShowingSequence 
          ? "Watch the sequence carefully. It will disappear soon." 
          : "Tap the icons in the exact order they appeared.",
        textAlign: TextAlign.center,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
      ),
    );
  }
}
