import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class TrainerRequestsScreen extends ConsumerWidget {
  const TrainerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(callRequestsStreamProvider).value ?? [];
    final trainerRequests =
        requests
            .where((request) => request.trainerId == AppConstants.trainerId)
            .toList()
          ..sort(_sortRequests);

    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: trainerRequests.isEmpty
          ? const EmptyState(
              title: 'No call requests yet.',
              actionLabel: 'Back to dashboard',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return _TrainerRequestCard(request: trainerRequests[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: trainerRequests.length,
            ),
    );
  }

  int _sortRequests(CallRequest a, CallRequest b) {
    if (a.status == CallRequestStatus.pending &&
        b.status != CallRequestStatus.pending) {
      return -1;
    }
    if (a.status != CallRequestStatus.pending &&
        b.status == CallRequestStatus.pending) {
      return 1;
    }
    return a.scheduledFor.compareTo(b.scheduledFor);
  }
}

class _TrainerRequestCard extends ConsumerWidget {
  const _TrainerRequestCard({required this.request});

  final CallRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = request.status == CallRequestStatus.pending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Text('DK')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DK',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(DateFormatters.dateTime(request.scheduledFor)),
                    ],
                  ),
                ),
                _StatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(request.note.isEmpty ? 'No note added.' : request.note),
            const SizedBox(height: 8),
            Text(
              'Requested ${DateFormatters.relative(request.requestedAt)}',
              style: const TextStyle(color: AppColors.muted),
            ),
            if (request.declineReason != null &&
                request.declineReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Declined reason: ${request.declineReason}',
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _decline(context, ref),
                      icon: const Icon(Icons.close),
                      label: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _approve(context, ref),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final error = await ref.read(callServiceProvider).approve(request.id);
    if (!context.mounted) {
      return;
    }
    AppFeedback.showSnackBar(
      context, 
      error ?? 'Request approved.',
      isError: error != null,
    );
  }

  Future<void> _decline(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _DeclineDialog(),
    );
    if (reason == null) {
      return;
    }
    await ref.read(callServiceProvider).decline(request.id, reason);
    if (!context.mounted) {
      return;
    }
    AppFeedback.showSnackBar(context, 'Request declined.');
  }
}

class _DeclineDialog extends StatefulWidget {
  const _DeclineDialog();

  @override
  State<_DeclineDialog> createState() => _DeclineDialogState();
}

class _DeclineDialogState extends State<_DeclineDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Decline request'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Share a short reason',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              return;
            }
            Navigator.of(context).pop(reason);
          },
          child: const Text('Decline'),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final CallRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      CallRequestStatus.pending => Colors.orange,
      CallRequestStatus.approved => AppColors.success,
      CallRequestStatus.declined => AppColors.error,
      CallRequestStatus.cancelled => AppColors.muted,
      CallRequestStatus.completed => Colors.blueGrey,
    };

    return Chip(
      label: Text(status.name),
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color),
    );
  }
}
