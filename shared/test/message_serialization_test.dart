import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  group('Message serialization', () {
    test('round-trips through toJson/fromJson', () {
      final original = Message(
        id: 'msg-001',
        chatId: 'chat-dk-aarav',
        senderId: 'member-dk',
        receiverId: 'trainer-aarav',
        text: 'Hello trainer!',
        createdAt: DateTime(2025, 1, 15, 10, 30, 0),
        status: MessageStatus.sent,
        isSystem: false,
      );

      final json = original.toJson();
      final restored = Message.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.chatId, equals(original.chatId));
      expect(restored.senderId, equals(original.senderId));
      expect(restored.receiverId, equals(original.receiverId));
      expect(restored.text, equals(original.text));
      expect(restored.status, equals(original.status));
      expect(restored.isSystem, equals(original.isSystem));
      expect(
        restored.createdAt.toIso8601String(),
        equals(original.createdAt.toIso8601String()),
      );
    });

    test('isSystem defaults to false when not set in json', () {
      final json = {
        'id': 'msg-002',
        'chatId': 'chat-dk-aarav',
        'senderId': 'sender',
        'receiverId': 'receiver',
        'text': 'Hi',
        'createdAt': DateTime(2025, 2, 1).toIso8601String(),
        'status': 'sent',
      };
      final msg = Message.fromJson(json);
      expect(msg.isSystem, isFalse);
    });

    test('supports emoji in text', () {
      final msg = Message(
        id: 'msg-003',
        chatId: 'chat-abc',
        senderId: 'a',
        receiverId: 'b',
        text: '💪🏋️ Great session!',
        createdAt: DateTime.now(),
        status: MessageStatus.sent,
      );
      final restored = Message.fromJson(msg.toJson());
      expect(restored.text, contains('💪'));
    });

    test('MessageStatus.read round-trips correctly', () {
      final msg = Message(
        id: 'msg-004',
        chatId: 'chat-x',
        senderId: 'a',
        receiverId: 'b',
        text: 'Seen',
        createdAt: DateTime.now(),
        status: MessageStatus.read,
      );
      final restored = Message.fromJson(msg.toJson());
      expect(restored.status, equals(MessageStatus.read));
    });

    test('unknown status falls back to sent', () {
      final json = {
        'id': 'msg-005',
        'chatId': 'chat-x',
        'senderId': 'a',
        'receiverId': 'b',
        'text': 'Hi',
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'UNKNOWN_STATUS',
        'isSystem': false,
      };
      final msg = Message.fromJson(json);
      expect(msg.status, equals(MessageStatus.sent));
    });
  });
}
