import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../../core/utils/image_utils.dart';
import '../../data/livekit_service.dart';

class ActiveCallView extends StatelessWidget {
  const ActiveCallView({super.key});

  @override
  Widget build(BuildContext context) {
    final LiveKitService lk = Get.find<LiveKitService>();

    return Obx(() {
      final isMinimized = lk.isMinimized.value;

      return Scaffold(
        backgroundColor: isMinimized ? Colors.transparent : const Color(0xFF0F172A),
        body: SafeArea(
          child: isMinimized
              ? _buildMinimizedOverlay(context, lk)
              : Stack(
                  children: [
                    // Main Content (Video if remote video/screen share is active, else Dual Avatar Voice Display)
                    Positioned.fill(
                      child: (lk.remoteVideoTrack.value != null || lk.screenShareTrack.value != null)
                          ? _buildVideoDisplay(lk)
                          : _buildDualAvatarVoiceDisplay(lk),
                    ),

                    // Local Camera PiP overlay when video display is NOT active (Voice view) but local camera is ON
                    if ((lk.remoteVideoTrack.value == null && lk.screenShareTrack.value == null) &&
                        !lk.isVideoOff.value &&
                        lk.localVideoTrack.value != null)
                      Positioned(
                        right: 16,
                        top: 80,
                        width: 110,
                        height: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.tealAccent, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black,
                            ),
                            child: VideoTrackRenderer(lk.localVideoTrack.value!),
                          ),
                        ),
                      ),

                    // Top Bar (Caller Title, Connection Quality, Minimize PiP Button)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: _buildTopHeader(context, lk),
                    ),

                    // Floating Emojis Layer
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Obx(() {
                          return Stack(
                            children: lk.floatingEmojis.map((e) {
                              return Positioned(
                                bottom: 120 + (lk.floatingEmojis.indexOf(e) * 40).toDouble(),
                                right: 24,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: 0.9,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(e.emoji, style: const TextStyle(fontSize: 28)),
                                        const SizedBox(width: 6),
                                        Text(
                                          e.sender,
                                          style: const TextStyle(color: Colors.white, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ),
                    ),

                    // Bottom Call Control Bar
                    Positioned(
                      bottom: 24,
                      left: 16,
                      right: 16,
                      child: _buildBottomControlBar(context, lk),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  // ── Top Header Widget ──────────────────────────────────────────────────
  Widget _buildTopHeader(BuildContext context, LiveKitService lk) {
    final remoteName = lk.remoteUserFullName.value ?? lk.callerUsername.value ?? 'Peer';
    final quality = lk.connectionQuality.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.open_in_full, color: Colors.white, size: 20),
                onPressed: () => lk.toggleMinimize(),
                tooltip: 'Minimize call',
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    remoteName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: quality == 'excellent' ? Colors.greenAccent : Colors.amberAccent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Obx(() {
                        return Text(
                          '${quality.toUpperCase()} • ${lk.formattedCallDuration}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Obx(() {
            final isNC = lk.isNoiseCancellationOn.value;
            return Chip(
              avatar: Icon(
                isNC ? Icons.noise_control_off : Icons.graphic_eq,
                color: isNC ? Colors.tealAccent : Colors.white54,
                size: 16,
              ),
              label: Text(
                isNC ? 'NC ON' : 'NC OFF',
                style: TextStyle(
                  color: isNC ? Colors.tealAccent : Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.black45,
            );
          }),
        ],
      ),
    );
  }

  // ── Video Display Widget ──────────────────────────────────────────────
  Widget _buildVideoDisplay(LiveKitService lk) {
    return Obx(() {
      final remoteTrack = lk.remoteVideoTrack.value;
      final screenTrack = lk.screenShareTrack.value;
      final localTrack = lk.localVideoTrack.value;

      final mainVideoTrack = screenTrack ?? remoteTrack;

      return Stack(
        children: [
          // Main Remote Video or Screen Share Stream (or Dual Avatars if muted)
          Positioned.fill(
            child: mainVideoTrack != null
                ? VideoTrackRenderer(mainVideoTrack)
                : _buildDualAvatarVoiceDisplay(lk),
          ),

          // Local Camera PiP Overlay
          if (localTrack != null)
            Positioned(
              right: 16,
              top: 80,
              width: 110,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.tealAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black,
                  ),
                  child: VideoTrackRenderer(localTrack),
                ),
              ),
            ),
        ],
      );
    });
  }

  // ── Dual Profile Picture Voice Display ─────────────────────────────────
  Widget _buildDualAvatarVoiceDisplay(LiveKitService lk) {
    final localPic = lk.localUserProfileImage.value;
    final localName = lk.localUserFullName.value ?? 'You';
    final remotePic = lk.remoteUserProfileImage.value;
    final remoteName = lk.remoteUserFullName.value ?? lk.callerUsername.value ?? 'Peer';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Local User Avatar (You)
              Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundImage: ImageUtils.getImageProvider(localPic),
                    child: (localPic == null || localPic.isEmpty)
                        ? Text(
                            localName.isNotEmpty ? localName[0].toUpperCase() : 'Y',
                            style: const TextStyle(fontSize: 32, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  const Text("You", style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),

              const SizedBox(width: 24),
              const Icon(Icons.graphic_eq, color: Colors.tealAccent, size: 36),
              const SizedBox(width: 24),

              // Remote Peer Avatar
              Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundImage: ImageUtils.getImageProvider(remotePic),
                    child: (remotePic == null || remotePic.isEmpty)
                        ? Text(
                            remoteName.isNotEmpty ? remoteName[0].toUpperCase() : 'P',
                            style: const TextStyle(fontSize: 32, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    remoteName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            remoteName,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Obx(() {
            final isCalling = lk.callState.value == callStateCalling;
            final label = lk.incomingIsVideo.value ? 'Video Call' : 'Voice Call';
            return Text(
              isCalling ? "Calling..." : "$label • ${lk.formattedCallDuration}",
              style: const TextStyle(color: Colors.tealAccent, fontSize: 14, fontWeight: FontWeight.w500),
            );
          }),
        ],
      ),
    );
  }

  // ── Minimized PiP View Widget ──────────────────────────────────────────
  Widget _buildMinimizedOverlay(BuildContext context, LiveKitService lk) {
    final remoteName = lk.remoteUserFullName.value ?? lk.callerUsername.value ?? 'Call';
    final hasRemoteVideo = lk.remoteVideoTrack.value != null;

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 40),
        child: Container(
          width: 200,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
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

                // Top Bar Action (Expand)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
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
                          color: Colors.black.withOpacity(0.6),
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
  }

  // ── Bottom Call Controls Widget ────────────────────────────────────────
  Widget _buildBottomControlBar(BuildContext context, LiveKitService lk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone Toggle
          IconButton(
            icon: Icon(
              lk.isMuted.value ? Icons.mic_off : Icons.mic,
              color: lk.isMuted.value ? Colors.redAccent : Colors.white,
            ),
            onPressed: () => lk.toggleMute(),
            tooltip: 'Mute/Unmute',
          ),

          // Camera Toggle
          IconButton(
            icon: Icon(
              lk.isVideoOff.value ? Icons.videocam_off : Icons.videocam,
              color: lk.isVideoOff.value ? Colors.redAccent : Colors.white,
            ),
            onPressed: () => lk.toggleVideo(),
            tooltip: 'Camera On/Off',
          ),

          // Audio Device Output Selector (Speaker / Earpiece / Bluetooth)
          IconButton(
            icon: Icon(
              lk.activeAudioDevice.value.toLowerCase().contains('speaker')
                  ? Icons.volume_up
                  : (lk.activeAudioDevice.value.toLowerCase().contains('bluetooth')
                      ? Icons.bluetooth_audio
                      : Icons.phone_in_talk),
              color: Colors.white,
            ),
            onPressed: () => _showAudioDeviceSelector(context, lk),
            tooltip: 'Audio Output (${lk.activeAudioDevice.value})',
          ),

          // Hardware Noise Cancellation Toggle
          IconButton(
            icon: Icon(
              lk.isNoiseCancellationOn.value ? Icons.noise_control_off : Icons.graphic_eq,
              color: lk.isNoiseCancellationOn.value ? Colors.tealAccent : Colors.white54,
            ),
            onPressed: () => lk.toggleNoiseCancellation(),
            tooltip: 'Toggle Noise Cancellation',
          ),

          // Screen Share Toggle
          IconButton(
            icon: Icon(
              lk.isScreenSharing.value ? Icons.stop_screen_share : Icons.screen_share,
              color: lk.isScreenSharing.value ? Colors.tealAccent : Colors.white,
            ),
            onPressed: () => lk.toggleScreenShare(),
            tooltip: 'Screen Share',
          ),

          // Floating Emoji Reactions Picker
          PopupMenuButton<String>(
            icon: const Icon(Icons.sentiment_satisfied_alt, color: Colors.amberAccent),
            onSelected: (emoji) => lk.sendEmoji(emoji),
            itemBuilder: (context) => [
              const PopupMenuItem(value: '❤️', child: Text('❤️ Love')),
              const PopupMenuItem(value: '👍', child: Text('👍 Like')),
              const PopupMenuItem(value: '👏', child: Text('👏 Clap')),
              const PopupMenuItem(value: '🔥', child: Text('🔥 Fire')),
              const PopupMenuItem(value: '🎉', child: Text('🎉 Party')),
            ],
          ),

          // End Call Button (Red FAB)
          FloatingActionButton.small(
            heroTag: 'end_call_fab',
            onPressed: () => lk.endCall(),
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.call_end, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  void _showAudioDeviceSelector(BuildContext context, LiveKitService lk) async {
    await lk.fetchAudioDevices();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Audio Output Device",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final devices = lk.availableAudioDevices;
                  if (devices.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Icon(Icons.speaker_phone, color: Colors.tealAccent),
                          SizedBox(width: 12),
                          Text("Speakerphone Active", style: TextStyle(color: Colors.white70, fontSize: 15)),
                        ],
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: devices.map((d) {
                      final name = d.label.isNotEmpty ? d.label : 'Audio Device';
                      final isSelected = lk.activeAudioDevice.value == name;
                      IconData iconData = Icons.speaker_phone;
                      if (name.toLowerCase().contains('bluetooth')) {
                        iconData = Icons.bluetooth;
                      } else if (name.toLowerCase().contains('earpiece') || name.toLowerCase().contains('phone')) {
                        iconData = Icons.phone_in_talk;
                      } else if (name.toLowerCase().contains('headset') || name.toLowerCase().contains('headphone')) {
                        iconData = Icons.headphones;
                      }

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(iconData, color: isSelected ? Colors.tealAccent : Colors.white70),
                        title: Text(
                          name,
                          style: TextStyle(
                            color: isSelected ? Colors.tealAccent : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.tealAccent) : null,
                        onTap: () {
                          lk.selectAudioDevice(d);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
