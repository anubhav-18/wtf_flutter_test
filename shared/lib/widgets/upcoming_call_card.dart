import 'package:flutter/material.dart';

import '../models/call_request.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/date_formatters.dart';

/// A card showing an approved [CallRequest] with an optional Join button.
///
/// [onJoin] is called when the user taps Join. Pass null to hide the button.
class UpcomingCallCard extends StatelessWidget {
  const UpcomingCallCard({
    super.key,
    required this.request,
    this.onJoin,
    this.peerName = 'Trainer',
  });

  final CallRequest request;
  final VoidCallback? onJoin;
  final String peerName;

  bool get _canJoin {
    final now = DateTime.now();
    final diff = request.scheduledFor.difference(now);
    // Within 10-min window before and up to 10-min after start.
    return diff <= AppConstants.joinWindow &&
        diff >= -AppConstants.joinWindow;
  }

  String _countdownLabel() {
    final now = DateTime.now();
    final diff = request.scheduledFor.difference(now);
    if (diff.isNegative) {
      final past = now.difference(request.scheduledFor);
      if (past < AppConstants.joinWindow) {
        return 'Started ${past.inMinutes}m ago';
      }
      return 'Missed';
    }
    if (diff.inMinutes < 1) return 'Starting now';
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes}m';
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    return m > 0 ? 'In ${h}h ${m}m' : 'In ${h}h';
  }

  @override
  Widget build(BuildContext context) {
    final canJoin = _canJoin;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.video_call_rounded,
                    color: scheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Call with $peerName',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        DateFormatters.dateTime(request.scheduledFor),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _CountdownChip(label: _countdownLabel(), isJoinable: canJoin),
              ],
            ),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                request.note,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (onJoin != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: canJoin ? onJoin : null,
                  icon: const Icon(Icons.videocam_rounded, size: 18),
                  label: const Text('Join Call'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (!canJoin)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Join opens 10 min before the scheduled time.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.muted.withValues(alpha: 0.8),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountdownChip extends StatelessWidget {
  const _CountdownChip({required this.label, required this.isJoinable});

  final String label;
  final bool isJoinable;

  @override
  Widget build(BuildContext context) {
    final color = isJoinable ? AppColors.success : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
