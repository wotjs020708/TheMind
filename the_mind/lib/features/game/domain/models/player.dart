import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../shared/models/game_card.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    required int position,
    required List<GameCard> cards,
    @Default(false) bool isReady,
    @Default(true) bool isConnected,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
