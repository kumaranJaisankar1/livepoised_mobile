import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/livekit_service.dart';

class FloatingCallOverlay extends StatelessWidget {
  const FloatingCallOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LiveKitService>()) return const SizedBox.shrink();
    final lk = Get.find<LiveKitService>();

    return Obx(() {
      final isConnected = lk.callState.value == callStateConnected;
      final currentRoute = Get.currentRoute;
      final isMinimized = lk.isMinimized.value || (isConnected && currentRoute != '/active-call');

      if (!isConnected || !isMinimized) {
        return const SizedBox.shrink();
      }

      final remoteName = lk.remoteUserFullName.value ?? lk.callerUsername.value ?? 'Call';
      final isVideo = lk.incomingIsVideo.value;
      final topPadding = MediaQuery.of(context).padding.top;

      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            onTap: () {
              lk.isMinimized.value = false;
              if (Get.currentRoute != '/active-call') {
                Get.toNamed('/active-call');
              }
            },
            child: Container(
              padding: EdgeInsets.only(
                top: topPadding + 6,
                bottom: 10,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF0F766E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated / Pulsing Phone Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isVideo ? Icons.videocam : Icons.call,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Call Info (Name & Live Timer)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          remoteName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                              'Tap to return • ${lk.formattedCallDuration}',
                              style: const TextStyle(
                                color: Color(0xFFA7F3D0),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                      ],
                    ),
                  ),

                  // Mute Button
                  Obx(() => IconButton(
                        icon: Icon(
                          lk.isMuted.value ? Icons.mic_off : Icons.mic,
                          color: lk.isMuted.value ? Colors.redAccent : Colors.white,
                          size: 20,
                        ),
                        onPressed: () => lk.toggleMute(),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
                      )),

                  const SizedBox(width: 8),

                  // End Call Button
                  GestureDetector(
                    onTap: () => lk.endCall(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.call_end, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'End',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
