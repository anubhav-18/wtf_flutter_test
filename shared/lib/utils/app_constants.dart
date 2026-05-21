class AppConstants {
  const AppConstants._();

  static const memberId = 'dk';
  static const trainerId = 'aarav';
  static const chatId = 'dk_aarav';
  static const pollInterval = Duration(milliseconds: 300);
  static const typingMinDelay = Duration(milliseconds: 400);
  static const typingMaxDelay = Duration(milliseconds: 800);
  static const joinWindow = Duration(minutes: 10);

  /// Injected at build time via:
  ///   flutter run --dart-define=TOKEN_SERVER_URL=http://YOUR_LAN_IP:4000
  /// Defaults to Android emulator alias (10.0.2.2) if not specified.
  static const tokenServerBaseUrl = String.fromEnvironment(
    'TOKEN_SERVER_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );
}
