import 'dart:async';

import 'package:flutter/material.dart';

import '../models/message.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatters.dart';

class ConversationView extends StatefulWidget {
  const ConversationView({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.peerName,
    required this.primaryColor,
    required this.onSend,
    required this.onMarkRead,
  });

  final List<Message> messages;
  final String currentUserId;
  final String peerName;
  final Color primaryColor;
  final Future<void> Function(String text) onSend;
  final Future<void> Function() onMarkRead;

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    unawaited(widget.onMarkRead());
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant ConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages.length != widget.messages.length) {
      unawaited(widget.onMarkRead());
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) {
      return;
    }
    setState(() {
      _sending = true;
      _typing = true;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) {
        return;
      }
      await widget.onSend(trimmed);
      if (!mounted) {
        return;
      }
      _controller.clear();
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _typing = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = [...widget.messages]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onMarkRead,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return AnimatedOpacity(
                    opacity: _typing ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const _TypingIndicator(),
                  );
                }
                return _MessageBubble(
                  message: messages[index],
                  isMine: messages[index].senderId == widget.currentUserId,
                  primaryColor: widget.primaryColor,
                );
              },
              itemCount: messages.length + 1,
            ),
          ),
        ),
        _QuickReplies(onSelected: _send),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Message ${widget.peerName}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : () => _send(_controller.text),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.primaryColor,
  });

  final Message message;
  final bool isMine;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(child: Chip(label: Text(message.text))),
      );
    }

    final color = isMine ? primaryColor : Colors.white;
    final textColor = isMine ? Colors.white : AppColors.text;
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: isMine ? null : Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.text, style: TextStyle(color: textColor)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormatters.time(message.createdAt),
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == MessageStatus.read
                        ? Icons.done_all
                        : Icons.check,
                    size: 14,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const replies = ['Got it 👍', 'Can we talk at 6?', 'Share plan?'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => ActionChip(
          label: Text(replies[index]),
          onPressed: () => onSelected(replies[index]),
        ),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: replies.length,
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Typing...', style: TextStyle(color: AppColors.muted)),
      ),
    );
  }
}
