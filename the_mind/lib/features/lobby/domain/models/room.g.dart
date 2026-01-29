// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  playerCount: (json['player_count'] as num).toInt(),
  status: json['status'] as String,
  currentLevel: (json['current_level'] as num).toInt(),
  lives: (json['lives'] as num).toInt(),
  shurikens: (json['shurikens'] as num).toInt(),
  playedCards:
      (json['played_cards'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'player_count': instance.playerCount,
      'status': instance.status,
      'current_level': instance.currentLevel,
      'lives': instance.lives,
      'shurikens': instance.shurikens,
      'played_cards': instance.playedCards,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
