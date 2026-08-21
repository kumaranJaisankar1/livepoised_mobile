import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../data/livekit_service.dart';

class FloatingCallOverlay extends StatelessWidget {
  const FloatingCallOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LiveKitService>()) return const SizedBox.shrink();
    final lk = Get.find<LiveKitService>();

    return Obx(() {
      final isConnected = lk.callState.value == callStateConnected;
      final isMinimized = lk.isMinimized.value;

      if (!isConnected || !isMinimized) {
        return const SizedBox.shrink();
      }

      final remoteName = lk.remoteUserFullName.value ?? lk.callerUsername.value ?? 'Call';
      final hasRemoteVideo = lk.remoteVideoTrack.value != null;

      return Positioned(
        right: 16,
        bottom: 80,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: 200,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: Colors.tealAccent, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  if (hasRemoteVideo)
                    Positioned.fill(
                      child: VideoTrackRenderer(lk.remoteVideoTrack.value!),
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            remoteName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                                lk.formattedCallDuration,
                                style: const TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.w600),
                              )),
                        ],
                      ),
                    ),

                  // Top Action (Expand to Full Screen)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.aspect_ratio, color: Colors.white, size: 16),
                        onPressed: () => lk.toggleMinimize(),
                        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // Bottom Call Controls (Mute & End Call)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              lk.isMuted.value ? Icons.mic_off : Icons.mic,
                              color: lk.isMuted.value ? Colors.redAccent : Colors.white,
                              size: 16,
                            ),
                            onPressed: () => lk.toggleMute(),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.call_end, color: Colors.white, size: 16),
                            onPressed: () => lk.endCall(),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
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
