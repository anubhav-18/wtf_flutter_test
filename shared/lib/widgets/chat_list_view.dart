import 'package:flutter/material.dart';

import '../models/message.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatters.dart';
import 'empty_state.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.peerName,
    required this.peerInitials,
    required this.primaryColor,
    required this.onOpenChat,
    required this.onSayHi,
  });

  final List<Message> messages;
  final String currentUserId;
  final String peerName;
  final String peerInitials;
  final Color primaryColor;
  final VoidCallback onOpenChat;
  final VoidCallback onSayHi;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return EmptyState(
        title: 'No messages yet. Start the conversation.',
        actionLabel: 'Say hi',
        onAction: onSayHi,
      );
    }

    final latest = [...messages]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final unreadCount = messages
        .where(
          (message) =>
              message.receiverId == currentUserId &&
              message.status != MessageStatus.read,
        )
        .length;
    final last = latest.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: primaryColor,
              child: Text(
                peerInitials,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(peerName),
            subtitle: Text(last.text, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(DateFormatters.relative(last.createdAt)),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Badge(
                    backgroundColor: AppColors.error,
                    label: Text('$unreadCount'),
                  ),
                ],
              ],
            ),
            onTap: onOpenChat,
          ),
        ),
      ],
    );
  }
}
