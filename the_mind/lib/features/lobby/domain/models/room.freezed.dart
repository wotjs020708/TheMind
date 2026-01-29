// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Room _$RoomFromJson(Map<String, dynamic> json) {
  return _Room.fromJson(json);
}

/// @nodoc
mixin _$Room {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'player_count')
  int get playerCount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_level')
  int get currentLevel => throw _privateConstructorUsedError;
  int get lives => throw _privateConstructorUsedError;
  int get shurikens => throw _privateConstructorUsedError;
  @JsonKey(name: 'played_cards')
  List<int> get playedCards => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomCopyWith<Room> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) then) =
      _$RoomCopyWithImpl<$Res, Room>;
  @useResult
  $Res call({
    String id,
    String code,
    @JsonKey(name: 'player_count') int playerCount,
    String status,
    @JsonKey(name: 'current_level') int currentLevel,
    int lives,
    int shurikens,
    @JsonKey(name: 'played_cards') List<int> playedCards,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$RoomCopyWithImpl<$Res, $Val extends Room>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? playerCount = null,
    Object? status = null,
    Object? currentLevel = null,
    Object? lives = null,
    Object? shurikens = null,
    Object? playedCards = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            code:
                null == code
                    ? _value.code
                    : code // ignore: cast_nullable_to_non_nullable
                        as String,
            playerCount:
                null == playerCount
                    ? _value.playerCount
                    : playerCount // ignore: cast_nullable_to_non_nullable
                        as int,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
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
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoomImplCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$$RoomImplCopyWith(
    _$RoomImpl value,
    $Res Function(_$RoomImpl) then,
  ) = __$$RoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    @JsonKey(name: 'player_count') int playerCount,
    String status,
    @JsonKey(name: 'current_level') int currentLevel,
    int lives,
    int shurikens,
    @JsonKey(name: 'played_cards') List<int> playedCards,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$RoomImplCopyWithImpl<$Res>
    extends _$RoomCopyWithImpl<$Res, _$RoomImpl>
    implements _$$RoomImplCopyWith<$Res> {
  __$$RoomImplCopyWithImpl(_$RoomImpl _value, $Res Function(_$RoomImpl) _then)
    : super(_value, _then);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? playerCount = null,
    Object? status = null,
    Object? currentLevel = null,
    Object? lives = null,
    Object? shurikens = null,
    Object? playedCards = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$RoomImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        code:
            null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                    as String,
        playerCount:
            null == playerCount
                ? _value.playerCount
                : playerCount // ignore: cast_nullable_to_non_nullable
                    as int,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
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
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomImpl implements _Room {
  const _$RoomImpl({
    required this.id,
    required this.code,
    @JsonKey(name: 'player_count') required this.playerCount,
    required this.status,
    @JsonKey(name: 'current_level') required this.currentLevel,
    required this.lives,
    required this.shurikens,
    @JsonKey(name: 'played_cards') required final List<int> playedCards,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _playedCards = playedCards;

  factory _$RoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  @JsonKey(name: 'player_count')
  final int playerCount;
  @override
  final String status;
  @override
  @JsonKey(name: 'current_level')
  final int currentLevel;
  @override
  final int lives;
  @override
  final int shurikens;
  final List<int> _playedCards;
  @override
  @JsonKey(name: 'played_cards')
  List<int> get playedCards {
    if (_playedCards is EqualUnmodifiableListView) return _playedCards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playedCards);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Room(id: $id, code: $code, playerCount: $playerCount, status: $status, currentLevel: $currentLevel, lives: $lives, shurikens: $shurikens, playedCards: $playedCards, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.playerCount, playerCount) ||
                other.playerCount == playerCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.lives, lives) || other.lives == lives) &&
            (identical(other.shurikens, shurikens) ||
                other.shurikens == shurikens) &&
            const DeepCollectionEquality().equals(
              other._playedCards,
              _playedCards,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    playerCount,
    status,
    currentLevel,
    lives,
    shurikens,
    const DeepCollectionEquality().hash(_playedCards),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      __$$RoomImplCopyWithImpl<_$RoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomImplToJson(this);
  }
}

abstract class _Room implements Room {
  const factory _Room({
    required final String id,
    required final String code,
    @JsonKey(name: 'player_count') required final int playerCount,
    required final String status,
    @JsonKey(name: 'current_level') required final int currentLevel,
    required final int lives,
    required final int shurikens,
    @JsonKey(name: 'played_cards') required final List<int> playedCards,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$RoomImpl;

  factory _Room.fromJson(Map<String, dynamic> json) = _$RoomImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  @JsonKey(name: 'player_count')
  int get playerCount;
  @override
  String get status;
  @override
  @JsonKey(name: 'current_level')
  int get currentLevel;
  @override
  int get lives;
  @override
  int get shurikens;
  @override
  @JsonKey(name: 'played_cards')
  List<int> get playedCards;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
