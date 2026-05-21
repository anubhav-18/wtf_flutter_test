class DevLogEntry {
  const DevLogEntry({
    required this.tag,
    required this.message,
    required this.createdAt,
  });

  final String tag;
  final String message;
  final DateTime createdAt;
}

class DevLogService {
  DevLogService._();

  static final List<DevLogEntry> _entries = <DevLogEntry>[];

  static List<DevLogEntry> get latest20 {
    return List.unmodifiable(_entries.reversed.take(20));
  }

  static void add(String tag, String message) {
    _entries.add(
      DevLogEntry(
        tag: tag,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
    if (_entries.length > 100) {
      _entries.removeRange(0, _entries.length - 100);
    }
  }
}
