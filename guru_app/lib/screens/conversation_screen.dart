import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class ConversationScreen extends ConsumerWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesStreamProvider).value ?? [];
    final chatMessages = messages
        .where((message) => message.chatId == AppConstants.chatId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aarav'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Badge(child: Icon(Icons.videocam_outlined)),
          ),
        ],
      ),
      body: ConversationView(
        messages: chatMessages,
        currentUserId: AppConstants.memberId,
        peerName: 'Aarav',
        primaryColor: AppColors.guruPrimary,
        onMarkRead: () =>
            ref.read(chatRepositoryProvider).markRead(AppConstants.memberId),
        onSend: (text) => ref.read(chatServiceProvider).sendMessage(
              senderId: AppConstants.memberId,
              receiverId: AppConstants.trainerId,
              text: text,
            ),
        onSendAttachment: (file) => ref
            .read(chatRepositoryProvider)
            .sendAttachment(
              senderId: AppConstants.memberId,
              receiverId: AppConstants.trainerId,
              file: file,
            ),
      ),
    );
  }
}
