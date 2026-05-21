import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

enum SessionFilter { all, last7, thisMonth }

class SessionLogsScreen extends ConsumerStatefulWidget {
  const SessionLogsScreen({super.key});

  @override
  ConsumerState<SessionLogsScreen> createState() => _SessionLogsScreenState();
}

class _SessionLogsScreenState extends ConsumerState<SessionLogsScreen> {
  SessionFilter _filter = SessionFilter.all;

  @override
  Widget build(BuildContext context) {
    final allLogs = ref.watch(sessionLogsStreamProvider).value ?? [];
    final logService = ref.read(logServiceProvider);
    final logs = switch (_filter) {
      SessionFilter.all => allLogs,
      SessionFilter.last7 => logService.filterLast7Days(allLogs),
      SessionFilter.thisMonth => logService.filterThisMonth(allLogs),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('My Sessions')),
      body: Column(
        children: [
          // ── Filter chips ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == SessionFilter.all,
                  onTap: () => setState(() => _filter = SessionFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Last 7 days',
                  selected: _filter == SessionFilter.last7,
                  onTap: () => setState(() => _filter = SessionFilter.last7),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'This month',
                  selected: _filter == SessionFilter.thisMonth,
                  onTap: () => setState(() => _filter = SessionFilter.thisMonth),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Log list ──────────────────────────────────────────────────
          Expanded(
            child: logs.isEmpty
                ? const EmptyState(
                    title: 'No sessions yet.',
                    subtitle: 'Complete a call to see your session history.',
                    icon: Icons.history_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _SessionLogCard(
                      log: logs[index],
                      onTap: () => _showDetail(context, logs[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, SessionLog log) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SessionLogDetailModal(log: log),
    );
  }
}

// ── Log card ─────────────────────────────────────────────────────────────────

class _SessionLogCard extends StatelessWidget {
  const _SessionLogCard({required this.log, required this.onTap});

  final SessionLog log;
  final VoidCallback onTap;

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.videocam_rounded,
                  color: scheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatters.dateTime(log.startedAt),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Duration: ${_formatDuration(log.durationSec)}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (log.rating != null) ...[
                Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 3),
                Text(
                  '${log.rating}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Detail modal ──────────────────────────────────────────────────────────────

class _SessionLogDetailModal extends StatelessWidget {
  const _SessionLogDetailModal({required this.log});

  final SessionLog log;

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            // ── Handle ─────────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Session Detail',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            _DetailRow(label: 'Date', value: DateFormatters.dateTime(log.startedAt)),
            _DetailRow(
                label: 'Duration', value: _formatDuration(log.durationSec)),
            _DetailRow(
              label: 'Rating',
              value: log.rating != null ? '${'★' * log.rating!} (${log.rating}/5)' : 'Not rated',
            ),
            if (log.memberNotes != null && log.memberNotes!.isNotEmpty)
              _DetailRow(label: 'My Notes', value: log.memberNotes!),
            if (log.trainerNotes != null && log.trainerNotes!.isNotEmpty)
              _DetailRow(
                  label: 'Trainer Notes', value: log.trainerNotes!),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? scheme.primary : AppColors.muted.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? scheme.primary : AppColors.muted,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
