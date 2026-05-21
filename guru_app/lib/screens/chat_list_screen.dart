import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesStreamProvider).value ?? [];
    final chatMessages = messages
        .where((message) => message.chatId == AppConstants.chatId)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Chat with Trainer')),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            AppNavigation.pushNamed(context, AppRoutes.guruConversation),
        child: const Icon(Icons.add),
      ),
      body: ChatListView(
        messages: chatMessages,
        currentUserId: AppConstants.memberId,
        peerName: 'Aarav',
        peerInitials: 'A',
        primaryColor: AppColors.guruPrimary,
        onOpenChat: () =>
            AppNavigation.pushNamed(context, AppRoutes.guruConversation),
        onSayHi: () async {
          await ref
              .read(chatServiceProvider)
              .sendMessage(
                senderId: AppConstants.memberId,
                receiverId: AppConstants.trainerId,
                text: 'Hi Coach 👋',
              );
          if (context.mounted) {
            AppNavigation.pushNamed(context, AppRoutes.guruConversation);
          }
        },
      ),
    );
  }
}
