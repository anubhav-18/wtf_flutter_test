import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class TrainerConversationScreen extends ConsumerWidget {
  const TrainerConversationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesStreamProvider).value ?? [];
    final chatMessages = messages
        .where((m) => m.chatId == AppConstants.chatId)
        .toList();

    // Upcoming approved call (for camera badge)
    final requests = ref.watch(callRequestsStreamProvider).value ?? [];
    final upcoming = requests.where((r) =>
        r.status == CallRequestStatus.approved &&
        r.trainerId == AppConstants.trainerId).toList();
    final hasUpcoming = upcoming.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DK'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: hasUpcoming ? 'Join upcoming call' : 'Upcoming calls',
              icon: Badge(
                isLabelVisible: hasUpcoming,
                label: Text('${upcoming.length}'),
                child: const Icon(Icons.videocam_outlined),
              ),
              onPressed: () => AppNavigation.pushNamed(
                  context, AppRoutes.trainerUpcomingCalls),
            ),
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
