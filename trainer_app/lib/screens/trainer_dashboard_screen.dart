import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import '../widgets/dashboard_tile.dart';

class TrainerDashboardScreen extends ConsumerWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(callRequestsStreamProvider).value ?? [];
    final upcomingCount = requests
        .where(
          (r) =>
              r.status == CallRequestStatus.approved &&
              r.trainerId == AppConstants.trainerId,
        )
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Trainer • Aarav')),
      floatingActionButton: const DevPanelButton(),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          DashboardTile(
            title: 'Members',
            icon: Icons.people_outline,
            onTap: () =>
                AppNavigation.pushNamed(context, AppRoutes.trainerMembers),
          ),
          DashboardTile(
            title: 'Chats',
            icon: Icons.chat_bubble_outline,
            onTap: () =>
                AppNavigation.pushNamed(context, AppRoutes.trainerChats),
          ),
          DashboardTile(
            title: 'Requests',
            icon: Icons.pending_actions,
            onTap: () =>
                AppNavigation.pushNamed(context, AppRoutes.trainerRequests),
          ),
          DashboardTile(
            title: 'Sessions',
            icon: Icons.history_outlined,
            onTap: () =>
                AppNavigation.pushNamed(context, AppRoutes.trainerSessions),
          ),
          DashboardTile(
            title: 'Upcoming Calls',
            icon: Icons.video_call_outlined,
            badge: upcomingCount > 0 ? '$upcomingCount' : null,
            onTap: () => AppNavigation.pushNamed(
                context, AppRoutes.trainerUpcomingCalls),
          ),
        ],
      ),
    );
  }
}
