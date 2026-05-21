import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

/// Chat list for the Guru (member) app.
/// Always shows the DK ↔ Aarav conversation — no "Say Hi" gate.
/// The conversation persists as long as the token server is running.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

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
            m.receiverId == AppConstants.memberId &&
            m.status != MessageStatus.read)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Always show the trainer conversation tile
          _ConversationTile(
            name: 'Aarav',
            subtitle: 'Lead Trainer',
            initials: 'A',
            lastMessage: lastMsg?.hasAttachment == true
                ? '📎 Attachment'
                : lastMsg?.text ?? 'Start the conversation',
            unread: unread,
            primaryColor: AppColors.guruPrimary,
            onTap: () => AppNavigation.pushNamed(
              context,
              AppRoutes.guruConversation,
            ),
          ),
          // Empty illustration only when no messages at all
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
                  Text('Tap above to say hi to Aarav 👋',
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

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.name,
    required this.subtitle,
    required this.initials,
    required this.lastMessage,
    required this.unread,
    required this.primaryColor,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final String initials;
  final String lastMessage;
  final int unread;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: primaryColor,
                  child: Text(
                    initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
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
                      border: Border.all(
                          color: cs.surface, width: 2),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            if (unread == 0)
              Icon(Icons.chevron_right, color: cs.outlineVariant),
          ],
        ),
      ),
    );
  }
}
