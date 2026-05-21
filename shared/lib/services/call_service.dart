import '../repositories/call_repository.dart';

class CallService {
  CallService({required this.repository});

  final CallRepository repository;

  Future<String?> requestCall({
    required DateTime scheduledFor,
    required String note,
  }) {
    return repository.requestCall(scheduledFor: scheduledFor, note: note);
  }

  Future<String?> approve(String requestId) {
    return repository.approve(requestId);
  }

  Future<void> decline(String requestId, String reason) {
    return repository.decline(requestId, reason);
  }

  Future<void> markCompleted(String requestId) {
    return repository.markCompleted(requestId);
  }
}
