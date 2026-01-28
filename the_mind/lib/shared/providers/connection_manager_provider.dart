import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 네트워크 연결 상태 모니터링
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// 연결 상태
enum ConnectionStatus { connected, disconnected, reconnecting }

/// 연결 관리 상태
class ConnectionState {
  final ConnectionStatus status;
  final DateTime? lastConnected;
  final int reconnectAttempts;
  final String? error;

  const ConnectionState({
    this.status = ConnectionStatus.connected,
    this.lastConnected,
    this.reconnectAttempts = 0,
    this.error,
  });

  ConnectionState copyWith({
    ConnectionStatus? status,
    DateTime? lastConnected,
    int? reconnectAttempts,
    String? error,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      lastConnected: lastConnected ?? this.lastConnected,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
      error: error ?? this.error,
    );
  }

  bool get isConnected => status == ConnectionStatus.connected;
  bool get isDisconnected => status == ConnectionStatus.disconnected;
  bool get isReconnecting => status == ConnectionStatus.reconnecting;
}

/// 연결 관리 Provider
final connectionManagerProvider =
    StateNotifierProvider<ConnectionManager, ConnectionState>((ref) {
      return ConnectionManager(ref);
    });

class ConnectionManager extends StateNotifier<ConnectionState> {
  final Ref ref;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<AuthState>? _authSubscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 3);
  static const Duration pingInterval = Duration(seconds: 30);

  ConnectionManager(this.ref) : super(const ConnectionState()) {
    _initConnectivityMonitoring();
    _initSupabaseMonitoring();
    _startPingTimer();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    super.dispose();
  }

  void _initConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      _handleConnectivityChange(results);
    });
  }

  void _initSupabaseMonitoring() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        // 로그아웃 시 연결 상태 초기화
        state = state.copyWith(
          status: ConnectionStatus.disconnected,
          error: 'Signed out',
        );
      }
    });
  }

  void _startPingTimer() {
    _pingTimer = Timer.periodic(pingInterval, (_) async {
      if (state.isConnected) {
        await _checkSupabaseConnection();
      }
    });
  }

  Future<void> _checkSupabaseConnection() async {
    try {
      // Supabase 연결 확인 (간단한 쿼리)
      await Supabase.instance.client.from('rooms').select('id').limit(1);
    } catch (e) {
      // 연결 실패 시 재접속 시도
      if (state.isConnected) {
        state = state.copyWith(
          status: ConnectionStatus.disconnected,
          error: 'Supabase connection lost',
        );
        _attemptReconnect();
      }
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection =
        results.isNotEmpty &&
        !results.every((result) => result == ConnectivityResult.none);

    if (!hasConnection) {
      // 네트워크 연결 끊김
      state = state.copyWith(
        status: ConnectionStatus.disconnected,
        error: 'No network connection',
      );
      _cancelReconnect();
    } else {
      // 네트워크 연결 복구됨
      if (state.isDisconnected) {
        _attemptReconnect();
      } else {
        state = state.copyWith(
          status: ConnectionStatus.connected,
          lastConnected: DateTime.now(),
          reconnectAttempts: 0,
          error: null,
        );
      }
    }
  }

  void _attemptReconnect() {
    if (state.reconnectAttempts >= maxReconnectAttempts) {
      // 최대 재시도 횟수 초과
      state = state.copyWith(
        status: ConnectionStatus.disconnected,
        error: 'Max reconnect attempts reached',
      );
      return;
    }

    state = state.copyWith(
      status: ConnectionStatus.reconnecting,
      reconnectAttempts: state.reconnectAttempts + 1,
    );

    _reconnectTimer = Timer(reconnectDelay, () async {
      await _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    try {
      // 1. 네트워크 연결 확인
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasNetwork =
          connectivityResult.isNotEmpty &&
          !connectivityResult.every(
            (result) => result == ConnectivityResult.none,
          );

      if (!hasNetwork) {
        // 네트워크 연결 없음 - 재시도
        _attemptReconnect();
        return;
      }

      // 2. Supabase 연결 확인
      await Supabase.instance.client.from('rooms').select('id').limit(1);

      // 연결 성공
      state = state.copyWith(
        status: ConnectionStatus.connected,
        lastConnected: DateTime.now(),
        reconnectAttempts: 0,
        error: null,
      );
    } catch (e) {
      // 연결 실패 - 재시도
      _attemptReconnect();
    }
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// 수동 재연결 시도
  Future<void> manualReconnect() async {
    state = state.copyWith(reconnectAttempts: 0, error: null);
    await _checkConnection();
  }

  /// 연결 상태 초기화
  void reset() {
    state = const ConnectionState();
    _cancelReconnect();
  }
}
