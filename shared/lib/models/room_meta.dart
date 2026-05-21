class RoomMeta {
  const RoomMeta({
    required this.id,
    required this.callRequestId,
    required this.hmsRoomId,
    required this.hmsRoleMember,
    required this.hmsRoleTrainer,
  });

  final String id;
  final String callRequestId;
  final String hmsRoomId;
  final String hmsRoleMember;
  final String hmsRoleTrainer;

  RoomMeta copyWith({
    String? id,
    String? callRequestId,
    String? hmsRoomId,
    String? hmsRoleMember,
    String? hmsRoleTrainer,
  }) {
    return RoomMeta(
      id: id ?? this.id,
      callRequestId: callRequestId ?? this.callRequestId,
      hmsRoomId: hmsRoomId ?? this.hmsRoomId,
      hmsRoleMember: hmsRoleMember ?? this.hmsRoleMember,
      hmsRoleTrainer: hmsRoleTrainer ?? this.hmsRoleTrainer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callRequestId': callRequestId,
      'hmsRoomId': hmsRoomId,
      'hmsRoleMember': hmsRoleMember,
      'hmsRoleTrainer': hmsRoleTrainer,
    };
  }

  factory RoomMeta.fromJson(Map<String, dynamic> json) {
    return RoomMeta(
      id: json['id'] as String,
      callRequestId: json['callRequestId'] as String,
      hmsRoomId: json['hmsRoomId'] as String,
      hmsRoleMember: json['hmsRoleMember'] as String,
      hmsRoleTrainer: json['hmsRoleTrainer'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RoomMeta &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            callRequestId == other.callRequestId &&
            hmsRoomId == other.hmsRoomId &&
            hmsRoleMember == other.hmsRoleMember &&
            hmsRoleTrainer == other.hmsRoleTrainer;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      callRequestId,
      hmsRoomId,
      hmsRoleMember,
      hmsRoleTrainer,
    );
  }
}
