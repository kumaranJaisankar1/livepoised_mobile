import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';
import '../../data/models/game_session.dart';
import '../controllers/neuro_wellness_controller.dart';

class ZenFlowView extends StatefulWidget {
  const ZenFlowView({super.key});

  @override
  State<ZenFlowView> createState() => _ZenFlowViewState();
}

enum BreathingPhase { initial, inhale, hold, exhale }

class _ZenFlowViewState extends State<ZenFlowView> with SingleTickerProviderStateMixin {
  static const int _targetCycles = 5;
  static const String _muteStorageKey = 'zen_flow_muted';

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late final FlutterTts _tts;

  bool _isStarted = false;
  bool _isMuted = false;
  BreathingPhase _currentPhase = BreathingPhase.initial;
  int _countdown = 0;
  int _cyclesCompleted = 0;
  DateTime? _sessionStart;
  Timer? _phaseTimer;
  Timer? _countdownTimer;

  // 4-7-8 method timings
  final int _inhaleDuration = 4;
  final int _holdDuration = 7;
  final int _exhaleDuration = 8;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _isMuted = GetStorage().read<bool>(_muteStorageKey) ?? false;
    _tts = FlutterTts();
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  void _speak(String text) {
    if (_isMuted) return;
    _tts.speak(text);
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    GetStorage().write(_muteStorageKey, _isMuted);
    if (_isMuted) _tts.stop();
  }

  void _startBreathingCycle() {
    setState(() {
      _isStarted = true;
      _cyclesCompleted = 0;
    });
    _sessionStart = DateTime.now();
    _runInhalePhase();
  }

  void _runInhalePhase() {
    if (!mounted) return;
    setState(() {
      _currentPhase = BreathingPhase.inhale;
      _countdown = _inhaleDuration;
    });

    HapticFeedback.lightImpact();
    _speak("Breathe in");
    _controller.duration = Duration(seconds: _inhaleDuration);
    _controller.forward();

    _startCountdownTimer();

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(seconds: _inhaleDuration), () {
      _runHoldPhase();
    });
  }

  void _runHoldPhase() {
    if (!mounted) return;
    setState(() {
      _currentPhase = BreathingPhase.hold;
      _countdown = _holdDuration;
    });

    HapticFeedback.mediumImpact();
    _speak("Hold");

    _startCountdownTimer();

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(seconds: _holdDuration), () {
      _runExhalePhase();
    });
  }

  void _runExhalePhase() {
    if (!mounted) return;
    setState(() {
      _currentPhase = BreathingPhase.exhale;
      _countdown = _exhaleDuration;
    });

    HapticFeedback.lightImpact();
    _speak("Breathe out");
    _controller.duration = Duration(seconds: _exhaleDuration);
    _controller.reverse();

    _startCountdownTimer();

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(seconds: _exhaleDuration), () {
      HapticFeedback.heavyImpact();
      _cyclesCompleted++;
      if (_cyclesCompleted >= _targetCycles) {
        _completeSession();
      } else {
        _runInhalePhase(); // Loop
      }
    });
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 1) {
          _countdown--;
          _speak('$_countdown');
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _stopBreathingCycle() {
    _recordSessionIfStarted();
    setState(() {
      _isStarted = false;
      _currentPhase = BreathingPhase.initial;
      _countdown = 0;
    });
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _tts.stop();
    _controller.stop();
    _controller.reverse(from: _controller.value);
  }

  void _completeSession() {
    _recordSessionIfStarted();
    _speak("Session complete. Well done.");
    setState(() {
      _isStarted = false;
      _currentPhase = BreathingPhase.initial;
      _countdown = 0;
    });
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _controller.reverse(from: _controller.value);
  }

  void _recordSessionIfStarted() {
    if (_sessionStart == null || _cyclesCompleted == 0) return;
    if (Get.isRegistered<NeuroWellnessController>()) {
      Get.find<NeuroWellnessController>().recordSession(GameSession(
        gameId: 'zen_flow',
        score: ((_cyclesCompleted / _targetCycles) * 100).clamp(0, 100).round(),
        durationSeconds: DateTime.now().difference(_sessionStart!).inSeconds,
        completedAt: DateTime.now(),
      ));
    }
    _sessionStart = null;
  }

  String _getPhaseInstruction() {
    switch (_currentPhase) {
      case BreathingPhase.initial:
        return "Tap Start when ready";
      case BreathingPhase.inhale:
        return "Breathe In...";
      case BreathingPhase.hold:
        return "Hold...";
      case BreathingPhase.exhale:
        return "Breathe Out...";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Background
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark 
                    ? [
                        theme.colorScheme.surface,
                        const Color(0xFF1A1525), // Deep purple tint
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFF3E5F5), // Light purple tint
                      ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, theme),
                if (!_isStarted) _buildIntroCard(theme),
                const Spacer(),
                _buildBreathingVisualizer(theme),
                const Spacer(),
                _buildControls(theme),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          Text(
            "Zen Flow",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
          const Spacer(),
          IconButton(
            icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
            tooltip: _isMuted ? 'Unmute voice guidance' : 'Mute voice guidance',
            onPressed: _toggleMute,
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.self_improvement, color: Colors.purple[400], size: 28),
              const SizedBox(width: 12),
              Text(
                "4-7-8 Breathing",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "A powerful rhythmic breathing technique designed to reduce anxiety, aid sleep, and relax the nervous system.",
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildBenefitRow(Icons.air, "Inhale quietly through your nose."),
          const SizedBox(height: 12),
          _buildBenefitRow(Icons.hourglass_empty, "Hold your breath."),
          const SizedBox(height: 12),
          _buildBenefitRow(Icons.wind_power, "Exhale completely through your mouth."),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.purple[300]),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildBreathingVisualizer(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple[300]!.withOpacity(0.8),
                      Colors.purple[500]!.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.4, 0.8, 1.0],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 60),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: ValueKey<BreathingPhase>(_currentPhase),
            children: [
              Text(
                _getPhaseInstruction(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                ),
              ),
              if (_isStarted) ...[
                const SizedBox(height: 8),
                Text(
                  "$_countdown",
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[400],
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(ThemeData theme) {
    return _isStarted
        ? TextButton.icon(
            onPressed: _stopBreathingCycle,
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.grey),
            label: const Text("Stop Session", style: TextStyle(color: Colors.grey)),
          )
        : ElevatedButton(
            onPressed: _startBreathingCycle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: Colors.purple.withOpacity(0.5),
            ),
            child: const Text(
              "Begin Zen Flow",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
          );
  }
}
