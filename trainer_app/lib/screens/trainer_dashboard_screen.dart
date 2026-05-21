import 'package:flutter/material.dart';
import 'package:wtf_shared/wtf_shared.dart';

import '../widgets/dashboard_tile.dart';
import 'members_screen.dart';

class TrainerDashboardScreen extends StatelessWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MembersScreen()),
            ),
          ),
          const DashboardTile(title: 'Chats', icon: Icons.chat_bubble_outline),
          const DashboardTile(title: 'Requests', icon: Icons.pending_actions),
          const DashboardTile(title: 'Sessions', icon: Icons.history_outlined),
          const DashboardTile(
            title: 'Upcoming Calls',
            icon: Icons.video_call_outlined,
          ),
        ],
      ),
    );
  }
}
