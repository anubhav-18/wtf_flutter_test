import 'package:uuid/uuid.dart';

import '../models/session_log.dart';
import '../services/api_client.dart';
import '../services/dev_log_service.dart';
import '../utils/app_constants.dart';
import 'base_polling_repository.dart';

class SessionLogRepository extends BasePollingRepository<SessionLog> {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<SessionLog>> load() async {
    final list = await ApiClient.getList('/session-logs');
    return list.map((json) => SessionLog.fromJson(json)).toList();
  }

  Future<SessionLog> createFromCall({
    required DateTime startedAt,
    required DateTime endedAt,
    int? rating,
    String? memberNotes,
    String? trainerNotes,
  }) async {
    final duration = endedAt.difference(startedAt).inSeconds;
    final log = SessionLog(
      id: _uuid.v4(),
      memberId: AppConstants.memberId,
      trainerId: AppConstants.trainerId,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSec: duration < 0 ? 0 : duration,
      rating: rating,
      trainerNotes: trainerNotes,
      memberNotes: memberNotes,
    );
    await ApiClient.post('/session-logs', log.toJson());
    DevLogService.add('[RTC]', 'Session log created ${log.id} (${log.durationSec}s)');
    await emitCurrent();
    return log;
  }

  Future<void> updateLog(SessionLog log) async {
    await ApiClient.patch('/session-logs/${log.id}', log.toJson());
    DevLogService.add('[LOG]', 'Session log updated ${log.id}');
    await emitCurrent();
  }

  List<SessionLog> last7Days(List<SessionLog> logs) {
    final start = DateTime.now().subtract(const Duration(days: 7));
    return logs.where((log) => log.startedAt.isAfter(start)).toList();
  }

  List<SessionLog> thisMonth(List<SessionLog> logs) {
    final now = DateTime.now();
    return logs
        .where(
          (log) => log.startedAt.year == now.year && log.startedAt.month == now.month,
        )
        .toList();
  }
}
