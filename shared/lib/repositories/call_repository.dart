import 'package:uuid/uuid.dart';

import '../models/call_request.dart';
import '../models/room_meta.dart';
import '../services/dev_log_service.dart';
import '../services/hive_storage_service.dart';
import '../utils/app_constants.dart';
import '../utils/date_formatters.dart';
import '../utils/validators.dart';
import 'base_polling_repository.dart';
import 'chat_repository.dart';

class CallRepository extends BasePollingRepository<CallRequest> {
  CallRepository({required this.chatRepository});

  final ChatRepository chatRepository;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<CallRequest>> load() async {
    return HiveStorageService.callRequests()
        .values
        .map((json) => CallRequest.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));
  }

  Future<String?> requestCall({
    required DateTime scheduledFor,
    required String note,
  }) async {
    final noteError = Validators.validateCallNote(note);
    if (noteError != null) {
      return noteError;
    }
    final dateError = Validators.validateScheduledFor(scheduledFor);
    if (dateError != null) {
      return dateError;
    }
    final request = CallRequest(
      id: _uuid.v4(),
      memberId: AppConstants.memberId,
      trainerId: AppConstants.trainerId,
      requestedAt: DateTime.now(),
      scheduledFor: scheduledFor,
      note: note,
      status: CallRequestStatus.pending,
    );
    await HiveStorageService.callRequests().put(request.id, request.toJson());
    DevLogService.add('[SCHEDULE]', 'Call requested for ${request.scheduledFor}');
    await emitCurrent();
    return null;
  }

  Future<String?> approve(String requestId) async {
    final requests = await load();
    final request = requests.firstWhere((item) => item.id == requestId);
    if (Validators.hasApprovedConflict(requests, request.scheduledFor)) {
      return 'Slot already approved.';
    }
    final approved = request.copyWith(status: CallRequestStatus.approved);
    await HiveStorageService.callRequests().put(approved.id, approved.toJson());
    final room = RoomMeta(
      id: _uuid.v4(),
      callRequestId: approved.id,
      hmsRoomId: 'env-room',
      hmsRoleMember: 'member',
      hmsRoleTrainer: 'trainer',
    );
    await HiveStorageService.roomMeta().put(room.id, room.toJson());
    await chatRepository.send(
      senderId: AppConstants.trainerId,
      receiverId: AppConstants.memberId,
      text: 'Call approved for ${DateFormatters.dateTime(approved.scheduledFor)}.',
      isSystem: true,
    );
    DevLogService.add('[SCHEDULE]', 'Call approved ${approved.id}');
    await emitCurrent();
    return null;
  }

  Future<void> decline(String requestId, String reason) async {
    final box = HiveStorageService.callRequests();
    final json = box.get(requestId);
    if (json == null) {
      return;
    }
    final request = CallRequest.fromJson(Map<String, dynamic>.from(json));
    final declined = request.copyWith(
      status: CallRequestStatus.declined,
      declineReason: reason,
    );
    await box.put(requestId, declined.toJson());
    await chatRepository.send(
      senderId: AppConstants.trainerId,
      receiverId: AppConstants.memberId,
      text: 'Call request declined. Reason: $reason.',
      isSystem: true,
    );
    DevLogService.add('[SCHEDULE]', 'Call declined $requestId');
    await emitCurrent();
  }
}
