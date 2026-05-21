import 'app_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.assignedTrainerId,
  });

  final String id;
  final AppRole role;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? assignedTrainerId;

  AppUser copyWith({
    String? id,
    AppRole? role,
    String? name,
    String? email,
    String? avatarUrl,
    String? assignedTrainerId,
  }) {
    return AppUser(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toJson(),
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'assignedTrainerId': assignedTrainerId,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      role: AppRole.fromJson(json['role'] as String),
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      assignedTrainerId: json['assignedTrainerId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppUser &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            role == other.role &&
            name == other.name &&
            email == other.email &&
            avatarUrl == other.avatarUrl &&
            assignedTrainerId == other.assignedTrainerId;
  }

  @override
  int get hashCode {
    return Object.hash(id, role, name, email, avatarUrl, assignedTrainerId);
  }
}
