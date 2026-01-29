// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return _GameState.fromJson(json);
}

/// @nodoc
mixin _$GameState {
  String get roomId => throw _privateConstructorUsedError;
  GameConfig get config => throw _privateConstructorUsedError;
  List<Player> get players => throw _privateConstructorUsedError;
  int get currentLevel => throw _privateConstructorUsedError;
  int get lives => throw _privateConstructorUsedError;
  int get shurikens => throw _privateConstructorUsedError;
  List<int> get playedCards => throw _privateConstructorUsedError;
  GamePhase get phase => throw _privateConstructorUsedError;
  String? get winnerId => throw _privateConstructorUsedError;

  /// Serializes this GameState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call({
    String roomId,
    GameConfig config,
    List<Player> players,
    int currentLevel,
    int lives,
    int shurikens,
    List<int> playedCards,
    GamePhase phase,
    String? winnerId,
  });

  $GameConfigCopyWith<$Res> get config;
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? config = null,
    Object? players = null,
    Object? currentLevel = null,
    Object? lives = null,
    Object? shurikens = null,
    Object? playedCards = null,
    Object? phase = null,
    Object? winnerId = freezed,
  }) {
    return _then(
      _value.copyWith(
            roomId:
                null == roomId
                    ? _value.roomId
                    : roomId // ignore: cast_nullable_to_non_nullable
                        as String,
            config:
                null == config
                    ? _value.config
                    : config // ignore: cast_nullable_to_non_nullable
                        as GameConfig,
            players:
                null == players
                    ? _value.players
                    : players // ignore: cast_nullable_to_non_nullable
                        as List<Player>,
            currentLevel:
                null == currentLevel
                    ? _value.currentLevel
                    : currentLevel // ignore: cast_nullable_to_non_nullable
                        as int,
            lives:
                null == lives
                    ? _value.lives
                    : lives // ignore: cast_nullable_to_non_nullable
                        as int,
            shurikens:
                null == shurikens
                    ? _value.shurikens
                    : shurikens // ignore: cast_nullable_to_non_nullable
                        as int,
            playedCards:
                null == playedCards
                    ? _value.playedCards
                    : playedCards // ignore: cast_nullable_to_non_nullable
                        as List<int>,
            phase:
                null == phase
                    ? _value.phase
                    : phase // ignore: cast_nullable_to_non_nullable
                        as GamePhase,
            winnerId:
                freezed == winnerId
                    ? _value.winnerId
                    : winnerId // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameConfigCopyWith<$Res> get config {
    return $GameConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
    _$GameStateImpl value,
    $Res Function(_$GameStateImpl) then,
  ) = __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String roomId,
    GameConfig config,
    List<Player> players,
    int currentLevel,
    int lives,
    int shurikens,
    List<int> playedCards,
    GamePhase phase,
    String? winnerId,
  });

  @override
  $GameConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
    _$GameStateImpl _value,
    $Res Function(_$GameStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? config = null,
    Object? players = null,
    Object? currentLevel = null,
    Object? lives = null,
    Object? shurikens = null,
    Object? playedCards = null,
    Object? phase = null,
    Object? winnerId = freezed,
  }) {
    return _then(
      _$GameStateImpl(
        roomId:
            null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                    as String,
        config:
            null == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                    as GameConfig,
        players:
            null == players
                ? _value._players
                : players // ignore: cast_nullable_to_non_nullable
                    as List<Player>,
        currentLevel:
            null == currentLevel
                ? _value.currentLevel
                : currentLevel // ignore: cast_nullable_to_non_nullable
                    as int,
        lives:
            null == lives
                ? _value.lives
                : lives // ignore: cast_nullable_to_non_nullable
                    as int,
        shurikens:
            null == shurikens
                ? _value.shurikens
                : shurikens // ignore: cast_nullable_to_non_nullable
                    as int,
        playedCards:
            null == playedCards
                ? _value._playedCards
                : playedCards // ignore: cast_nullable_to_non_nullable
                    as List<int>,
        phase:
            null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                    as GamePhase,
        winnerId:
            freezed == winnerId
                ? _value.winnerId
                : winnerId // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameStateImpl implements _GameState {
  const _$GameStateImpl({
    required this.roomId,
    required this.config,
    required final List<Player> players,
    required this.currentLevel,
    required this.lives,
    required this.shurikens,
    required final List<int> playedCards,
    required this.phase,
    this.winnerId,
  }) : _players = players,
       _playedCards = playedCards;

  factory _$GameStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameStateImplFromJson(json);

  @override
  final String roomId;
  @override
  final GameConfig config;
  final List<Player> _players;
  @override
  List<Player> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  @override
  final int currentLevel;
  @override
  final int lives;
  @override
  final int shurikens;
  final List<int> _playedCards;
  @override
  List<int> get playedCards {
    if (_playedCards is EqualUnmodifiableListView) return _playedCards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playedCards);
  }

  @override
  final GamePhase phase;
  @override
  final String? winnerId;

  @override
  String toString() {
    return 'GameState(roomId: $roomId, config: $config, players: $players, currentLevel: $currentLevel, lives: $lives, shurikens: $shurikens, playedCards: $playedCards, phase: $phase, winnerId: $winnerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.config, config) || other.config == config) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.lives, lives) || other.lives == lives) &&
            (identical(other.shurikens, shurikens) ||
                other.shurikens == shurikens) &&
            const DeepCollectionEquality().equals(
              other._playedCards,
              _playedCards,
            ) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    roomId,
    config,
    const DeepCollectionEquality().hash(_players),
    currentLevel,
    lives,
    shurikens,
    const DeepCollectionEquality().hash(_playedCards),
    phase,
    winnerId,
  );

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameStateImplToJson(this);
  }
}

abstract class _GameState implements GameState {
  const factory _GameState({
    required final String roomId,
    required final GameConfig config,
    required final List<Player> players,
    required final int currentLevel,
    required final int lives,
    required final int shurikens,
    required final List<int> playedCards,
    required final GamePhase phase,
    final String? winnerId,
  }) = _$GameStateImpl;

  factory _GameState.fromJson(Map<String, dynamic> json) =
      _$GameStateImpl.fromJson;

  @override
  String get roomId;
  @override
  GameConfig get config;
  @override
  List<Player> get players;
  @override
  int get currentLevel;
  @override
  int get lives;
  @override
  int get shurikens;
  @override
  List<int> get playedCards;
  @override
  GamePhase get phase;
  @override
  String? get winnerId;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
