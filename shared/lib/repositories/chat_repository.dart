import 'package:uuid/uuid.dart';

import '../models/message.dart';
import '../services/dev_log_service.dart';
import '../services/hive_storage_service.dart';
import '../utils/app_constants.dart';
import 'base_polling_repository.dart';

class ChatRepository extends BasePollingRepository<Message> {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<Message>> load() async {
    return HiveStorageService.messages()
        .values
        .map((json) => Message.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> send({
    required String senderId,
    required String receiverId,
    required String text,
    bool isSystem = false,
  }) async {
    final message = Message(
      id: _uuid.v4(),
      chatId: AppConstants.chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      isSystem: isSystem,
    );
    await HiveStorageService.messages().put(message.id, message.toJson());
    DevLogService.add('[CHAT]', 'Message sent by $senderId');
    await emitCurrent();
  }

  Future<void> markRead(String currentUserId) async {
    final box = HiveStorageService.messages();
    for (final key in box.keys) {
      final json = Map<String, dynamic>.from(box.get(key)!);
      final message = Message.fromJson(json);
      if (message.receiverId == currentUserId &&
          message.status != MessageStatus.read) {
        await box.put(key, message.copyWith(status: MessageStatus.read).toJson());
      }
    }
    await emitCurrent();
  }
}
