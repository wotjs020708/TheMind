// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameStateImpl _$$GameStateImplFromJson(Map<String, dynamic> json) =>
    _$GameStateImpl(
      roomId: json['roomId'] as String,
      config: GameConfig.fromJson(json['config'] as Map<String, dynamic>),
      players:
          (json['players'] as List<dynamic>)
              .map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList(),
      currentLevel: (json['currentLevel'] as num).toInt(),
      lives: (json['lives'] as num).toInt(),
      shurikens: (json['shurikens'] as num).toInt(),
      playedCards:
          (json['playedCards'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
      phase: $enumDecode(_$GamePhaseEnumMap, json['phase']),
      winnerId: json['winnerId'] as String?,
    );

Map<String, dynamic> _$$GameStateImplToJson(_$GameStateImpl instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'config': instance.config,
      'players': instance.players,
      'currentLevel': instance.currentLevel,
      'lives': instance.lives,
      'shurikens': instance.shurikens,
      'playedCards': instance.playedCards,
      'phase': _$GamePhaseEnumMap[instance.phase]!,
      'winnerId': instance.winnerId,
    };

const _$GamePhaseEnumMap = {
  GamePhase.lobby: 'lobby',
  GamePhase.ready: 'ready',
  GamePhase.playing: 'playing',
  GamePhase.levelComplete: 'levelComplete',
  GamePhase.gameOver: 'gameOver',
  GamePhase.victory: 'victory',
};
