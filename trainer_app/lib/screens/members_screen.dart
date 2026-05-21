import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersStreamProvider);
    final messages = ref.watch(messagesStreamProvider).value ?? [];
    final requests = ref.watch(callRequestsStreamProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: users.when(
        data: (items) {
          final members = items
              .where(
                (user) =>
                    user.role == AppRole.member &&
                    user.assignedTrainerId == AppConstants.trainerId,
              )
              .toList();
          if (members.isEmpty) {
            return const EmptyState(
              title: 'No assigned members yet.',
              actionLabel: 'Refresh',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final member = members[index];
              final latestMessages =
                  messages
                      .where(
                        (message) =>
                            message.senderId == member.id ||
                            message.receiverId == member.id,
                      )
                      .toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final requestCount = requests
                  .where((request) => request.memberId == member.id)
                  .length;
              final summary = latestMessages.isNotEmpty
                  ? latestMessages.first.text
                  : requestCount > 0
                  ? '$requestCount call request(s)'
                  : 'No interactions yet';
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(member.avatarUrl ?? member.name[0]),
                  ),
                  title: Text(member.name),
                  subtitle: Text('Trainer: Aarav • $summary'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => AppNavigation.pushNamed(
                    context,
                    AppRoutes.trainerMemberDetail,
                    arguments: member,
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount: members.length,
          );
        },
        error: (error, stackTrace) => EmptyState(
          title: 'Could not load members.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(usersStreamProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
