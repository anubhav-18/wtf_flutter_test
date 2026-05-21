import 'package:uuid/uuid.dart';

import '../models/call_request.dart';
import '../services/api_client.dart';
import '../services/dev_log_service.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';
import 'base_polling_repository.dart';

class CallRepository extends BasePollingRepository<CallRequest> {
  CallRepository({required this.chatRepository});

  // kept for interface compatibility — system messages are now sent server-side
  final dynamic chatRepository;

  final Uuid _uuid = const Uuid();

  @override
  Future<List<CallRequest>> load() async {
    final list = await ApiClient.getList('/call-requests');
    return list.map((json) => CallRequest.fromJson(json)).toList();
  }

  Future<String?> requestCall({
    required DateTime scheduledFor,
    required String note,
  }) async {
    final noteError = Validators.validateCallNote(note);
    if (noteError != null) return noteError;

    final dateError = Validators.validateScheduledFor(scheduledFor);
    if (dateError != null) return dateError;

    final request = CallRequest(
      id: _uuid.v4(),
      memberId: AppConstants.memberId,
      trainerId: AppConstants.trainerId,
      requestedAt: DateTime.now(),
      scheduledFor: scheduledFor,
      note: note,
      status: CallRequestStatus.pending,
    );

    // Server handles conflict check and returns 409 with error text.
    final error = await ApiClient.postForError(
      '/call-requests',
      request.toJson(),
    );
    if (error != null) return error;

    DevLogService.add('[SCHEDULE]', 'Call requested for ${request.scheduledFor}');
    await emitCurrent();
    return null;
  }

  Future<String?> approve(String requestId) async {
    // Server handles conflict check and sends the system chat message.
    final error = await ApiClient.patchForError(
      '/call-requests/$requestId',
      {'status': 'approved'},
    );
    if (error != null) return error;

    DevLogService.add('[SCHEDULE]', 'Call approved $requestId');
    await emitCurrent();
    return null;
  }

  Future<void> decline(String requestId, String reason) async {
    await ApiClient.patch('/call-requests/$requestId', {
      'status': 'declined',
      'declineReason': reason,
    });
    DevLogService.add('[SCHEDULE]', 'Call declined $requestId');
    await emitCurrent();
  }
}
