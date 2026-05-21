import 'package:uuid/uuid.dart';

import '../models/message.dart';
import '../services/api_client.dart';
import '../services/dev_log_service.dart';
import '../utils/app_constants.dart';
import 'base_polling_repository.dart';

class ChatRepository extends BasePollingRepository<Message> {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<Message>> load() async {
    final list = await ApiClient.getList(
      '/messages',
      {'chatId': AppConstants.chatId},
    );
    return list.map((json) => Message.fromJson(json)).toList();
  }

  Future<void> send({
    required String senderId,
    required String receiverId,
    required String text,
    bool isSystem = false,
  }) async {
    final id = _uuid.v4();
    await ApiClient.post('/messages', {
      'id': id,
      'chatId': AppConstants.chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'isSystem': isSystem,
    });
    DevLogService.add('[CHAT]', 'Message sent by $senderId');
    await emitCurrent();
  }

  Future<void> markRead(String currentUserId) async {
    await ApiClient.patchQuery(
      '/messages/mark-read',
      {'receiverId': currentUserId},
    );
    await emitCurrent();
  }
}
