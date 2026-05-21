import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveStorageService {
  HiveStorageService._();

  static bool _initialized = false;

  static const usersBox = 'users';
  static const messagesBox = 'messages';
  static const callRequestsBox = 'call_requests';
  static const roomMetaBox = 'room_meta';
  static const sessionLogsBox = 'session_logs';
  static const appStateBox = 'app_state';

  static Future<void> init() async {
    if (_initialized) {
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    final path = Directory('${directory.path}/wtf_local_store');
    await path.create(recursive: true);
    await Hive.initFlutter(path.path);
    await Future.wait([
      Hive.openBox<Map>(usersBox),
      Hive.openBox<Map>(messagesBox),
      Hive.openBox<Map>(callRequestsBox),
      Hive.openBox<Map>(roomMetaBox),
      Hive.openBox<Map>(sessionLogsBox),
      Hive.openBox<dynamic>(appStateBox),
    ]);
    _initialized = true;
  }

  static Box<Map> users() => Hive.box<Map>(usersBox);
  static Box<Map> messages() => Hive.box<Map>(messagesBox);
  static Box<Map> callRequests() => Hive.box<Map>(callRequestsBox);
  static Box<Map> roomMeta() => Hive.box<Map>(roomMetaBox);
  static Box<Map> sessionLogs() => Hive.box<Map>(sessionLogsBox);
  static Box<dynamic> appState() => Hive.box<dynamic>(appStateBox);
}
