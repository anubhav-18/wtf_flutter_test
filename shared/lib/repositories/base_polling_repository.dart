import 'dart:async';

import '../utils/app_constants.dart';

abstract class BasePollingRepository<T> {
  BasePollingRepository();

  final StreamController<List<T>> controller =
      StreamController<List<T>>.broadcast();
  Timer? _timer;
  String _lastSignature = '';

  Stream<List<T>> get stream => controller.stream;

  Future<List<T>> load();

  String signature(List<T> items) =>
      items.map((item) => item.hashCode).join('|');

  Future<void> emitCurrent() async {
    final items = await load();
    final nextSignature = signature(items);
    if (nextSignature != _lastSignature) {
      _lastSignature = nextSignature;
      if (!controller.isClosed) {
        controller.add(items);
      }
    }
  }

  void startPolling() {
    _timer?.cancel();
    unawaited(emitCurrent());
    _timer = Timer.periodic(AppConstants.pollInterval, (_) {
      unawaited(emitCurrent());
    });
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await controller.close();
  }
}
