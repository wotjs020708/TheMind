import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/room.dart';
import '../../../../features/game/domain/models/game_config.dart';

class RoomRepository {
  final SupabaseClient _supabase;

  RoomRepository(this._supabase);

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<Room> createRoom(int playerCount) async {
    final code = _generateRoomCode();
    final config = GameConfig.forPlayerCount(playerCount);

    final response =
        await _supabase
            .from('rooms')
            .insert({
              'code': code,
              'player_count': playerCount,
              'lives': config.initialLives,
              'shurikens': config.initialShurikens,
            })
            .select()
            .single();

    return Room.fromJson(response);
  }

  Future<Room?> findRoomByCode(String code) async {
    final response =
        await _supabase
            .from('rooms')
            .select()
            .eq('code', code.toUpperCase())
            .maybeSingle();

    if (response == null) return null;
    return Room.fromJson(response);
  }

  Future<Room> getRoomById(String roomId) async {
    final response =
        await _supabase.from('rooms').select().eq('id', roomId).single();

    return Room.fromJson(response);
  }

  Future<void> updateRoomStatus(String roomId, String status) async {
    await _supabase.from('rooms').update({'status': status}).eq('id', roomId);
  }

  Future<void> deleteRoom(String roomId) async {
    await _supabase.from('rooms').delete().eq('id', roomId);
  }

  Stream<Room> subscribeToRoom(String roomId) {
    return _supabase
        .from('rooms')
        .stream(primaryKey: ['id'])
        .eq('id', roomId)
        .map((data) => Room.fromJson(data.first));
  }
}
