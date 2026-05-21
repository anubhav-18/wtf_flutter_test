import '../models/call_request.dart';

class Validators {
  const Validators._();

  static String? validateCallNote(String value) {
    if (value.length > 140) {
      return 'Note must be 140 characters or less.';
    }
    return null;
  }

  static String? validateScheduledFor(DateTime scheduledFor) {
    if (scheduledFor.isBefore(DateTime.now())) {
      return 'Cannot pick a past time.';
    }
    return null;
  }

  static bool hasApprovedConflict(
    Iterable<CallRequest> requests,
    DateTime scheduledFor,
  ) {
    return requests.any(
      (request) =>
          request.status == CallRequestStatus.approved &&
          request.scheduledFor.isAtSameMomentAs(scheduledFor),
    );
  }
}
