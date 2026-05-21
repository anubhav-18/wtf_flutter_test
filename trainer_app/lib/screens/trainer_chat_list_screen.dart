import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class TrainerChatListScreen extends ConsumerWidget {
  const TrainerChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesStreamProvider).value ?? [];
    final chatMessages = messages
        .where((message) => message.chatId == AppConstants.chatId)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            AppNavigation.pushNamed(context, AppRoutes.trainerConversation),
        child: const Icon(Icons.add),
      ),
      body: ChatListView(
        messages: chatMessages,
        currentUserId: AppConstants.trainerId,
        peerName: 'DK',
        peerInitials: 'DK',
        primaryColor: AppColors.trainerPrimary,
        onOpenChat: () =>
            AppNavigation.pushNamed(context, AppRoutes.trainerConversation),
        onSayHi: () async {
          await ref
              .read(chatServiceProvider)
              .sendMessage(
                senderId: AppConstants.trainerId,
                receiverId: AppConstants.memberId,
                text: 'Hi DK 👋',
              );
          if (context.mounted) {
            AppNavigation.pushNamed(context, AppRoutes.trainerConversation);
          }
        },
      ),
    );
  }
}
