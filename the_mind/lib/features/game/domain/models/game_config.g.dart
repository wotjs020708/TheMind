// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameConfigImpl _$$GameConfigImplFromJson(Map<String, dynamic> json) =>
    _$GameConfigImpl(
      playerCount: (json['playerCount'] as num).toInt(),
      maxLevel: (json['maxLevel'] as num).toInt(),
      initialLives: (json['initialLives'] as num).toInt(),
      initialShurikens: (json['initialShurikens'] as num).toInt(),
    );

Map<String, dynamic> _$$GameConfigImplToJson(_$GameConfigImpl instance) =>
    <String, dynamic>{
      'playerCount': instance.playerCount,
      'maxLevel': instance.maxLevel,
      'initialLives': instance.initialLives,
      'initialShurikens': instance.initialShurikens,
    };
