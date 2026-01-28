import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String code,
    required int playerCount,
    required String status,
    required int currentLevel,
    required int lives,
    required int shurikens,
    required List<int> playedCards,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}
