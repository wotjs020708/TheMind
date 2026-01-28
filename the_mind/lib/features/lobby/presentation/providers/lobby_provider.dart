import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/room.dart';
import '../../../game/domain/models/player.dart';
import '../../data/repositories/room_repository.dart';
import '../../data/repositories/player_repository.dart';
import '../../../../shared/providers/supabase_provider.dart';

/// Lobby State
class LobbyState {
  final Room? room;
  final List<Player> players;
  final String? currentPlayerId;
  final bool isLoading;
  final String? error;

  const LobbyState({
    this.room,
    this.players = const [],
    this.currentPlayerId,
    this.isLoading = false,
    this.error,
  });

  LobbyState copyWith({
    Room? room,
    List<Player>? players,
    String? currentPlayerId,
    bool? isLoading,
    String? error,
  }) {
    return LobbyState(
      room: room ?? this.room,
      players: players ?? this.players,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  Player? get currentPlayer {
    if (currentPlayerId == null) return null;
    try {
      return players.firstWhere((p) => p.id == currentPlayerId);
    } catch (_) {
      return null;
    }
  }

  bool get allPlayersReady {
    if (room == null || players.isEmpty) return false;
    if (players.length != room!.playerCount) return false;
    return players.every((p) => p.isReady);
  }

  bool get isHost {
    if (currentPlayerId == null || players.isEmpty) return false;
    return players.first.id == currentPlayerId;
  }
}

/// Lobby Provider
final lobbyProvider =
    StateNotifierProvider.family<LobbyNotifier, LobbyState, String>((
      ref,
      roomCode,
    ) {
      final supabase = ref.watch(supabaseProvider);
      final roomRepo = RoomRepository(supabase);
      final playerRepo = PlayerRepository(supabase);

      return LobbyNotifier(
        roomCode: roomCode,
        roomRepo: roomRepo,
        playerRepo: playerRepo,
      );
    });

class LobbyNotifier extends StateNotifier<LobbyState> {
  final String roomCode;
  final RoomRepository roomRepo;
  final PlayerRepository playerRepo;

  StreamSubscription<Room>? _roomSubscription;
  StreamSubscription<List<Player>>? _playersSubscription;

  LobbyNotifier({
    required this.roomCode,
    required this.roomRepo,
    required this.playerRepo,
  }) : super(const LobbyState(isLoading: true)) {
    _initialize();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _playersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      // 방 정보 가져오기
      final room = await roomRepo.findRoomByCode(roomCode);
      if (room == null) {
        state = state.copyWith(isLoading: false, error: '방을 찾을 수 없습니다');
        return;
      }

      state = state.copyWith(room: room, isLoading: false);

      // 플레이어 목록 가져오기
      final players = await playerRepo.getPlayersByRoom(room.id);
      state = state.copyWith(players: players);

      // 실시간 구독 시작
      _subscribeToRoom(room.id);
      _subscribeToPlayers(room.id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _subscribeToRoom(String roomId) {
    _roomSubscription = roomRepo
        .subscribeToRoom(roomId)
        .listen(
          (room) {
            state = state.copyWith(room: room);
          },
          onError: (error) {
            state = state.copyWith(error: error.toString());
          },
        );
  }

  void _subscribeToPlayers(String roomId) {
    _playersSubscription = playerRepo
        .subscribeToplayers(roomId)
        .listen(
          (players) {
            state = state.copyWith(players: players);
          },
          onError: (error) {
            state = state.copyWith(error: error.toString());
          },
        );
  }

  /// 플레이어 추가 (방 참가 시)
  Future<String?> joinLobby(String playerName) async {
    if (state.room == null) return null;

    try {
      // 다음 포지션 계산
      final nextPosition = state.players.length;

      // 방이 꽉 찼는지 확인
      if (nextPosition >= state.room!.playerCount) {
        state = state.copyWith(error: '방이 가득 찼습니다');
        return null;
      }

      // 플레이어 추가
      final player = await playerRepo.addPlayer(
        roomId: state.room!.id,
        name: playerName,
        position: nextPosition,
      );

      // 현재 플레이어 ID 저장
      state = state.copyWith(currentPlayerId: player.id);

      return player.id;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// 준비 상태 토글
  Future<void> toggleReady() async {
    final currentPlayer = state.currentPlayer;
    if (currentPlayer == null) return;

    try {
      await playerRepo.updateReadyStatus(
        playerId: currentPlayer.id,
        isReady: !currentPlayer.isReady,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 게임 시작 (방장만)
  Future<void> startGame() async {
    if (!state.isHost || !state.allPlayersReady || state.room == null) {
      return;
    }

    try {
      await roomRepo.updateRoomStatus(state.room!.id, 'playing');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 방 나가기
  Future<void> leaveLobby() async {
    final currentPlayer = state.currentPlayer;
    if (currentPlayer == null) return;

    try {
      await playerRepo.removePlayer(currentPlayer.id);

      // 방장이 나가면 방 삭제
      if (state.isHost && state.room != null) {
        await roomRepo.deleteRoom(state.room!.id);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
