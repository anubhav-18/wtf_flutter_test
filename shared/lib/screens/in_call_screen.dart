import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:wtf_shared/wtf_shared.dart';

/// In-call screen shared between Guru and Trainer apps.
///
/// Receives [InCallArgs] via `ModalRoute.settings.arguments`.
/// [postCallRoute] is the route name of the post-call sheet to push on end.
class InCallScreen extends ConsumerStatefulWidget {
  const InCallScreen({
    super.key,
    required this.userId,
    required this.postCallRoute,
  });

  final String userId;
  final String postCallRoute;

  @override
  ConsumerState<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends ConsumerState<InCallScreen> {
  InCallArgs? _args;
  DateTime? _joinedAt;
  Timer? _durationTimer;
  int _elapsedSec = 0;
  bool _isEndingCall = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      _args = ModalRoute.of(context)?.settings.arguments as InCallArgs?;
      if (_args != null) {
        _startCall();
      }
    }
  }

  Future<void> _startCall() async {
    _joinedAt = DateTime.now();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSec++);
    });

    final hms = ref.read(hmsServiceProvider);
    // Honour device state from pre-join.
    if (!(_args?.micEnabled ?? true)) hms.toggleMic();
    if (!(_args?.cameraEnabled ?? true)) hms.toggleCamera();

    await hms.join(
      userId: widget.userId,
      role: _args!.role,
    );
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  String get _durationLabel {
    final m = _elapsedSec ~/ 60;
    final s = _elapsedSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _endCall() async {
    if (_isEndingCall) return;
    setState(() => _isEndingCall = true);
    _durationTimer?.cancel();

    final hms = ref.read(hmsServiceProvider);
    await hms.leave();

    final endedAt = DateTime.now();
    final log = await ref.read(logServiceProvider).createFromCall(
          startedAt: _joinedAt ?? endedAt,
          endedAt: endedAt,
        );
    DevLogService.add('[RTC]', 'Session ended — log ${log.id}');

    if (!mounted) return;

    // "Session saved to your logs." snackbar per assessment copy.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session saved to your logs.')),
    );

    // Navigate to post-call sheet, passing the log ID.
    await Navigator.of(context).pushReplacementNamed(
      widget.postCallRoute,
      arguments: log,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hmsState = ref.watch(hmsStateProvider).when(
      data: (s) => s,
      loading: () => const HmsRoomState(isConnecting: true),
      error: (error, stack) => const HmsRoomState(isConnecting: false),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Remote video (full screen) ──────────────────────────────────
          _RemoteVideoTile(remotePeer: hmsState.remotePeer),

          // ── Self preview (picture-in-picture) ──────────────────────────
          Positioned(
            top: 60,
            right: 16,
            child: _SelfPreviewTile(
              localPeer: hmsState.localPeer,
              cameraEnabled: hmsState.isCameraEnabled,
            ),
          ),

          // ── Status overlays ─────────────────────────────────────────────
          if (hmsState.isConnecting || hmsState.isReconnecting)
            _StatusOverlay(
              message: hmsState.isReconnecting
                  ? 'Reconnecting…'
                  : 'Connecting…',
            ),

          if (hmsState.error != null && !hmsState.isConnecting)
            _ErrorOverlay(
              message: hmsState.error!,
              onDismiss: _endCall,
            ),

          // ── Duration badge ──────────────────────────────────────────────
          if (hmsState.isJoined)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _durationLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),

          // ── Control bar ─────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _ControlBar(
              isMicEnabled: hmsState.isMicEnabled,
              isCameraEnabled: hmsState.isCameraEnabled,
              isEndingCall: _isEndingCall,
              onToggleMic: () => ref.read(hmsServiceProvider).toggleMic(),
              onToggleCamera: () =>
                  ref.read(hmsServiceProvider).toggleCamera(),
              onSwitchCamera: () =>
                  ref.read(hmsServiceProvider).switchCamera(),
              onEnd: _endCall,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _RemoteVideoTile extends StatelessWidget {
  const _RemoteVideoTile({this.remotePeer});

  final HMSPeer? remotePeer;

  @override
  Widget build(BuildContext context) {
    if (remotePeer == null) {
      return Container(
        color: const Color(0xFF0D1117),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white24, size: 56),
              ),
              const SizedBox(height: 16),
              const Text(
                'Waiting for peer…',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Show avatar if peer has no video track or camera is off.
    final videoTrack = remotePeer?.videoTrack;
    if (videoTrack == null || videoTrack.isMute) {
      return Container(
        color: const Color(0xFF0D1117),
        child: Center(
          child: Text(
            remotePeer?.name.substring(0, 1).toUpperCase() ?? '?',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 72,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return HMSVideoView(
      track: videoTrack!,
      scaleType: ScaleType.SCALE_ASPECT_FILL,
    );
  }
}

class _SelfPreviewTile extends StatelessWidget {
  const _SelfPreviewTile({
    this.localPeer,
    required this.cameraEnabled,
  });

  final HMSPeer? localPeer;
  final bool cameraEnabled;

  @override
  Widget build(BuildContext context) {
    final videoTrack = localPeer?.videoTrack;
    return Container(
      width: 90,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      clipBehavior: Clip.hardEdge,
      child: (!cameraEnabled || videoTrack == null)
          ? const Center(
              child: Icon(Icons.person_rounded, color: Colors.white38, size: 36),
            )
          : HMSVideoView(
              track: videoTrack,
              scaleType: ScaleType.SCALE_ASPECT_FILL,
            ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.isMicEnabled,
    required this.isCameraEnabled,
    required this.isEndingCall,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onSwitchCamera,
    required this.onEnd,
  });

  final bool isMicEnabled;
  final bool isCameraEnabled;
  final bool isEndingCall;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onSwitchCamera;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CtrlBtn(
            icon: isMicEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
            label: isMicEnabled ? 'Mute' : 'Unmute',
            active: isMicEnabled,
            onTap: onToggleMic,
          ),
          _CtrlBtn(
            icon: isCameraEnabled
                ? Icons.videocam_rounded
                : Icons.videocam_off_rounded,
            label: isCameraEnabled ? 'Camera' : 'Cam Off',
            active: isCameraEnabled,
            onTap: onToggleCamera,
          ),
          _CtrlBtn(
            icon: Icons.flip_camera_android_rounded,
            label: 'Flip',
            active: true,
            onTap: onSwitchCamera,
          ),
          // End call button.
          GestureDetector(
            onTap: isEndingCall ? null : onEnd,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: isEndingCall
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'End',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active ? Colors.white12 : Colors.red.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? Colors.white24 : Colors.red.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : Colors.redAccent,
              size: 22,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 56),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onDismiss,
                icon: const Icon(Icons.call_end_rounded),
                label: const Text('Leave'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
