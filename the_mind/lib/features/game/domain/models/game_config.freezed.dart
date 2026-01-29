// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameConfig _$GameConfigFromJson(Map<String, dynamic> json) {
  return _GameConfig.fromJson(json);
}

/// @nodoc
mixin _$GameConfig {
  int get playerCount => throw _privateConstructorUsedError; // 2, 3, 4
  int get maxLevel => throw _privateConstructorUsedError; // 12, 10, 8
  int get initialLives => throw _privateConstructorUsedError; // 2, 3, 4
  int get initialShurikens => throw _privateConstructorUsedError;

  /// Serializes this GameConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameConfigCopyWith<GameConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameConfigCopyWith<$Res> {
  factory $GameConfigCopyWith(
    GameConfig value,
    $Res Function(GameConfig) then,
  ) = _$GameConfigCopyWithImpl<$Res, GameConfig>;
  @useResult
  $Res call({
    int playerCount,
    int maxLevel,
    int initialLives,
    int initialShurikens,
  });
}

/// @nodoc
class _$GameConfigCopyWithImpl<$Res, $Val extends GameConfig>
    implements $GameConfigCopyWith<$Res> {
  _$GameConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerCount = null,
    Object? maxLevel = null,
    Object? initialLives = null,
    Object? initialShurikens = null,
  }) {
    return _then(
      _value.copyWith(
            playerCount:
                null == playerCount
                    ? _value.playerCount
                    : playerCount // ignore: cast_nullable_to_non_nullable
                        as int,
            maxLevel:
                null == maxLevel
                    ? _value.maxLevel
                    : maxLevel // ignore: cast_nullable_to_non_nullable
                        as int,
            initialLives:
                null == initialLives
                    ? _value.initialLives
                    : initialLives // ignore: cast_nullable_to_non_nullable
                        as int,
            initialShurikens:
                null == initialShurikens
                    ? _value.initialShurikens
                    : initialShurikens // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameConfigImplCopyWith<$Res>
    implements $GameConfigCopyWith<$Res> {
  factory _$$GameConfigImplCopyWith(
    _$GameConfigImpl value,
    $Res Function(_$GameConfigImpl) then,
  ) = __$$GameConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int playerCount,
    int maxLevel,
    int initialLives,
    int initialShurikens,
  });
}

/// @nodoc
class __$$GameConfigImplCopyWithImpl<$Res>
    extends _$GameConfigCopyWithImpl<$Res, _$GameConfigImpl>
    implements _$$GameConfigImplCopyWith<$Res> {
  __$$GameConfigImplCopyWithImpl(
    _$GameConfigImpl _value,
    $Res Function(_$GameConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerCount = null,
    Object? maxLevel = null,
    Object? initialLives = null,
    Object? initialShurikens = null,
  }) {
    return _then(
      _$GameConfigImpl(
        playerCount:
            null == playerCount
                ? _value.playerCount
                : playerCount // ignore: cast_nullable_to_non_nullable
                    as int,
        maxLevel:
            null == maxLevel
                ? _value.maxLevel
                : maxLevel // ignore: cast_nullable_to_non_nullable
                    as int,
        initialLives:
            null == initialLives
                ? _value.initialLives
                : initialLives // ignore: cast_nullable_to_non_nullable
                    as int,
        initialShurikens:
            null == initialShurikens
                ? _value.initialShurikens
                : initialShurikens // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameConfigImpl implements _GameConfig {
  const _$GameConfigImpl({
    required this.playerCount,
    required this.maxLevel,
    required this.initialLives,
    required this.initialShurikens,
  });

  factory _$GameConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameConfigImplFromJson(json);

  @override
  final int playerCount;
  // 2, 3, 4
  @override
  final int maxLevel;
  // 12, 10, 8
  @override
  final int initialLives;
  // 2, 3, 4
  @override
  final int initialShurikens;

  @override
  String toString() {
    return 'GameConfig(playerCount: $playerCount, maxLevel: $maxLevel, initialLives: $initialLives, initialShurikens: $initialShurikens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameConfigImpl &&
            (identical(other.playerCount, playerCount) ||
                other.playerCount == playerCount) &&
            (identical(other.maxLevel, maxLevel) ||
                other.maxLevel == maxLevel) &&
            (identical(other.initialLives, initialLives) ||
                other.initialLives == initialLives) &&
            (identical(other.initialShurikens, initialShurikens) ||
                other.initialShurikens == initialShurikens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    playerCount,
    maxLevel,
    initialLives,
    initialShurikens,
  );

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameConfigImplCopyWith<_$GameConfigImpl> get copyWith =>
      __$$GameConfigImplCopyWithImpl<_$GameConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameConfigImplToJson(this);
  }
}

abstract class _GameConfig implements GameConfig {
  const factory _GameConfig({
    required final int playerCount,
    required final int maxLevel,
    required final int initialLives,
    required final int initialShurikens,
  }) = _$GameConfigImpl;

  factory _GameConfig.fromJson(Map<String, dynamic> json) =
      _$GameConfigImpl.fromJson;

  @override
  int get playerCount; // 2, 3, 4
  @override
  int get maxLevel; // 12, 10, 8
  @override
  int get initialLives; // 2, 3, 4
  @override
  int get initialShurikens;

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameConfigImplCopyWith<_$GameConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
