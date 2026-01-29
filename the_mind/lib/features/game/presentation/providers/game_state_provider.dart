import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/player.dart';
import '../../domain/models/game_config.dart';
import '../../domain/enums/game_phase.dart';
import '../../domain/services/game_logic_service.dart';
import '../../../lobby/domain/models/room.dart';
import '../../../lobby/data/repositories/room_repository.dart';
import '../../../lobby/data/repositories/player_repository.dart';
import '../../data/repositories/game_event_repository.dart';
import '../../data/repositories/shuriken_vote_repository.dart';
import '../../../../shared/providers/supabase_provider.dart';

/// Game State Provider 파라미터
class GameStateParams {
  final String roomId;
  final String? currentPlayerId;

  const GameStateParams({required this.roomId, this.currentPlayerId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateParams &&
          runtimeType == other.runtimeType &&
          roomId == other.roomId &&
          currentPlayerId == other.currentPlayerId;

  @override
  int get hashCode => roomId.hashCode ^ currentPlayerId.hashCode;
}

/// Game State Provider
///
/// 게임의 전체 상태를 관리하는 메인 Provider입니다.
/// - Room, Player, GameEvent, ShurikenVote Repository 통합
/// - 실시간 동기화 (Supabase Realtime)
/// - 게임 로직 조율 (GameLogicService 활용)
final gameStateProvider = StateNotifierProvider.autoDispose
    .family<GameStateNotifier, AsyncValue<GameState>, GameStateParams>((
      ref,
      params,
    ) {
      final supabase = ref.watch(supabaseProvider);
      final roomRepo = RoomRepository(supabase);
      final playerRepo = PlayerRepository(supabase);
      final eventRepo = GameEventRepository(supabase);
      final voteRepo = ShurikenVoteRepository(supabase);
      final gameLogic = GameLogicService();

      return GameStateNotifier(
        roomId: params.roomId,
        currentPlayerId: params.currentPlayerId,
        roomRepo: roomRepo,
        playerRepo: playerRepo,
        eventRepo: eventRepo,
        voteRepo: voteRepo,
        gameLogic: gameLogic,
      );
    });

class GameStateNotifier extends StateNotifier<AsyncValue<GameState>> {
  final String roomId;
  final String? currentPlayerId;
  final RoomRepository roomRepo;
  final PlayerRepository playerRepo;
  final GameEventRepository eventRepo;
  final ShurikenVoteRepository voteRepo;
  final GameLogicService gameLogic;
  final Set<String> _processedEventIds = {};

  StreamSubscription<Room>? _roomSubscription;
  StreamSubscription<List<Player>>? _playersSubscription;
  StreamSubscription<GameEvent>? _eventsSubscription;

  GameStateNotifier({
    required this.roomId,
    this.currentPlayerId,
    required this.roomRepo,
    required this.playerRepo,
    required this.eventRepo,
    required this.voteRepo,
    required this.gameLogic,
  }) : super(const AsyncValue.loading()) {
    _initialize();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _playersSubscription?.cancel();
    _eventsSubscription?.cancel();
    super.dispose();
  }

  /// 초기화: Room 및 Player 실시간 구독 시작
  Future<void> _initialize() async {
    try {
      // Room 초기 데이터 가져오기
      final room = await roomRepo.getRoomById(roomId);
      final players = await playerRepo.getPlayersByRoom(roomId);

      // 초기 GameState 생성
      state = AsyncValue.data(_createGameState(room, players));

      // 게임이 이미 시작된 상태이고 플레이어들에게 카드가 없으면 배분
      if (room.status == 'playing') {
        final hasCards = players.any((p) => p.cards.isNotEmpty);
        if (!hasCards) {
          // Only host distributes cards
          final isHost =
              players.isNotEmpty && players.first.id == currentPlayerId;
          if (isHost) {
            // 카드 배분 (레벨 = 각 플레이어당 카드 수)
            await _distributeCards(room.currentLevel);
          }
        }
      }

      // Room 실시간 구독
      _roomSubscription = roomRepo
          .subscribeToRoom(roomId)
          .listen(
            (room) {
              state.whenData((currentState) {
                state = AsyncValue.data(
                  currentState.copyWith(
                    currentLevel: room.currentLevel,
                    lives: room.lives,
                    shurikens: room.shurikens,
                    playedCards: room.playedCards,
                    phase: _mapRoomStatusToPhase(room.status),
                  ),
                );
              });
            },
            onError: (error) {
              state = AsyncValue.error(error, StackTrace.current);
            },
          );

      // Players 실시간 구독
      _playersSubscription = playerRepo
          .subscribeToplayers(roomId)
          .listen(
            (players) {
              state.whenData((currentState) {
                state = AsyncValue.data(
                  currentState.copyWith(players: players),
                );
              });
            },
            onError: (error) {
              state = AsyncValue.error(error, StackTrace.current);
            },
          );

      // GameEvents 실시간 구독
      _eventsSubscription = eventRepo
          .subscribeToEvents(roomId)
          .listen(
            (event) {
              _handleGameEvent(event);
            },
            onError: (error) {
              state = AsyncValue.error(error, StackTrace.current);
            },
          );
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Room과 Player 목록으로 GameState 생성
  GameState _createGameState(Room room, List<Player> players) {
    return GameState(
      roomId: room.id,
      config: GameConfig.forPlayerCount(room.playerCount),
      players: players,
      currentLevel: room.currentLevel,
      lives: room.lives,
      shurikens: room.shurikens,
      playedCards: room.playedCards,
      phase: _mapRoomStatusToPhase(room.status),
    );
  }

  /// Room status를 GamePhase로 매핑
  GamePhase _mapRoomStatusToPhase(String status) {
    switch (status) {
      case 'waiting':
        return GamePhase.lobby;
      case 'playing':
        return GamePhase.playing;
      case 'completed':
        return GamePhase.victory;
      case 'failed':
        return GamePhase.gameOver;
      default:
        return GamePhase.lobby;
    }
  }

  /// GameEvent 처리
  void _handleGameEvent(GameEvent event) {
    // Skip already processed events
    if (_processedEventIds.contains(event.id)) return;
    _processedEventIds.add(event.id);

    switch (event.eventType) {
      case GameEventType.cardPlayed:
        _handleCardPlayed(event);
        break;
      case GameEventType.mistakeOccurred:
        _handleMistakeOccurred(event);
        break;
      case GameEventType.levelComplete:
        _handleLevelComplete(event);
        break;
      case GameEventType.shurikenProposed:
        _handleShurikenProposed(event);
        break;
      case GameEventType.shurikenUsed:
        _handleShurikenUsed(event);
        break;
      case GameEventType.gameStarted:
      case GameEventType.gameEnded:
        // Room subscription에서 처리됨
        break;
    }
  }

  /// 카드 낸 이벤트 처리
  void _handleCardPlayed(GameEvent event) {
    final cardNumber = event.data?['card_number'] as int?;
    if (cardNumber == null) return;

    state.whenData((currentState) {
      // Idempotency check: skip if card already played
      if (currentState.playedCards.contains(cardNumber)) return;

      // 실수 여부 검증
      if (!gameLogic.isValidCardPlay(cardNumber, currentState.playedCards)) {
        // 실수 발생
        _triggerMistake(cardNumber);
      } else {
        // 정상 플레이: playedCards에 추가
        final newPlayedCards = [...currentState.playedCards, cardNumber];
        state = AsyncValue.data(
          currentState.copyWith(playedCards: newPlayedCards),
        );

        // Room 업데이트
        roomRepo.updateRoom(roomId: roomId, playedCards: newPlayedCards);

        // 플레이어 카드 제거
        final playerId = event.playerId;
        if (playerId != null) {
          _removeCardFromPlayer(playerId, cardNumber);
        }

        // 레벨 완료 체크
        _checkLevelComplete();
      }
    });
  }

  /// 실수 발생 이벤트 처리
  void _handleMistakeOccurred(GameEvent event) {
    state.whenData((currentState) {
      final newLives = currentState.lives - 1;

      // 생명 감소 (로컬 상태 - 모든 클라이언트)
      state = AsyncValue.data(currentState.copyWith(lives: newLives));

      // DB 업데이트 및 패배 체크 (호스트만)
      final isHost =
          currentState.players.isNotEmpty &&
          currentState.players.first.id == currentPlayerId;
      if (isHost) {
        roomRepo.updateRoom(roomId: roomId, lives: newLives);

        // 패배 체크
        if (gameLogic.checkDefeat(newLives)) {
          _endGame(victory: false);
        }
      }
    });
  }

  /// 레벨 완료 이벤트 처리
  void _handleLevelComplete(GameEvent event) {
    state.whenData((currentState) {
      final nextLevel = currentState.currentLevel + 1;

      // 보상 적용
      final rewards = gameLogic.applyLevelReward(currentState.currentLevel);
      final newShurikens = currentState.shurikens + (rewards['shurikens'] ?? 0);
      final newLives = currentState.lives + (rewards['lives'] ?? 0);

      // 승리 조건 체크
      if (gameLogic.checkVictory(nextLevel, currentState.config.maxLevel)) {
        // 게임 승리
        _endGame(victory: true);
      } else {
        // 다음 레벨 시작
        state = AsyncValue.data(
          currentState.copyWith(
            currentLevel: nextLevel,
            shurikens: newShurikens,
            lives: newLives,
            playedCards: [],
          ),
        );

        roomRepo.updateRoom(
          roomId: roomId,
          currentLevel: nextLevel,
          shurikens: newShurikens,
          lives: newLives,
          playedCards: [],
        );

        // Only host distributes cards
        final isHost =
            currentState.players.isNotEmpty &&
            currentState.players.first.id == currentPlayerId;
        if (isHost) {
          _distributeCards(nextLevel);
        }
      }
    });
  }

  /// 수리검 제안 이벤트 처리
  void _handleShurikenProposed(GameEvent event) {
    // UI에서 투표 다이얼로그 표시 (이벤트 전달용)
  }

  /// 수리검 사용 이벤트 처리
  void _handleShurikenUsed(GameEvent event) {
    state.whenData((currentState) {
      // 수리검 사용: 모든 플레이어의 최소 카드 제거 (계산은 모든 클라이언트)
      final removedCards = gameLogic.useShurikenEffect(currentState.players);

      // 수리검 감소 (로컬 상태 - 모든 클라이언트)
      final newShurikens = currentState.shurikens - 1;
      state = AsyncValue.data(currentState.copyWith(shurikens: newShurikens));

      // DB 업데이트 및 카드 제거 (호스트만)
      final isHost =
          currentState.players.isNotEmpty &&
          currentState.players.first.id == currentPlayerId;
      if (isHost) {
        roomRepo.updateRoom(roomId: roomId, shurikens: newShurikens);

        // 각 플레이어 카드 업데이트
        for (final entry in removedCards.entries) {
          final playerId = entry.key;
          final removedCard = entry.value;
          if (removedCard != null) {
            _removeCardFromPlayer(playerId, removedCard.number);
          }
        }
      }
    });
  }

  // ============================================
  // Public Methods (UI에서 호출)
  // ============================================

  /// 게임 시작 (로비 → 게임)
  Future<void> startGame() async {
    await roomRepo.updateRoomStatus(roomId, 'playing');
    await eventRepo.sendEvent(
      roomId: roomId,
      eventType: GameEventType.gameStarted,
    );

    // Only host distributes cards
    state.whenData((currentState) {
      final isHost =
          currentState.players.isNotEmpty &&
          currentState.players.first.id == currentPlayerId;
      if (isHost) {
        _distributeCards(1);
      }
    });
  }

  /// 카드 내기
  Future<void> playCard({
    required String playerId,
    required int cardNumber,
  }) async {
    // 이벤트 전송 (다른 플레이어들에게 브로드캐스트)
    await eventRepo.sendEvent(
      roomId: roomId,
      eventType: GameEventType.cardPlayed,
      playerId: playerId,
      data: {'card_number': cardNumber},
    );
  }

  /// 수리검 사용 제안
  Future<String> proposeShurikenUse(String playerId) async {
    final proposalId = const Uuid().v4();

    await eventRepo.sendEvent(
      roomId: roomId,
      eventType: GameEventType.shurikenProposed,
      playerId: playerId,
      data: {'proposal_id': proposalId},
    );

    return proposalId;
  }

  /// 수리검 투표
  Future<void> voteShurikenUse({
    required String proposalId,
    required String playerId,
    required bool vote,
  }) async {
    await voteRepo.submitVote(
      roomId: roomId,
      proposalId: proposalId,
      playerId: playerId,
      vote: vote,
    );

    // 만장일치 확인
    state.whenData((currentState) async {
      final isUnanimous = await voteRepo.isUnanimous(
        proposalId: proposalId,
        expectedPlayerCount: currentState.players.length,
      );

      if (isUnanimous) {
        // 수리검 사용
        await eventRepo.sendEvent(
          roomId: roomId,
          eventType: GameEventType.shurikenUsed,
          data: {'proposal_id': proposalId},
        );

        // 투표 데이터 삭제
        await voteRepo.deleteVotesByProposal(proposalId);
      }
    });
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// 카드 배분
  Future<void> _distributeCards(int level) async {
    state.whenData((currentState) async {
      final distribution = gameLogic.distributeCards(
        level,
        currentState.players,
      );

      for (final entry in distribution.entries) {
        final playerId = entry.key;
        final cards = entry.value;
        await playerRepo.updatePlayerCards(
          playerId: playerId,
          cards: cards.map((c) => c.number).toList(),
        );
      }
    });
  }

  /// 플레이어 카드 제거
  Future<void> _removeCardFromPlayer(String playerId, int cardNumber) async {
    state.whenData((currentState) async {
      final player = currentState.players.firstWhere((p) => p.id == playerId);
      final newCards =
          player.cards.where((c) => c.number != cardNumber).toList();
      await playerRepo.updatePlayerCards(
        playerId: playerId,
        cards: newCards.map((c) => c.number).toList(),
      );
    });
  }

  /// 레벨 완료 체크
  Future<void> _checkLevelComplete() async {
    state.whenData((currentState) async {
      // 모든 플레이어의 카드가 비어있으면 레벨 완료
      final allCardsPlayed = currentState.players.every(
        (player) => player.cards.isEmpty,
      );

      if (allCardsPlayed) {
        // 호스트만 이벤트 전송
        final isHost =
            currentState.players.isNotEmpty &&
            currentState.players.first.id == currentPlayerId;
        if (isHost) {
          await eventRepo.sendEvent(
            roomId: roomId,
            eventType: GameEventType.levelComplete,
          );
        }
      }
    });
  }

  /// 실수 트리거
  Future<void> _triggerMistake(int cardNumber) async {
    state.whenData((currentState) async {
      // 호스트만 실수 처리 수행
      final isHost =
          currentState.players.isNotEmpty &&
          currentState.players.first.id == currentPlayerId;
      if (!isHost) return;

      // 실수 처리: 낸 카드보다 작은 카드 공개 및 제거
      final discardedCards = gameLogic.handleMistake(
        cardNumber,
        currentState.players,
      );

      // 각 플레이어 카드 업데이트
      for (final player in currentState.players) {
        final newCards =
            player.cards.where((c) => c.number >= cardNumber).toList();
        await playerRepo.updatePlayerCards(
          playerId: player.id,
          cards: newCards.map((c) => c.number).toList(),
        );
      }

      // 실수 이벤트 전송
      await eventRepo.sendEvent(
        roomId: roomId,
        eventType: GameEventType.mistakeOccurred,
        data: {
          'card_number': cardNumber,
          'discarded_cards': discardedCards.map((c) => c.number).toList(),
        },
      );
    });
  }

  /// 게임 종료
  Future<void> _endGame({required bool victory}) async {
    final status = victory ? 'completed' : 'failed';
    await roomRepo.updateRoomStatus(roomId, status);
    await eventRepo.sendEvent(
      roomId: roomId,
      eventType: GameEventType.gameEnded,
      data: {'victory': victory},
    );
  }
}
