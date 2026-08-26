import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/game_session.dart';
import '../controllers/neuro_wellness_controller.dart';
import '../widgets/game_result_dialog.dart';

class _Question {
  final String expression;
  final int answer;
  final List<int> choices;

  _Question({required this.expression, required this.answer, required this.choices});

  factory _Question.random(int difficulty) {
    final rand = Random();
    final maxOperand = 5 + difficulty * 3;
    final a = rand.nextInt(maxOperand) + 1;
    final b = rand.nextInt(maxOperand) + 1;
    final useAddition = rand.nextBool();
    final expression = useAddition ? '$a + $b' : '${a + b} - $b';
    final answer = useAddition ? a + b : a;

    final choices = <int>{answer};
    while (choices.length < 4) {
      final offset = rand.nextInt(9) - 4;
      final candidate = answer + offset;
      if (offset != 0 && candidate >= 0) choices.add(candidate);
    }
    final choiceList = choices.toList()..shuffle();
    return _Question(expression: expression, answer: answer, choices: choiceList);
  }
}

/// Quick arithmetic against the clock — a Lumosity-style speed/attention
/// drill. Same round/Timer structure as the other Neuro Wellness games.
class NumberMatchGameView extends StatefulWidget {
  const NumberMatchGameView({super.key});

  @override
  State<NumberMatchGameView> createState() => _NumberMatchGameViewState();
}

class _NumberMatchGameViewState extends State<NumberMatchGameView> {
  static const int _startRoundMs = 6000;
  static const int _minRoundMs = 2500;

  static const int _tickMs = 100;

  late _Question _question;
  int _correctCount = 0;
  int _roundMs = _startRoundMs;
  int _elapsedMs = 0;
  double _timerProgress = 1.0;
  bool _isGameOver = false;
  int? _selectedChoice;
  Timer? _roundTimer;
  final DateTime _sessionStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nextQuestion();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  void _nextQuestion() {
    setState(() {
      _question = _Question.random(_correctCount);
      _selectedChoice = null;
      _timerProgress = 1.0;
      _elapsedMs = 0;
    });

    // A single merged timer (was a periodic progress-tick Timer plus a
    // separate one-shot timeout Timer before) — one tick now drives both
    // the progress bar and the timeout, so they can never disagree about
    // whether the round has ended, and there's one fewer Timer per round.
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
        _endGame();
        return;
      }
      setState(() {
        _timerProgress = 1 - (_elapsedMs / _roundMs);
      });
    });
  }

  void _onChoiceTap(int choice) {
    if (_isGameOver || _selectedChoice != null) return;
    _roundTimer?.cancel();
    setState(() => _selectedChoice = choice);

    if (choice == _question.answer) {
      _correctCount++;
      _roundMs = (_roundMs - 200).clamp(_minRoundMs, _startRoundMs);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _nextQuestion();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _endGame();
      });
    }
  }

  void _endGame() {
    if (_isGameOver) return;
    _roundTimer?.cancel();
    setState(() => _isGameOver = true);

    if (Get.isRegistered<NeuroWellnessController>()) {
      Get.find<NeuroWellnessController>().recordSession(GameSession(
        gameId: 'number_match',
        score: (_correctCount * 10).clamp(0, 100),
        durationSeconds: DateTime.now().difference(_sessionStart).inSeconds,
        completedAt: DateTime.now(),
      ));
    }

    GameResultDialog.show(
      icon: Icons.calculate_outlined,
      accentColor: Colors.orange[700]!,
      title: "Sharp Thinking!",
      message: "You solved $_correctCount question${_correctCount == 1 ? '' : 's'} correctly.",
      onTryAgain: () {
        setState(() {
          _correctCount = 0;
          _roundMs = _startRoundMs;
          _isGameOver = false;
        });
        _nextQuestion();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Colors.orange[700]!;

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
                  Text("Number Match", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text("Score $_correctCount", style: theme.textTheme.titleSmall?.copyWith(color: accent)),
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
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
            ),
            const Spacer(),
            Text(
              _question.expression,
              style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.4,
                children: _question.choices.map((choice) {
                  final isSelected = _selectedChoice == choice;
                  final isCorrect = choice == _question.answer;
                  Color? bg;
                  if (isSelected) {
                    bg = isCorrect ? Colors.green : Colors.red;
                  }
                  return ElevatedButton(
                    onPressed: () => _onChoiceTap(choice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bg ?? theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: bg != null ? Colors.white : theme.colorScheme.onSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('$choice', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
