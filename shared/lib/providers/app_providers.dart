import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/call_request.dart';
import '../models/message.dart';
import '../models/session_log.dart';
import '../models/user.dart';
import '../repositories/call_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/session_log_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/call_service.dart';
import '../services/chat_service.dart';
import '../services/hms_service.dart';
import '../services/log_service.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repository = ChatRepository()..startPolling();
  ref.onDispose(repository.dispose);
  return repository;
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final repository = UserRepository()..startPolling();
  ref.onDispose(repository.dispose);
  return repository;
});

final callRepositoryProvider = Provider<CallRepository>((ref) {
  final repository = CallRepository(
    chatRepository: ref.watch(chatRepositoryProvider),
  )..startPolling();
  ref.onDispose(repository.dispose);
  return repository;
});

final sessionLogRepositoryProvider = Provider<SessionLogRepository>((ref) {
  final repository = SessionLogRepository()..startPolling();
  ref.onDispose(repository.dispose);
  return repository;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(userRepository: ref.watch(userRepositoryProvider));
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(repository: ref.watch(chatRepositoryProvider));
});

final callServiceProvider = Provider<CallService>((ref) {
  return CallService(repository: ref.watch(callRepositoryProvider));
});

final logServiceProvider = Provider<LogService>((ref) {
  return LogService(repository: ref.watch(sessionLogRepositoryProvider));
});

/// One HmsService per in-call screen lifetime.
/// Use `ProviderScope.overrides` or `.autoDispose` at the in-call route level.
final hmsServiceProvider = Provider.autoDispose<HmsService>((ref) {
  final service = HmsService();
  ref.onDispose(service.dispose);
  return service;
});

final hmsStateProvider = StreamProvider.autoDispose<HmsRoomState>((ref) {
  return ref.watch(hmsServiceProvider).stream;
});

final usersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).stream;
});

final messagesStreamProvider = StreamProvider<List<Message>>((ref) {
  return ref.watch(chatRepositoryProvider).stream;
});

final callRequestsStreamProvider = StreamProvider<List<CallRequest>>((ref) {
  return ref.watch(callRepositoryProvider).stream;
});

final sessionLogsStreamProvider = StreamProvider<List<SessionLog>>((ref) {
  return ref.watch(sessionLogRepositoryProvider).stream;
});
