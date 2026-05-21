import '../repositories/user_repository.dart';
import 'hive_storage_service.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> init() async {
    await HiveStorageService.init();
    await UserRepository().seedUsers();
  }
}
