import 'hive_storage_service.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> init() async {
    // Hive still needed for auth state (onboarded flag, trainer login).
    // User data now lives on the shared backend server.
    await HiveStorageService.init();
  }
}
