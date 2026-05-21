import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class TrainerUpcomingCallsScreen extends ConsumerWidget {
  const TrainerUpcomingCallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(callRequestsStreamProvider).value ?? [];
    final upcoming = requests
        .where(
          (r) =>
              r.status == CallRequestStatus.approved &&
              r.trainerId == AppConstants.trainerId,
        )
        .toList()
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Calls')),
      body: upcoming.isEmpty
          ? const EmptyState(
              title: 'No upcoming calls.',
              subtitle: 'Approve a member request to see calls here.',
              icon: Icons.video_call_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: upcoming.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = upcoming[index];
                return UpcomingCallCard(
                  request: request,
                  peerName: 'Member DK',
                  onJoin: () => _joinCall(context, request),
                );
              },
            ),
    );
  }

  void _joinCall(BuildContext context, CallRequest request) {
    AppNavigation.pushNamed(
      context,
      AppRoutes.trainerPreJoin,
      arguments: InCallArgs(
        callRequestId: request.id,
        role: AppRole.trainer,
        scheduledFor: request.scheduledFor,
      ),
    );
  }
}
