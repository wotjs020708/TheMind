import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String code,
    @JsonKey(name: 'player_count') required int playerCount,
    required String status,
    @JsonKey(name: 'current_level') required int currentLevel,
    required int lives,
    required int shurikens,
    @JsonKey(name: 'played_cards') required List<int> playedCards,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}
