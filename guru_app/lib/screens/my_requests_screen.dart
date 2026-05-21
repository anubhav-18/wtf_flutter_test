import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(callRequestsStreamProvider).value ?? [];
    final myRequests = requests
        .where((request) => request.memberId == AppConstants.memberId)
        .toList()
      ..sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));

    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: myRequests.isEmpty
          ? const EmptyState(
              title: 'No call requests yet.',
              actionLabel: 'Schedule a call',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return _RequestCard(request: myRequests[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: myRequests.length,
            ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final CallRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormatters.dateTime(request.scheduledFor),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.note.isEmpty ? 'No note added.' : request.note,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Text('Requested ${DateFormatters.relative(request.requestedAt)}'),
            if (request.status == CallRequestStatus.declined &&
                request.declineReason != null &&
                request.declineReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Declined reason: ${request.declineReason}',
                style: const TextStyle(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
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
    };

    return Chip(
      label: Text(status.name),
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color),
    );
  }
}
