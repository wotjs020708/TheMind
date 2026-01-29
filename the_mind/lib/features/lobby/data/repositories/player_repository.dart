import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../game/domain/models/player.dart';
import '../../../../shared/models/game_card.dart';

class PlayerRepository {
  final SupabaseClient _supabase;
  final _uuid = const Uuid();

  PlayerRepository(this._supabase);

  /// 플레이어 추가
  Future<Player> addPlayer({
    required String roomId,
    required String name,
    required int position,
  }) async {
    final userId = _uuid.v4();

    final response =
        await _supabase
            .from('players')
            .insert({
              'room_id': roomId,
              'user_id': userId,
              'name': name,
              'position': position,
              'cards': [],
              'is_ready': false,
              'is_connected': true,
            })
            .select()
            .single();

    return _playerFromJson(response);
  }

  /// 방의 모든 플레이어 조회
  Future<List<Player>> getPlayersByRoom(String roomId) async {
    final response = await _supabase
        .from('players')
        .select()
        .eq('room_id', roomId)
        .order('created_at');

    return (response as List).map((json) => _playerFromJson(json)).toList();
  }

  /// 플레이어 준비 상태 업데이트
  Future<void> updateReadyStatus({
    required String playerId,
    required bool isReady,
  }) async {
    await _supabase
        .from('players')
        .update({'is_ready': isReady})
        .eq('id', playerId);
  }

  /// 플레이어 카드 업데이트
  Future<void> updatePlayerCards({
    required String playerId,
    required List<int> cards,
  }) async {
    await _supabase.from('players').update({'cards': cards}).eq('id', playerId);
  }

  /// 플레이어 연결 상태 업데이트
  Future<void> updateConnectionStatus({
    required String playerId,
    required bool isConnected,
  }) async {
    await _supabase
        .from('players')
        .update({'is_connected': isConnected})
        .eq('id', playerId);
  }

  /// 플레이어 제거
  Future<void> removePlayer(String playerId) async {
    await _supabase.from('players').delete().eq('id', playerId);
  }

  /// 방의 플레이어 실시간 구독
  Stream<List<Player>> subscribeToplayers(String roomId) {
    return _supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((data) => data.map((json) => _playerFromJson(json)).toList());
  }

  /// JSON을 Player 모델로 변환 (cards는 int[] → GameCard[])
  Player _playerFromJson(Map<String, dynamic> json) {
    final cardNumbers = (json['cards'] as List?)?.cast<int>() ?? [];
    final cards =
        cardNumbers.map((cardNum) => GameCard(number: cardNum)).toList();

    return Player(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      cards: cards,
      isReady: json['is_ready'] ?? false,
      isConnected: json['is_connected'] ?? true,
    );
  }
}
