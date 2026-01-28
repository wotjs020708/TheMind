import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_config.freezed.dart';
part 'game_config.g.dart';

@freezed
class GameConfig with _$GameConfig {
  const factory GameConfig({
    required int playerCount, // 2, 3, 4
    required int maxLevel, // 12, 10, 8
    required int initialLives, // 2, 3, 4
    required int initialShurikens, // 1, 1, 1
  }) = _GameConfig;

  factory GameConfig.fromJson(Map<String, dynamic> json) =>
      _$GameConfigFromJson(json);

  factory GameConfig.forPlayerCount(int count) {
    switch (count) {
      case 2:
        return const GameConfig(
          playerCount: 2,
          maxLevel: 12,
          initialLives: 2,
          initialShurikens: 1,
        );
      case 3:
        return const GameConfig(
          playerCount: 3,
          maxLevel: 10,
          initialLives: 3,
          initialShurikens: 1,
        );
      case 4:
        return const GameConfig(
          playerCount: 4,
          maxLevel: 8,
          initialLives: 4,
          initialShurikens: 1,
        );
      default:
        throw ArgumentError(
          'Invalid player count: $count. Must be 2, 3, or 4.',
        );
    }
  }
}
