import 'app_role.dart';

/// Arguments passed to pre-join and in-call screens via [Navigator] routes.
class InCallArgs {
  const InCallArgs({
    required this.callRequestId,
    required this.role,
    required this.scheduledFor,
    this.micEnabled = true,
    this.cameraEnabled = true,
  });

  final String callRequestId;
  final AppRole role;
  final DateTime scheduledFor;
  final bool micEnabled;
  final bool cameraEnabled;

  InCallArgs copyWith({
    String? callRequestId,
    AppRole? role,
    DateTime? scheduledFor,
    bool? micEnabled,
    bool? cameraEnabled,
  }) {
    return InCallArgs(
      callRequestId: callRequestId ?? this.callRequestId,
      role: role ?? this.role,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      micEnabled: micEnabled ?? this.micEnabled,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
    );
  }
}
