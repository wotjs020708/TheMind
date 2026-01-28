import 'package:supabase_flutter/supabase_flutter.dart';

/// 게임 이벤트 타입
enum GameEventType {
  gameStarted('game_started'),
  cardPlayed('card_played'),
  mistakeOccurred('mistake_occurred'),
  levelComplete('level_complete'),
  shurikenProposed('shuriken_proposed'),
  shurikenUsed('shuriken_used'),
  gameEnded('game_ended');

  final String value;
  const GameEventType(this.value);

  static GameEventType fromString(String value) {
    return GameEventType.values.firstWhere((e) => e.value == value);
  }
}

/// 게임 이벤트 모델
class GameEvent {
  final String id;
  final String roomId;
  final GameEventType eventType;
  final String? playerId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  const GameEvent({
    required this.id,
    required this.roomId,
    required this.eventType,
    this.playerId,
    this.data,
    required this.createdAt,
  });

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    return GameEvent(
      id: json['id'],
      roomId: json['room_id'],
      eventType: GameEventType.fromString(json['event_type']),
      playerId: json['player_id'],
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class GameEventRepository {
  final SupabaseClient _supabase;

  GameEventRepository(this._supabase);

  /// 카드 내기 이벤트 전송
  Future<void> sendCardPlayedEvent({
    required String roomId,
    required String playerId,
    required int cardNumber,
  }) async {
    await _supabase.from('game_events').insert({
      'room_id': roomId,
      'event_type': GameEventType.cardPlayed.value,
      'player_id': playerId,
      'data': {'card': cardNumber},
    });
  }

  /// 실수 발생 이벤트 전송
  Future<void> sendMistakeEvent({
    required String roomId,
    required String playerId,
    required int playedCard,
    required int expectedCard,
  }) async {
    await _supabase.from('game_events').insert({
      'room_id': roomId,
      'event_type': GameEventType.mistakeOccurred.value,
      'player_id': playerId,
      'data': {'played_card': playedCard, 'expected_card': expectedCard},
    });
  }

  /// 레벨 완료 이벤트 전송
  Future<void> sendLevelCompleteEvent({
    required String roomId,
    required int level,
    String? reward,
  }) async {
    await _supabase.from('game_events').insert({
      'room_id': roomId,
      'event_type': GameEventType.levelComplete.value,
      'data': {'level': level, if (reward != null) 'reward': reward},
    });
  }

  /// 수리검 제안 이벤트 전송
  Future<String> sendShurikenProposalEvent({
    required String roomId,
    required String playerId,
  }) async {
    final response =
        await _supabase
            .from('game_events')
            .insert({
              'room_id': roomId,
              'event_type': GameEventType.shurikenProposed.value,
              'player_id': playerId,
            })
            .select()
            .single();

    return response['id']; // proposal_id로 사용
  }

  /// 수리검 사용 이벤트 전송
  Future<void> sendShurikenUsedEvent({
    required String roomId,
    required List<int> removedCards,
  }) async {
    await _supabase.from('game_events').insert({
      'room_id': roomId,
      'event_type': GameEventType.shurikenUsed.value,
      'data': {'removed_cards': removedCards},
    });
  }

  /// 게임 종료 이벤트 전송
  Future<void> sendGameEndedEvent({
    required String roomId,
    required bool isVictory,
    required int finalLevel,
  }) async {
    await _supabase.from('game_events').insert({
      'room_id': roomId,
      'event_type': GameEventType.gameEnded.value,
      'data': {'is_victory': isVictory, 'final_level': finalLevel},
    });
  }

  /// 범용 이벤트 전송 메서드
  Future<void> sendEvent({
    required String roomId,
    required GameEventType eventType,
    String? playerId,
    Map<String, dynamic>? data,
  }) async {
    await _supabase.from('game_events').insert({
      'room_id': roomId,
      'event_type': eventType.value,
      if (playerId != null) 'player_id': playerId,
      if (data != null) 'data': data,
    });
  }

  /// 게임 이벤트 실시간 구독
  Stream<GameEvent> subscribeToEvents(String roomId) {
    return _supabase
        .from('game_events')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((data) => data.map((json) => GameEvent.fromJson(json)))
        .expand((events) => events); // List<GameEvent>를 개별 GameEvent로 변환
  }

  /// 특정 시간 이후 이벤트 조회 (재접속 시 사용)
  Future<List<GameEvent>> getEventsSince({
    required String roomId,
    required DateTime since,
  }) async {
    final response = await _supabase
        .from('game_events')
        .select()
        .eq('room_id', roomId)
        .gte('created_at', since.toIso8601String())
        .order('created_at');

    return (response as List).map((json) => GameEvent.fromJson(json)).toList();
  }
}
