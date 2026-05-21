import 'dart:async';
import 'dart:convert';


import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/app_role.dart';
import '../utils/app_constants.dart';
import 'dev_log_service.dart';

/// State emitted by [HmsService] to the UI.
class HmsRoomState {
  const HmsRoomState({
    this.isJoined = false,
    this.isConnecting = false,
    this.isReconnecting = false,
    this.isMicEnabled = true,
    this.isCameraEnabled = true,
    this.localPeer,
    this.remotePeer,
    this.error,
  });

  final bool isJoined;
  final bool isConnecting;
  final bool isReconnecting;
  final bool isMicEnabled;
  final bool isCameraEnabled;
  final HMSPeer? localPeer;
  final HMSPeer? remotePeer;
  final String? error;

  HmsRoomState copyWith({
    bool? isJoined,
    bool? isConnecting,
    bool? isReconnecting,
    bool? isMicEnabled,
    bool? isCameraEnabled,
    HMSPeer? localPeer,
    // nullable sentinel: pass an explicit null via forceNullRemote
    HMSPeer? remotePeer,
    bool forceNullRemote = false,
    String? error,
    bool clearError = false,
  }) {
    return HmsRoomState(
      isJoined: isJoined ?? this.isJoined,
      isConnecting: isConnecting ?? this.isConnecting,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
      localPeer: localPeer ?? this.localPeer,
      remotePeer: forceNullRemote ? null : (remotePeer ?? this.remotePeer),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Thin wrapper around [HMSSDK] for the WTF assessment.
///
/// Responsibilities:
/// - Fetch a short-lived JWT from the local token server.
/// - Join / leave a 100ms room.
/// - Toggle mic / camera / flip camera.
/// - Emit [HmsRoomState] updates via a [Stream].
/// - Auto-reconnect up to [_maxReconnectAttempts] times on error.
class HmsService implements HMSUpdateListener, HMSActionResultListener {
  HmsService();

  static const int _maxReconnectAttempts = 3;

  HMSSDK? _hmsdk;
  final StreamController<HmsRoomState> _stateController =
      StreamController<HmsRoomState>.broadcast();

  HmsRoomState _state = const HmsRoomState();
  int _reconnectAttempts = 0;
  String? _lastToken;
  String? _lastUserId;
  String? _lastRole;

  Stream<HmsRoomState> get stream => _stateController.stream;
  HmsRoomState get currentState => _state;

  void _emit(HmsRoomState next) {
    _state = next;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  // ── Token ─────────────────────────────────────────────────────────────────

  /// Fetches a JWT token from the local token server.
  Future<String> fetchToken({
    required String userId,
    required AppRole role,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.tokenServerBaseUrl}/token'
      '?userId=${Uri.encodeComponent(userId)}'
      '&role=${role.name}',
    );
    DevLogService.add('[RTC]', 'Fetching token for $userId (${role.name})');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Token server error ${response.statusCode}: ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final token = json['token'] as String;
    DevLogService.add('[RTC]', 'Token fetched ok (${token.length} chars)');
    return token;
  }

  // ── Join / Leave ──────────────────────────────────────────────────────────

  /// Joins the 100ms room. Fetches token first, then calls [HMSSDK.join].
  Future<void> join({
    required String userId,
    required AppRole role,
    String? preFetchedToken,
  }) async {
    _emit(_state.copyWith(isConnecting: true, clearError: true));
    try {
      final token = preFetchedToken ??
          await fetchToken(userId: userId, role: role);
      _lastToken = token;
      _lastUserId = userId;
      _lastRole = role.name;

      if (_hmsdk == null) {
        final sdk = HMSSDK();
        await sdk.build();
        sdk.addUpdateListener(listener: this);
        _hmsdk = sdk;
      }

      final config = HMSConfig(
        authToken: token,
        userName: userId,
      );
      _hmsdk!.join(config: config);
      DevLogService.add('[RTC]', 'join() called for $userId as ${role.name}');
    } catch (e) {
      DevLogService.add('[RTC]', 'join() error: $e');
      _emit(_state.copyWith(
        isConnecting: false,
        error: 'Failed to join: $e',
      ));
    }
  }

  /// Leaves the current room and cleans up.
  Future<void> leave() async {
    DevLogService.add('[RTC]', 'leave() called');
    _hmsdk?.leave(hmsActionResultListener: this);
  }

  void _teardown() {
    _hmsdk?.removeUpdateListener(listener: this);
    _hmsdk = null;
    _reconnectAttempts = 0;
    _emit(const HmsRoomState());
  }

  // ── Controls ──────────────────────────────────────────────────────────────

  void toggleMic() {
    _hmsdk?.toggleMicMuteState();
    _emit(_state.copyWith(isMicEnabled: !_state.isMicEnabled));
    DevLogService.add('[RTC]', 'mic -> ${!_state.isMicEnabled}');
  }

  void toggleCamera() {
    _hmsdk?.toggleCameraMuteState();
    _emit(_state.copyWith(isCameraEnabled: !_state.isCameraEnabled));
    DevLogService.add('[RTC]', 'cam -> ${!_state.isCameraEnabled}');
  }

  void switchCamera() {
    _hmsdk?.switchCamera(hmsActionResultListener: this);
    DevLogService.add('[RTC]', 'switchCamera()');
  }

  // ── HMSUpdateListener ─────────────────────────────────────────────────────

  @override
  void onJoin({required HMSRoom room}) {
    DevLogService.add('[RTC]', 'onJoin roomId=${room.id}');
    _reconnectAttempts = 0;
    _emit(_state.copyWith(isJoined: true, isConnecting: false, isReconnecting: false));
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    DevLogService.add('[RTC]', 'onPeerUpdate ${peer.name} $update');
    if (peer.isLocal) {
      _emit(_state.copyWith(localPeer: peer));
    } else {
      if (update == HMSPeerUpdate.peerLeft) {
        _emit(_state.copyWith(forceNullRemote: true));
      } else {
        _emit(_state.copyWith(remotePeer: peer));
      }
    }
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    DevLogService.add('[RTC]', 'onTrackUpdate ${peer.name} $trackUpdate');
    // Re-emit peer so video widget can rebuild.
    if (peer.isLocal) {
      _emit(_state.copyWith(localPeer: peer));
    } else {
      _emit(_state.copyWith(remotePeer: peer));
    }
  }

  @override
  void onHMSError({required HMSException error}) {
    DevLogService.add('[RTC]', 'onHMSError ${error.message}');
    _tryReconnect(error.message ?? 'Unknown error');
  }

  Future<void> _tryReconnect(String errorMessage) async {
    if (_reconnectAttempts >= _maxReconnectAttempts ||
        _lastToken == null ||
        _lastUserId == null ||
        _lastRole == null) {
      _emit(_state.copyWith(
        isJoined: false,
        isConnecting: false,
        isReconnecting: false,
        error: errorMessage,
      ));
      _teardown();
      return;
    }
    _reconnectAttempts++;
    DevLogService.add('[RTC]', 'Reconnect attempt $_reconnectAttempts');
    _emit(_state.copyWith(isReconnecting: true, clearError: true));
    await Future<void>.delayed(const Duration(seconds: 2));
    await join(
      userId: _lastUserId!,
      role: AppRole.fromJson(_lastRole!),
      preFetchedToken: _lastToken,
    );
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    DevLogService.add('[RTC]', 'onRoomUpdate $update');
    if (update == HMSRoomUpdate.serverRecordingStateUpdated) return;
  }

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onChangeTrackStateRequest({
    required HMSTrackChangeRequest hmsTrackChangeRequest,
  }) {}

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onReconnected() {
    DevLogService.add('[RTC]', 'onReconnected');
    _reconnectAttempts = 0;
    _emit(_state.copyWith(isReconnecting: false, isJoined: true));
  }

  @override
  void onReconnecting() {
    DevLogService.add('[RTC]', 'onReconnecting');
    _emit(_state.copyWith(isReconnecting: true));
  }

  @override
  void onRemovedFromRoom({
    required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer,
  }) {
    DevLogService.add('[RTC]', 'onRemovedFromRoom');
    _teardown();
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {
    DevLogService.add('[RTC]', 'onPeerListUpdate added=${addedPeers.length} removed=${removedPeers.length}');
    for (final peer in addedPeers) {
      if (peer.isLocal) {
        _emit(_state.copyWith(localPeer: peer));
      } else {
        _emit(_state.copyWith(remotePeer: peer));
      }
    }
    for (final peer in removedPeers) {
      if (!peer.isLocal && _state.remotePeer?.peerId == peer.peerId) {
        _emit(_state.copyWith(forceNullRemote: true));
      }
    }
  }

  // ── HMSActionResultListener ───────────────────────────────────────────────

  @override
  void onSuccess({
    HMSActionResultListenerMethod methodType =
        HMSActionResultListenerMethod.unknown,
    Map<String, dynamic>? arguments,
  }) {
    if (methodType == HMSActionResultListenerMethod.leave) {
      DevLogService.add('[RTC]', 'leave() success');
      _teardown();
    }
  }

  @override
  void onException({
    HMSActionResultListenerMethod methodType =
        HMSActionResultListenerMethod.unknown,
    Map<String, dynamic>? arguments,
    required HMSException hmsException,
  }) {
    DevLogService.add('[RTC]', 'action error $methodType: ${hmsException.message}');
    _emit(_state.copyWith(error: hmsException.message));
  }

  void dispose() {
    _hmsdk?.removeUpdateListener(listener: this);
    _stateController.close();
  }
}
