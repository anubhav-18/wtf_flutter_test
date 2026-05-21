enum AppRole {
  member,
  trainer;

  String get label {
    return switch (this) {
      AppRole.member => 'Member',
      AppRole.trainer => 'Trainer',
    };
  }

  String toJson() => name;

  static AppRole fromJson(String value) {
    return AppRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => AppRole.member,
    );
  }
}
