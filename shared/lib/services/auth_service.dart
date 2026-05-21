import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../utils/app_constants.dart';
import 'dev_log_service.dart';
import 'hive_storage_service.dart';

class AuthService {
  AuthService({required this.userRepository});

  final UserRepository userRepository;

  Future<void> completeGuruOnboarding() async {
    await HiveStorageService.appState().put('guru_onboarded', true);
    DevLogService.add('[AUTH]', 'Guru onboarding completed');
  }

  Future<bool> isGuruOnboarded() async {
    return HiveStorageService.appState().get('guru_onboarded') == true;
  }

  Future<void> loginTrainer() async {
    await HiveStorageService.appState().put('trainer_logged_in', true);
    DevLogService.add('[AUTH]', 'Trainer logged in');
  }

  Future<bool> isTrainerLoggedIn() async {
    return HiveStorageService.appState().get('trainer_logged_in') == true;
  }

  Future<AppUser?> currentGuru() {
    return userRepository.byId(AppConstants.memberId);
  }

  Future<AppUser?> currentTrainer() {
    return userRepository.byId(AppConstants.trainerId);
  }
}
