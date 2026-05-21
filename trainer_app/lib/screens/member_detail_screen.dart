import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import '../widgets/shortcut_tile.dart';

class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({super.key, required this.member});

  final AppUser member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(callRequestsStreamProvider).value ?? [];
    final memberRequests =
        requests.where((request) => request.memberId == member.id).toList()
          ..sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));

    return Scaffold(
      appBar: AppBar(title: Text(member.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(member.avatarUrl ?? member.name[0]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppRoleBadge(user: member),
                        const SizedBox(height: 4),
                        Text(member.email),
                        const SizedBox(height: 4),
                        const Text('Assigned trainer: Aarav'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Shortcuts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ShortcutTile(
            title: 'Chat',
            icon: Icons.chat_bubble_outline,
            onTap: () =>
                AppNavigation.pushNamed(context, AppRoutes.trainerConversation),
          ),
          ShortcutTile(
            title: 'Requests',
            icon: Icons.pending_actions,
            onTap: () =>
                AppNavigation.pushNamed(context, AppRoutes.trainerRequests),
          ),
          ShortcutTile(
            title: 'Sessions',
            icon: Icons.history_outlined,
            onTap: () => _showComingNext(context, 'Sessions'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (memberRequests.isEmpty)
            const EmptyState(
              title: 'No call requests yet.',
              actionLabel: 'Back to member',
            )
          else
            ...memberRequests
                .take(3)
                .map(
                  (request) => Card(
                    child: ListTile(
                      title: Text(
                        DateFormatters.dateTime(request.scheduledFor),
                      ),
                      subtitle: Text(
                        request.note.isEmpty ? 'No note' : request.note,
                      ),
                      trailing: Text(request.status.name),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showComingNext(BuildContext context, String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title is in the next plan step.')));
  }
}
