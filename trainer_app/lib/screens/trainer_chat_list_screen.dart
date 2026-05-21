import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

/// Trainer chat list — always shows the DK conversation.
class TrainerChatListScreen extends ConsumerWidget {
  const TrainerChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesStreamProvider).value ?? [];
    final chatMessages = messages
        .where((m) => m.chatId == AppConstants.chatId)
        .toList();
    final cs = Theme.of(context).colorScheme;

    final lastMsg = chatMessages.isNotEmpty ? chatMessages.last : null;
    final unread = chatMessages
        .where((m) =>
            m.receiverId == AppConstants.trainerId &&
            m.status != MessageStatus.read)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () =>
                AppNavigation.pushNamed(context, AppRoutes.trainerConversation),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.guruPrimary,
                        child: const Text('DK',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DK',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Member',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(
                          lastMsg?.hasAttachment == true
                              ? '📎 Attachment'
                              : lastMsg?.text ?? 'Start the conversation',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: unread > 0
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant,
                                    fontWeight: unread > 0
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.trainerPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Icon(Icons.chevron_right, color: cs.outlineVariant),
                ],
              ),
            ),
          ),
          if (chatMessages.isEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 72, color: cs.outlineVariant),
                  const SizedBox(height: 16),
                  Text('No messages yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('DK hasn\'t messaged yet',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
