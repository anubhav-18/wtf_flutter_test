import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import '../widgets/dashboard_card.dart';
import 'chat_list_screen.dart';

class GuruDashboardScreen extends ConsumerWidget {
  const GuruDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member • DK')),
      floatingActionButton: const DevPanelButton(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DashboardCard(
            title: 'Chat with Trainer',
            icon: Icons.chat_bubble_outline,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ChatListScreen()),
            ),
          ),
          const DashboardCard(
            title: 'Schedule Call',
            icon: Icons.calendar_month_outlined,
          ),
          const DashboardCard(
            title: 'My Requests',
            icon: Icons.pending_actions_outlined,
          ),
          const DashboardCard(
            title: 'Upcoming Calls',
            icon: Icons.video_call_outlined,
          ),
          const DashboardCard(title: 'My Sessions', icon: Icons.history_outlined),
        ],
      ),
    );
  }
}
