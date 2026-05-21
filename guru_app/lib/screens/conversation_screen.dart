import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class ConversationScreen extends ConsumerWidget {
  const ConversationScreen({super.key});

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
        r.memberId == AppConstants.memberId).toList();
    final hasUpcoming = upcoming.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aarav'),
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
              onPressed: () =>
                  AppNavigation.pushNamed(context, AppRoutes.guruUpcomingCalls),
            ),
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
