import '../services/dev_log_service.dart';

class AppLogger {
  const AppLogger._();

  static void log(String tag, String message) {
    DevLogService.add(tag, message);
  }
}
