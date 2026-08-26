import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

/// Thin wrapper around the native Android Picture-in-Picture platform channel.
/// No-ops on iOS/other platforms — real OS PiP is Android-only for now.
class PipService {
  static final PipService _instance = PipService._internal();
  factory PipService() => _instance;
  PipService._internal() {
    if (Platform.isAndroid) {
      _channel.setMethodCallHandler(_handleMethodCall);
    }
  }

  static const MethodChannel _channel = MethodChannel('com.livepoised.app/pip');

  final StreamController<bool> _modeChangedController = StreamController<bool>.broadcast();
  Stream<bool> get onModeChanged => _modeChangedController.stream;

  final StreamController<String> _actionController = StreamController<String>.broadcast();
  /// Emits the action id (e.g. 'end_call') when the user taps a control
  /// button rendered directly on the native PiP window.
  Stream<String> get onPipAction => _actionController.stream;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onPipModeChanged') {
      final isInPip = call.arguments as bool? ?? false;
      _modeChangedController.add(isInPip);
    } else if (call.method == 'onPipAction') {
      final action = call.arguments as String?;
      if (action != null) _actionController.add(action);
    }
  }

  Future<bool> isSupported() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isPipSupported') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isPermissionEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isPipPermissionEnabled') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openPipSettings');
    } catch (_) {}
  }

  Future<void> setCallActive(bool active) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('setCallActive', active);
    } catch (_) {}
  }

  Future<bool> enterPip() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('enterPip') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Must be called (and awaited) BEFORE starting screen capture — Android
  /// 14 requires an active mediaProjection-type foreground service to
  /// already be running before MediaProjection capture starts, or the OS
  /// throws a SecurityException that kills the whole app process. See
  /// ScreenShareForegroundService.kt for the native side.
  Future<bool> startScreenShareService() async {
    if (!Platform.isAndroid) return true;
    try {
      return await _channel.invokeMethod<bool>('startScreenShareService') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopScreenShareService() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('stopScreenShareService');
    } catch (_) {}
  }
}
