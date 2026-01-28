import 'package:supabase_flutter/supabase_flutter.dart';

/// 수리검 투표 Repository
///
/// 수리검 제안에 대한 플레이어들의 투표를 관리합니다.
/// - 투표 제출
/// - 투표 현황 조회
/// - 만장일치 확인
/// - 실시간 투표 구독
class ShurikenVoteRepository {
  final SupabaseClient _supabase;

  ShurikenVoteRepository(this._supabase);

  /// 수리검 제안에 대한 투표 제출
  ///
  /// [roomId]: 방 ID
  /// [proposalId]: 제안 ID (UUID 문자열)
  /// [playerId]: 플레이어 ID
  /// [vote]: true = 찬성, false = 반대
  Future<void> submitVote({
    required String roomId,
    required String proposalId,
    required String playerId,
    required bool vote,
  }) async {
    await _supabase.from('shuriken_votes').insert({
      'room_id': roomId,
      'proposal_id': proposalId,
      'player_id': playerId,
      'vote': vote,
    });
  }

  /// 특정 제안의 모든 투표 조회
  ///
  /// [proposalId]: 제안 ID
  /// Returns: `List<Map<String, dynamic>>` - 투표 목록
  Future<List<Map<String, dynamic>>> getVotes(String proposalId) async {
    final response = await _supabase
        .from('shuriken_votes')
        .select()
        .eq('proposal_id', proposalId);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// 특정 제안에 대한 투표 실시간 구독
  ///
  /// [proposalId]: 제안 ID
  /// Returns: `Stream<List<Map<String, dynamic>>>` - 투표 목록 스트림
  Stream<List<Map<String, dynamic>>> subscribeToVotes(String proposalId) {
    return _supabase
        .from('shuriken_votes')
        .stream(primaryKey: ['id'])
        .eq('proposal_id', proposalId)
        .map((list) => List<Map<String, dynamic>>.from(list));
  }

  /// 만장일치 여부 확인
  ///
  /// [proposalId]: 제안 ID
  /// [expectedPlayerCount]: 방의 총 플레이어 수
  /// Returns: true = 만장일치 찬성, false = 그 외
  ///
  /// 조건:
  /// 1. 모든 플레이어가 투표했는가? (투표 수 == 플레이어 수)
  /// 2. 모든 투표가 찬성인가? (vote == true)
  Future<bool> isUnanimous({
    required String proposalId,
    required int expectedPlayerCount,
  }) async {
    final votes = await getVotes(proposalId);

    // 투표 수가 플레이어 수와 일치하지 않으면 false
    if (votes.length != expectedPlayerCount) {
      return false;
    }

    // 모든 투표가 찬성이어야 true
    return votes.every((vote) => vote['vote'] == true);
  }

  /// 특정 플레이어가 이미 투표했는지 확인
  ///
  /// [proposalId]: 제안 ID
  /// [playerId]: 플레이어 ID
  /// Returns: true = 이미 투표함, false = 아직 투표 안 함
  Future<bool> hasVoted({
    required String proposalId,
    required String playerId,
  }) async {
    final response = await _supabase
        .from('shuriken_votes')
        .select()
        .eq('proposal_id', proposalId)
        .eq('player_id', playerId);

    final votes = List<Map<String, dynamic>>.from(response as List);
    return votes.isNotEmpty;
  }

  /// 특정 방의 모든 투표 삭제 (방 정리 시)
  ///
  /// [roomId]: 방 ID
  Future<void> deleteVotesByRoom(String roomId) async {
    await _supabase.from('shuriken_votes').delete().eq('room_id', roomId);
  }

  /// 특정 제안의 모든 투표 삭제 (제안 취소 시)
  ///
  /// [proposalId]: 제안 ID
  Future<void> deleteVotesByProposal(String proposalId) async {
    await _supabase
        .from('shuriken_votes')
        .delete()
        .eq('proposal_id', proposalId);
  }

  /// 투표 통계 조회
  ///
  /// [proposalId]: 제안 ID
  /// Returns: {'yes': 찬성 수, 'no': 반대 수, 'total': 총 투표 수}
  Future<Map<String, int>> getVoteStats(String proposalId) async {
    final votes = await getVotes(proposalId);

    int yesCount = 0;
    int noCount = 0;

    for (final vote in votes) {
      if (vote['vote'] == true) {
        yesCount++;
      } else {
        noCount++;
      }
    }

    return {'yes': yesCount, 'no': noCount, 'total': votes.length};
  }
}
