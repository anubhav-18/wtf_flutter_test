import '../models/app_role.dart';
import '../models/user.dart';
import '../services/hive_storage_service.dart';
import '../utils/app_constants.dart';
import 'base_polling_repository.dart';

class UserRepository extends BasePollingRepository<AppUser> {
  Future<void> seedUsers() async {
    final box = HiveStorageService.users();
    await box.put(
      AppConstants.trainerId,
      const AppUser(
        id: AppConstants.trainerId,
        role: AppRole.trainer,
        name: 'Aarav',
        email: 'aarav@wtf.local',
        avatarUrl: 'A',
      ).toJson(),
    );
    await box.put(
      AppConstants.memberId,
      const AppUser(
        id: AppConstants.memberId,
        role: AppRole.member,
        name: 'DK',
        email: 'dk@wtf.local',
        avatarUrl: 'DK',
        assignedTrainerId: AppConstants.trainerId,
      ).toJson(),
    );
    await emitCurrent();
  }

  @override
  Future<List<AppUser>> load() async {
    return HiveStorageService.users()
        .values
        .map((json) => AppUser.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<AppUser?> byId(String id) async {
    final json = HiveStorageService.users().get(id);
    if (json == null) {
      return null;
    }
    return AppUser.fromJson(Map<String, dynamic>.from(json));
  }
}
