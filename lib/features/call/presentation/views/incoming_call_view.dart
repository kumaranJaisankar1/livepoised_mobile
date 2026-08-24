import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/image_utils.dart';
import '../../data/livekit_service.dart';

class IncomingCallView extends StatelessWidget {
  const IncomingCallView({super.key});

  String _formatName(String? raw) {
    if (raw == null || raw.trim().isEmpty || raw == 'Incoming Call') return 'Incoming Call';
    final name = raw.trim();
    if (name.contains(' ')) {
      return name.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    }
    if (name.contains('.')) {
      return name.split('.').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    }
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final LiveKitService lk = Get.find<LiveKitService>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Obx(() {
          final rawName = lk.remoteUserFullName.value ?? lk.callerUsername.value;
          final callerName = _formatName(rawName);
          final callerPic = lk.remoteUserProfileImage.value;
          final isVideo = lk.incomingIsVideo.value;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header Info
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      isVideo ? "INCOMING VIDEO CALL" : "INCOMING VOICE CALL",
                      style: const TextStyle(
                        color: Colors.tealAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      callerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Live Poised Calling...",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                // Center Avatar with Glowing Ring Effect
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal.withOpacity(0.15),
                        ),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal.withOpacity(0.3),
                        ),
                      ),
                      CircleAvatar(
                        radius: 56,
                        backgroundImage: ImageUtils.getImageProvider(callerPic),
                        child: (callerPic == null || callerPic.isEmpty)
                            ? Text(
                                callerName.isNotEmpty ? callerName[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 42, color: Colors.white),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),

                // Bottom Action Buttons (Decline & Accept)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decline Button
                    Column(
                      children: [
                        FloatingActionButton.large(
                          heroTag: 'decline_call_fab',
                          onPressed: () => lk.declineCall(),
                          backgroundColor: Colors.redAccent,
                          shape: const CircleBorder(),
                          child: const Icon(Icons.call_end, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Decline",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),

                    // Accept Button
                    Column(
                      children: [
                        FloatingActionButton.large(
                          heroTag: 'accept_call_fab',
                          onPressed: () => lk.acceptCall(),
                          backgroundColor: Colors.greenAccent.shade700,
                          shape: const CircleBorder(),
                          child: Icon(
                            isVideo ? Icons.videocam : Icons.call,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Accept",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
