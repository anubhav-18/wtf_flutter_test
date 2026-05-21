import '../repositories/chat_repository.dart';

class ChatService {
  ChatService({required this.repository});

  final ChatRepository repository;

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) {
    return repository.send(
      senderId: senderId,
      receiverId: receiverId,
      text: text,
    );
  }
}
