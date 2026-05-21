import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message.dart';
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
    this.onSendAttachment,
  });

  final List<Message> messages;
  final String currentUserId;
  final String peerName;
  final Color primaryColor;
  final Future<void> Function(String text) onSend;
  final Future<void> Function() onMarkRead;
  final Future<void> Function(File file)? onSendAttachment;

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _picker = ImagePicker();
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
    if (trimmed.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _typing = true;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      await widget.onSend(trimmed);
      if (!mounted) return;
      _controller.clear();
    } finally {
      if (mounted) setState(() { _sending = false; _typing = false; });
    }
  }

  Future<void> _pickAndSend() async {
    if (widget.onSendAttachment == null) return;
    final result = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Photo from gallery'),
              onTap: () async {
                final img = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 75,
                );
                if (ctx.mounted) Navigator.pop(ctx, img);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo'),
              onTap: () async {
                final img = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 75,
                );
                if (ctx.mounted) Navigator.pop(ctx, img);
              },
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _sending = true);
    try {
      await widget.onSendAttachment!(File(result.path));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final messages = [...widget.messages]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onMarkRead,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return AnimatedOpacity(
                    opacity: _typing ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: _TypingIndicator(
                        peerName: widget.peerName,
                        color: cs.outlineVariant),
                  );
                }
                final msg = messages[index];
                final showDate = index == 0 ||
                    !_sameDay(msg.createdAt, messages[index - 1].createdAt);
                return Column(
                  children: [
                    if (showDate) _DateDivider(date: msg.createdAt),
                    _MessageBubble(
                      message: msg,
                      isMine: msg.senderId == widget.currentUserId,
                      primaryColor: widget.primaryColor,
                    ),
                  ],
                );
              },
              itemCount: messages.length + 1,
            ),
          ),
        ),
        _QuickReplies(onSelected: _send),
        // Input bar
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file_rounded,
                      color: cs.onSurfaceVariant),
                  onPressed: _sending ? null : _pickAndSend,
                  tooltip: 'Attach image',
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Message ${widget.peerName}…',
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _sending
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: widget.primaryColor),
                          ),
                        )
                      : IconButton.filled(
                          onPressed: () => _send(_controller.text),
                          style: IconButton.styleFrom(
                              backgroundColor: widget.primaryColor),
                          icon: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final bubbleColor = isMine ? primaryColor : cs.surfaceContainerHighest;
    final textColor = isMine ? Colors.white : cs.onSurface;
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isMine ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isMine ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Attachment (image)
              if (message.hasAttachment && message.isImage)
                ClipRRect(
                  borderRadius: radius.copyWith(
                      bottomLeft: const Radius.circular(0),
                      bottomRight: const Radius.circular(0)),
                  child: Image.memory(
                    base64Decode(message.imageData!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (ctx2, e, _) => const Icon(Icons.broken_image),
                  ),
                ),
              // PDF or other file
              if (message.hasAttachment && message.isPdf)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.picture_as_pdf,
                          color: isMine ? Colors.white70 : cs.primary),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          message.fileName ?? 'Document',
                          style: TextStyle(color: textColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              // Text body
              if (message.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Text(message.text,
                      style: TextStyle(color: textColor, fontSize: 15)),
                ),
              // Timestamp + status
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 10, 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormatters.time(message.createdAt),
                      style: TextStyle(
                          color: textColor.withValues(alpha: 0.65),
                          fontSize: 10.5),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.status == MessageStatus.read
                            ? Icons.done_all_rounded
                            : Icons.check_rounded,
                        size: 13,
                        color: message.status == MessageStatus.read
                            ? Colors.lightBlueAccent
                            : textColor.withValues(alpha: 0.7),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day
        ? 'Today'
        : DateFormatters.date(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        const Expanded(child: Divider()),
      ]),
    );
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.onSelected});
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const replies = ['Got it 👍', 'Can we talk at 6?', 'Share plan?', 'Sounds good!'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => ActionChip(
          label: Text(replies[index],
              style: const TextStyle(fontSize: 13)),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          onPressed: () => onSelected(replies[index]),
        ),
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemCount: replies.length,
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.peerName, required this.color});
  final String peerName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            _Dot(delay: 200),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.delay});
  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(
      parent: _ac,
      curve: Interval(widget.delay / 800.0, 1.0, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 7,
        height: 7 + _anim.value * 4,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant
              .withValues(alpha: 0.5 + _anim.value * 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
