import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/game_session.dart';
import '../controllers/neuro_wellness_controller.dart';
import '../widgets/game_result_dialog.dart';

/// Visual-scanning / processing-speed game: every tile shows the same icon
/// except one, which is rotated — spot it before the timer runs out. Icon
/// and accent color rotate each round for variety. Each correct tap grows
/// the grid and shrinks the timer.
class FogClearerGameView extends StatefulWidget {
  const FogClearerGameView({super.key});

  @override
  State<FogClearerGameView> createState() => _FogClearerGameViewState();
}

class _FogClearerGameViewState extends State<FogClearerGameView> {
  static const int _startGridSize = 9; // 3x3
  static const int _maxGridSize = 36; // 6x6
  static const int _startRoundMs = 4500;
  static const int _minRoundMs = 1500;
  static const int _tickMs = 100;

  static const List<IconData> _iconPool = [
    Icons.favorite,
    Icons.star,
    Icons.eco,
    Icons.water_drop,
    Icons.bolt,
    Icons.wb_sunny,
    Icons.nightlight_round,
    Icons.ac_unit,
    Icons.local_fire_department,
  ];

  static const List<Color> _colorPool = [
    Colors.teal,
    Colors.purple,
    Colors.indigo,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
  ];

  int _round = 1;
  int _gridSize = _startGridSize;
  int _roundMs = _startRoundMs;
  int _elapsedMs = 0;
  int _targetIndex = 0;
  double _targetAngle = 0;
  late IconData _roundIcon;
  late Color _roundColor;
  bool _isGameOver = false;
  double _timerProgress = 1.0;
  Timer? _roundTimer;
  final DateTime _sessionStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  int get _columns => sqrt(_gridSize).ceil();

  void _startRound() {
    final rand = Random();
    setState(() {
      _targetIndex = rand.nextInt(_gridSize);
      // 40-140 degrees — clearly off-axis for every icon in the pool, never
      // close enough to 0/180/360 to look upright by accident.
      _targetAngle = (40 + rand.nextInt(101)) * (pi / 180);
      _roundIcon = _iconPool[rand.nextInt(_iconPool.length)];
      _roundColor = _colorPool[rand.nextInt(_colorPool.length)];
      _timerProgress = 1.0;
      _elapsedMs = 0;
    });

    // A single merged timer (was two separate Timers before) — one tick
    // drives both the progress bar and the timeout, so there's no chance of
    // them disagreeing/racing, and it's one fewer Timer object per round.
    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(milliseconds: _tickMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _elapsedMs += _tickMs;
      if (_elapsedMs >= _roundMs) {
        timer.cancel();
        setState(() => _timerProgress = 0.0);
        _onTimeout();
        return;
      }
      setState(() {
        _timerProgress = 1 - (_elapsedMs / _roundMs);
      });
    });
  }

  void _onTimeout() {
    if (_isGameOver) return;
    _endGame();
  }

  void _onTileTap(int index) {
    if (_isGameOver) return;
    _roundTimer?.cancel();

    if (index == _targetIndex) {
      setState(() {
        _round++;
        _gridSize = (_gridSize + 2).clamp(_startGridSize, _maxGridSize);
        _roundMs = (_roundMs - 150).clamp(_minRoundMs, _startRoundMs);
      });
      _startRound();
    } else {
      _endGame();
    }
  }

  void _endGame() {
    _roundTimer?.cancel();
    setState(() => _isGameOver = true);

    if (Get.isRegistered<NeuroWellnessController>()) {
      Get.find<NeuroWellnessController>().recordSession(GameSession(
        gameId: 'fog_clearer',
        score: ((_round - 1) * 10).clamp(0, 100),
        durationSeconds: DateTime.now().difference(_sessionStart).inSeconds,
        completedAt: DateTime.now(),
      ));
    }

    GameResultDialog.show(
      icon: Icons.wb_cloudy_outlined,
      accentColor: Colors.teal,
      title: "Vision Sharpened",
      message: "You cleared ${_round - 1} round${_round == 2 ? '' : 's'} of fog!",
      onTryAgain: () {
        setState(() {
          _round = 1;
          _gridSize = _startGridSize;
          _roundMs = _startRoundMs;
          _isGameOver = false;
        });
        _startRound();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
                  const SizedBox(width: 8),
                  Text("Fog Clearer", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text("Round $_round", style: theme.textTheme.titleSmall?.copyWith(color: _roundColor)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _timerProgress,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(_roundColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the tile that's tilted differently",
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _columns,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _gridSize,
                  itemBuilder: (context, index) {
                    final isTarget = index == _targetIndex;
                    return GestureDetector(
                      onTap: () => _onTileTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _roundColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: isTarget ? _targetAngle : 0,
                            child: Icon(_roundIcon, color: _roundColor, size: 28),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
