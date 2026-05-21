import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

/// Pre-join device check screen.
///
/// Receives [InCallArgs] via `ModalRoute.settings.arguments`.
/// Shows a camera preview tile and mic/camera toggles.
/// "Join Now" navigates to InCallScreen (replacing itself so back doesn't
/// return to this screen mid-call).
class PreJoinScreen extends ConsumerStatefulWidget {
  const PreJoinScreen({super.key, required this.inCallRoute});

  /// The in-call route to push after the user taps Join.
  final String inCallRoute;

  @override
  ConsumerState<PreJoinScreen> createState() => _PreJoinScreenState();
}

class _PreJoinScreenState extends ConsumerState<PreJoinScreen> {
  bool _micEnabled = true;
  bool _cameraEnabled = true;
  bool _isJoining = false;

  InCallArgs? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = ModalRoute.of(context)?.settings.arguments as InCallArgs?;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Ready to join?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Camera preview placeholder ────────────────────────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: _cameraEnabled
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: const _CameraPreviewPlaceholder(),
                      )
                    : const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam_off_rounded,
                              color: Colors.white38,
                              size: 64,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Camera is off',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Copy from assessment ──────────────────────────────────────
            const Text(
              'Check mic and camera.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),

            const SizedBox(height: 20),

            // ── Device toggle controls ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DeviceButton(
                  icon: _micEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                  label: _micEnabled ? 'Mic On' : 'Mic Off',
                  active: _micEnabled,
                  onTap: () => setState(() => _micEnabled = !_micEnabled),
                ),
                const SizedBox(width: 24),
                _DeviceButton(
                  icon: _cameraEnabled
                      ? Icons.videocam_rounded
                      : Icons.videocam_off_rounded,
                  label: _cameraEnabled ? 'Camera On' : 'Camera Off',
                  active: _cameraEnabled,
                  onTap: () => setState(() => _cameraEnabled = !_cameraEnabled),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Join button ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isJoining ? null : _onJoin,
                  icon: _isJoining
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.videocam_rounded),
                  label: Text(_isJoining ? 'Connecting…' : 'Join Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _onJoin() async {
    if (_args == null) return;
    setState(() => _isJoining = true);
    DevLogService.add('[RTC]', 'pre-join: mic=$_micEnabled cam=$_cameraEnabled');
    // Navigate to in-call — pushReplacement so Back doesn't return here.
    if (!mounted) return;
    await Navigator.of(context).pushReplacementNamed(
      widget.inCallRoute,
      arguments: _args!.copyWith(
        micEnabled: _micEnabled,
        cameraEnabled: _cameraEnabled,
      ),
    );
  }
}

/// Simple animated placeholder when camera permission not yet granted or
/// the real HMSVideoView is not available in pre-join phase.
class _CameraPreviewPlaceholder extends StatelessWidget {
  const _CameraPreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1117),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_rounded, color: Colors.white24, size: 80),
            SizedBox(height: 8),
            Text(
              'You',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// Control button for mic/camera toggle.
class _DeviceButton extends StatelessWidget {
  const _DeviceButton({
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: active ? Colors.white12 : Colors.red.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? Colors.white24 : Colors.red.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : Colors.red,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
