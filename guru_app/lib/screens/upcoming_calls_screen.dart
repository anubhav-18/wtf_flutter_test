import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class UpcomingCallsScreen extends ConsumerWidget {
  const UpcomingCallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(callRequestsStreamProvider).value ?? [];
    final now = DateTime.now();
    final upcoming = requests
        .where(
          (r) =>
              r.status == CallRequestStatus.approved &&
              r.memberId == AppConstants.memberId &&
              r.scheduledFor.isAfter(now.subtract(const Duration(minutes: 30))),
        )
        .toList()
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Calls')),
      body: upcoming.isEmpty
          ? const EmptyState(
              title: 'No upcoming calls.',
              subtitle: 'Schedule a call with your trainer to get started.',
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
                  peerName: 'Trainer Aarav',
                  onJoin: () => _joinCall(context, request),
                );
              },
            ),
    );
  }

  void _joinCall(BuildContext context, CallRequest request) {
    AppNavigation.pushNamed(
      context,
      AppRoutes.guruPreJoin,
      arguments: InCallArgs(
        callRequestId: request.id,
        role: AppRole.member,
        scheduledFor: request.scheduledFor,
      ),
    );
  }
}
