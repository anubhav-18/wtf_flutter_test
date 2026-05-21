import '../repositories/session_log_repository.dart';
import '../models/session_log.dart';

class LogService {
  LogService({required this.repository});

  final SessionLogRepository repository;

  Future<SessionLog> createFromCall({
    required DateTime startedAt,
    required DateTime endedAt,
    int? rating,
    String? memberNotes,
    String? trainerNotes,
  }) =>
      repository.createFromCall(
        startedAt: startedAt,
        endedAt: endedAt,
        rating: rating,
        memberNotes: memberNotes,
        trainerNotes: trainerNotes,
      );

  Future<void> addRating(String logId, int rating) async {
    final logs = await repository.load();
    final log = logs.firstWhere((l) => l.id == logId);
    final updated = log.copyWith(rating: rating);
    await repository.updateLog(updated);
  }

  Future<void> addMemberNotes(String logId, String notes) async {
    final logs = await repository.load();
    final log = logs.firstWhere((l) => l.id == logId);
    final updated = log.copyWith(memberNotes: notes);
    await repository.updateLog(updated);
  }

  Future<void> addTrainerNotes(String logId, String notes) async {
    final logs = await repository.load();
    final log = logs.firstWhere((l) => l.id == logId);
    final updated = log.copyWith(trainerNotes: notes);
    await repository.updateLog(updated);
  }

  List<SessionLog> filterLast7Days(List<SessionLog> logs) =>
      repository.last7Days(logs);

  List<SessionLog> filterThisMonth(List<SessionLog> logs) =>
      repository.thisMonth(logs);
}
