import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/neuro_wellness_controller.dart';
import '../widgets/neuro_reminder_tile.dart';

class NeuroWellnessLobbyView extends GetView<NeuroWellnessController> {
  const NeuroWellnessLobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Ensure controller is initialized
    if (!Get.isRegistered<NeuroWellnessController>()) {
      Get.put(NeuroWellnessController());
    }

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
          // Pattern Overlay (Subtle Brand Pattern)
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsHeader(theme),
                        const SizedBox(height: 32),
                        Text(
                          "DAILY CHALLENGES", 
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1.2, 
                            color: theme.colorScheme.primary
                          )
                        ),
                        const Divider(height: 24),
                        const SizedBox(height: 12),
                        _buildGameCard(
                          context,
                          id: 'memory_recall',
                          title: "Memory Recalibration",
                          subtitle: "Improve short-term recall and focus.",
                          icon: Icons.psychology_outlined,
                          color: Colors.blue,
                          isAvailable: true,
                        ),
                        const SizedBox(height: 16),
                        _buildGameCard(
                          context,
                          id: 'zen_flow',
                          title: "Zen Flow",
                          subtitle: "Deep breathing and grounding exercises.",
                          icon: Icons.self_improvement_outlined,
                          color: Colors.purple,
                          isAvailable: true,
                        ),
                        const SizedBox(height: 16),
                        _buildGameCard(
                          context,
                          id: 'fog_clearer',
                          title: "Fog Clearer",
                          subtitle: "Boost visual scanning and processing speed.",
                          icon: Icons.wb_cloudy_outlined,
                          color: Colors.teal,
                          isAvailable: true,
                        ),
                        const SizedBox(height: 16),
                        _buildGameCard(
                          context,
                          id: 'number_match',
                          title: "Number Match",
                          subtitle: "Quick arithmetic against the clock.",
                          icon: Icons.calculate_outlined,
                          color: Colors.orange,
                          isAvailable: true,
                        ),
                        const SizedBox(height: 16),
                        _buildGameCard(
                          context,
                          id: 'reaction_time',
                          title: "Focus Tap",
                          subtitle: "Test and train your reaction speed.",
                          icon: Icons.touch_app_outlined,
                          color: Colors.pink,
                          isAvailable: true,
                        ),
                        const SizedBox(height: 120), // Navigator buffer
                      ],
                    ),
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Neuro Wellness",
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton.icon(
            onPressed: () => _showReminderDialog(context),
            icon: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary, size: 20),
            label: Text(
              "Reminder",
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    final theme = Theme.of(context);
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        // Material (not a plain decorated Container) so NeuroReminderTile's
        // ListTile/SwitchListTile can paint their background/ink splashes
        // correctly — a DecoratedBox sitting between a ListTile and its
        // Material ancestor hides those effects (Flutter warns about this
        // explicitly), and Material's own elevation gives the same shadow.
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 8, 4),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Daily Reminder",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              // Same widget as Settings > Neuro Wellness — both read/write
              // the same NeuroReminderService state, so toggling it here or
              // in Settings always agrees.
              const NeuroReminderTile(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(ThemeData theme) {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(theme, "Daily Streak", "${controller.streak.value}", Icons.local_fire_department, Colors.orange),
              _buildStatItem(theme, "Brain Power", "${controller.brainPower.value}%", Icons.bolt, Colors.yellow[700]!),
            ],
          ),
        ));
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, {required String id, required String title, required String subtitle, required IconData icon, required Color color, bool isAvailable = true}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => controller.startGame(id),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                ],
              ),
            ),
            if (!isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("SOON", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              )
            else
              Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.primary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
