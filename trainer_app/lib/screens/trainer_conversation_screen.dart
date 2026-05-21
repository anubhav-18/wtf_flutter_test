import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class TrainerConversationScreen extends ConsumerWidget {
  const TrainerConversationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesStreamProvider).value ?? [];
    final chatMessages = messages
        .where((message) => message.chatId == AppConstants.chatId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DK'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Badge(child: Icon(Icons.videocam_outlined)),
          ),
        ],
      ),
      body: ConversationView(
        messages: chatMessages,
        currentUserId: AppConstants.trainerId,
        peerName: 'DK',
        primaryColor: AppColors.trainerPrimary,
        onMarkRead: () =>
            ref.read(chatRepositoryProvider).markRead(AppConstants.trainerId),
        onSend: (text) => ref.read(chatServiceProvider).sendMessage(
              senderId: AppConstants.trainerId,
              receiverId: AppConstants.memberId,
              text: text,
            ),
        onSendAttachment: (file) => ref
            .read(chatRepositoryProvider)
            .sendAttachment(
              senderId: AppConstants.trainerId,
              receiverId: AppConstants.memberId,
              file: file,
            ),
      ),
    );
  }
}
