import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/game_session.dart';
import '../controllers/neuro_wellness_controller.dart';
import '../widgets/game_result_dialog.dart';

enum _RoundState { waiting, ready, tooSoon, result }

/// Classic reaction-test loop: a target appears after a random delay, the
/// user taps it as fast as possible. Guards against anticipation-tapping by
/// penalizing (not crashing on) an early tap.
class ReactionTimeGameView extends StatefulWidget {
  const ReactionTimeGameView({super.key});

  @override
  State<ReactionTimeGameView> createState() => _ReactionTimeGameViewState();
}

class _ReactionTimeGameViewState extends State<ReactionTimeGameView> {
  static const int _totalRounds = 6;

  int _round = 0;
  final List<int> _reactionTimesMs = [];
  _RoundState _state = _RoundState.waiting;
  Offset _targetPosition = Offset.zero;
  DateTime? _targetShownAt;
  Timer? _delayTimer;
  final DateTime _sessionStart = DateTime.now();

  // Reused for the whole game instead of `Random()` per call: Dart's
  // unseeded Random derives its seed from the clock, so creating a fresh
  // instance for the delay and then again for x/y microseconds later can
  // produce correlated output on some platforms — which is exactly why the
  // target kept landing in the same spot. One instance, reused, is both the
  // correct fix and the standard/faster way to use Random anyway.
  final Random _rand = Random();

  static const List<Color> _targetColors = [
    Colors.pinkAccent,
    Colors.deepPurpleAccent,
    Colors.orangeAccent,
    Colors.tealAccent,
    Colors.blueAccent,
  ];
  Color _targetColor = Colors.pinkAccent;

  @override
  void initState() {
    super.initState();
    _startNextRound();
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  void _startNextRound() {
    if (_round >= _totalRounds) {
      _finishGame();
      return;
    }
    _round++;
    setState(() => _state = _RoundState.waiting);

    final delayMs = 800 + _rand.nextInt(2200); // 0.8s - 3.0s
    _delayTimer?.cancel();
    _delayTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      setState(() {
        _state = _RoundState.ready;
        _targetPosition = Offset(
          0.1 + _rand.nextDouble() * 0.8,
          0.1 + _rand.nextDouble() * 0.7,
        );
        _targetColor = _targetColors[_rand.nextInt(_targetColors.length)];
        _targetShownAt = DateTime.now();
      });
    });
  }

  void _onWaitingAreaTap() {
    if (_state != _RoundState.waiting) return;
    // Tapped before the target appeared — penalize this round rather than
    // letting the user game the test by mashing the screen.
    _delayTimer?.cancel();
    _reactionTimesMs.add(1200);
    setState(() => _state = _RoundState.tooSoon);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _startNextRound();
    });
  }

  void _onTargetTap() {
    if (_state != _RoundState.ready || _targetShownAt == null) return;
    final reactionMs = DateTime.now().difference(_targetShownAt!).inMilliseconds;
    _reactionTimesMs.add(reactionMs);
    setState(() => _state = _RoundState.result);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _startNextRound();
    });
  }

  void _finishGame() {
    final avgMs = _reactionTimesMs.isEmpty
        ? 0
        : (_reactionTimesMs.reduce((a, b) => a + b) / _reactionTimesMs.length).round();
    // Faster average reaction time -> higher score. 200ms is roughly
    // excellent human reaction time, 800ms+ trends toward 0.
    final score = (100 - ((avgMs - 200) / 6)).clamp(0, 100).round();

    if (Get.isRegistered<NeuroWellnessController>()) {
      Get.find<NeuroWellnessController>().recordSession(GameSession(
        gameId: 'reaction_time',
        score: score,
        durationSeconds: DateTime.now().difference(_sessionStart).inSeconds,
        completedAt: DateTime.now(),
      ));
    }

    GameResultDialog.show(
      icon: Icons.touch_app_outlined,
      accentColor: Colors.pinkAccent,
      title: "Reflexes Tested",
      message: "Average reaction time: ${avgMs}ms",
      onTryAgain: () {
        setState(() {
          _round = 0;
          _reactionTimesMs.clear();
        });
        _startNextRound();
      },
    );
  }

  String get _instruction {
    switch (_state) {
      case _RoundState.waiting:
        return "Wait for it...";
      case _RoundState.ready:
        return "Tap now!";
      case _RoundState.tooSoon:
        return "Too soon! Wait for the target.";
      case _RoundState.result:
        return "${_reactionTimesMs.last}ms";
    }
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
                  Text("Focus Tap", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text("Round $_round/$_totalRounds", style: theme.textTheme.titleSmall),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _onWaitingAreaTap,
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  // LayoutBuilder now wraps the Stack (not nested inside it)
                  // so the Positioned below is a direct child of Stack, as
                  // Flutter requires — it was previously returned from a
                  // LayoutBuilder placed *inside* the Stack's children list,
                  // which throws "Incorrect use of ParentDataWidget" and
                  // left the target's position never actually applying,
                  // which is why it always appeared in the same spot.
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Stack(
                      children: [
                        Center(
                          child: Text(
                            _instruction,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w300),
                          ),
                        ),
                        if (_state == _RoundState.ready)
                          Positioned(
                            left: _targetPosition.dx * constraints.maxWidth,
                            top: _targetPosition.dy * constraints.maxHeight,
                            child: GestureDetector(
                              onTap: _onTargetTap,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.4, end: 1.0),
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: _targetColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: _targetColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
