import 'package:flutter/material.dart';
import '../../services/neuro_reminder_service.dart';

/// Daily reminder toggle + time picker. Shared between the Settings screen
/// and the Neuro Wellness lobby itself so both surfaces always show the same
/// state — both just read/write the same `NeuroReminderService` (backed by
/// GetStorage), so there's nothing to keep "in sync" beyond using this one
/// widget in both places rather than two separate implementations.
class NeuroReminderTile extends StatefulWidget {
  const NeuroReminderTile({super.key});

  @override
  State<NeuroReminderTile> createState() => _NeuroReminderTileState();
}

class _NeuroReminderTileState extends State<NeuroReminderTile> {
  final _service = NeuroReminderService();
  late bool _enabled;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _enabled = _service.isEnabled;
    _time = _service.scheduledTime;
  }

  Future<void> _onToggle(bool value) async {
    setState(() => _enabled = value);
    if (value) {
      await _service.setReminder(_time);
    } else {
      await _service.cancelReminder();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    setState(() => _time = picked);
    if (_enabled) {
      await _service.setReminder(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SwitchListTile(
          secondary: Icon(Icons.psychology_alt_outlined, color: theme.colorScheme.primary),
          title: const Text('Daily Brain Training Reminder'),
          subtitle: const Text('A nudge to keep your Neuro Wellness streak alive'),
          value: _enabled,
          activeColor: theme.colorScheme.primary,
          onChanged: _onToggle,
        ),
        if (_enabled)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 72, right: 16),
            title: const Text('Reminder Time'),
            subtitle: Text(_time.format(context)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: _pickTime,
          ),
      ],
    );
  }
}
