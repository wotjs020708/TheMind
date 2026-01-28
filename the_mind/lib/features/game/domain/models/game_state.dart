import 'package:freezed_annotation/freezed_annotation.dart';
import 'player.dart';
import 'game_config.dart';
import '../enums/game_phase.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

@freezed
class GameState with _$GameState {
  const factory GameState({
    required String roomId,
    required GameConfig config,
    required List<Player> players,
    required int currentLevel,
    required int lives,
    required int shurikens,
    required List<int> playedCards,
    required GamePhase phase,
    String? winnerId,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
}
