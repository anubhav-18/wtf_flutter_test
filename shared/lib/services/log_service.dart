import '../repositories/session_log_repository.dart';

class LogService {
  LogService({required this.repository});

  final SessionLogRepository repository;
}
