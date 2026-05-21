import '../models/app_role.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../utils/app_constants.dart';
import 'base_polling_repository.dart';

class UserRepository extends BasePollingRepository<AppUser> {
  @override
  Future<List<AppUser>> load() async {
    final list = await ApiClient.getList('/users');
    if (list.isEmpty) return _defaultUsers();
    return list.map((json) => AppUser.fromJson(json)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<AppUser?> byId(String id) async {
    final all = await load();
    try {
      return all.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns hardcoded fallback users in case server is unreachable.
  List<AppUser> _defaultUsers() {
    return [
      const AppUser(
        id: AppConstants.trainerId,
        role: AppRole.trainer,
        name: 'Aarav',
        email: 'aarav@wtf.local',
        avatarUrl: 'A',
      ),
      const AppUser(
        id: AppConstants.memberId,
        role: AppRole.member,
        name: 'DK',
        email: 'dk@wtf.local',
        avatarUrl: 'DK',
        assignedTrainerId: AppConstants.trainerId,
      ),
    ];
  }
}
