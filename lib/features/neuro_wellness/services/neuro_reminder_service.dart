import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/timezone.dart' as tz;

/// Local daily reminder to play a Neuro Wellness game. Entirely on-device —
/// no backend involvement, no server load, works offline. Reuses the single
/// shared `FlutterLocalNotificationsPlugin` instance already initialized
/// app-wide in `PushNotificationService` (with `handleNotificationResponse`/
/// `notificationTapBackground` already registered as its callbacks) rather
/// than creating a second `.initialize()` call, which would silently
/// clobber those callbacks — a real, previously-fixed bug in this app.
class NeuroReminderService {
  static const int _notificationId = 7777;
  static const String _keyEnabled = 'neuro_reminder_enabled';
  static const String _keyHour = 'neuro_reminder_hour';
  static const String _keyMinute = 'neuro_reminder_minute';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final GetStorage _storage = GetStorage();

  bool get isEnabled => _storage.read<bool>(_keyEnabled) ?? false;

  TimeOfDay get scheduledTime => TimeOfDay(
        hour: _storage.read<int>(_keyHour) ?? 19,
        minute: _storage.read<int>(_keyMinute) ?? 0,
      );

  Future<void> setReminder(TimeOfDay time) async {
    await _storage.write(_keyEnabled, true);
    await _storage.write(_keyHour, time.hour);
    await _storage.write(_keyMinute, time.minute);
    await _schedule(time);
  }

  Future<void> cancelReminder() async {
    await _storage.write(_keyEnabled, false);
    await _plugin.cancel(_notificationId);
  }

  /// Re-arms the reminder on app start if it's enabled — Android clears
  /// exact alarms on reboot, and this is a cheap no-op otherwise.
  Future<void> restoreIfEnabled() async {
    if (isEnabled) {
      await _schedule(scheduledTime);
    }
  }

  Future<void> _schedule(TimeOfDay time) async {
    await _plugin.cancel(_notificationId);

    final scheduledDate = _nextInstanceOf(time);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'neuro_wellness_reminder_channel',
        'Neuro Wellness Reminders',
        channelDescription: 'Daily reminder to play a Neuro Wellness brain-training game',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher_monochrome',
        color: Color(0xFF0F766E),
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      _notificationId,
      '🧠 Time for your daily brain training!',
      '🔥 A few minutes of Neuro Wellness keeps your streak alive.',
      scheduledDate,
      details,
      payload: jsonEncode({'type': 'NEURO_REMINDER'}),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
