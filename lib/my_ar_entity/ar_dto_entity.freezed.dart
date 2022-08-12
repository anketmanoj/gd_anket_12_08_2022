// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'ar_dto_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ARDTOEntity _$ARDTOEntityFromJson(Map<String, dynamic> json) {
  return _ARDTOEntity.fromJson(json);
}

/// @nodoc
class _$ARDTOEntityTearOff {
  const _$ARDTOEntityTearOff();

  _ARDTOEntity call(
      {required int id,
      required int userId,
      required int arCollectionId,
      required int createBy,
      required String createdAt,
      int? updateBy,
      String? updatedAt}) {
    return _ARDTOEntity(
      id: id,
      userId: userId,
      arCollectionId: arCollectionId,
      createBy: createBy,
      createdAt: createdAt,
      updateBy: updateBy,
      updatedAt: updatedAt,
    );
  }

  ARDTOEntity fromJson(Map<String, Object> json) {
    return ARDTOEntity.fromJson(json);
  }
}

/// @nodoc
const $ARDTOEntity = _$ARDTOEntityTearOff();

/// @nodoc
mixin _$ARDTOEntity {
  int get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  int get arCollectionId => throw _privateConstructorUsedError;
  int get createBy => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  int? get updateBy => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ARDTOEntityCopyWith<ARDTOEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ARDTOEntityCopyWith<$Res> {
  factory $ARDTOEntityCopyWith(
          ARDTOEntity value, $Res Function(ARDTOEntity) then) =
      _$ARDTOEntityCopyWithImpl<$Res>;
  $Res call(
      {int id,
      int userId,
      int arCollectionId,
      int createBy,
      String createdAt,
      int? updateBy,
      String? updatedAt});
}

/// @nodoc
class _$ARDTOEntityCopyWithImpl<$Res> implements $ARDTOEntityCopyWith<$Res> {
  _$ARDTOEntityCopyWithImpl(this._value, this._then);

  final ARDTOEntity _value;
  // ignore: unused_field
  final $Res Function(ARDTOEntity) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? arCollectionId = freezed,
    Object? createBy = freezed,
    Object? createdAt = freezed,
    Object? updateBy = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: userId == freezed
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      arCollectionId: arCollectionId == freezed
          ? _value.arCollectionId
          : arCollectionId // ignore: cast_nullable_to_non_nullable
              as int,
      createBy: createBy == freezed
          ? _value.createBy
          : createBy // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updateBy: updateBy == freezed
          ? _value.updateBy
          : updateBy // ignore: cast_nullable_to_non_nullable
              as int?,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$ARDTOEntityCopyWith<$Res>
    implements $ARDTOEntityCopyWith<$Res> {
  factory _$ARDTOEntityCopyWith(
          _ARDTOEntity value, $Res Function(_ARDTOEntity) then) =
      __$ARDTOEntityCopyWithImpl<$Res>;
  @override
  $Res call(
      {int id,
      int userId,
      int arCollectionId,
      int createBy,
      String createdAt,
      int? updateBy,
      String? updatedAt});
}

/// @nodoc
class __$ARDTOEntityCopyWithImpl<$Res> extends _$ARDTOEntityCopyWithImpl<$Res>
    implements _$ARDTOEntityCopyWith<$Res> {
  __$ARDTOEntityCopyWithImpl(
      _ARDTOEntity _value, $Res Function(_ARDTOEntity) _then)
      : super(_value, (v) => _then(v as _ARDTOEntity));

  @override
  _ARDTOEntity get _value => super._value as _ARDTOEntity;

  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? arCollectionId = freezed,
    Object? createBy = freezed,
    Object? createdAt = freezed,
    Object? updateBy = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_ARDTOEntity(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: userId == freezed
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      arCollectionId: arCollectionId == freezed
          ? _value.arCollectionId
          : arCollectionId // ignore: cast_nullable_to_non_nullable
              as int,
      createBy: createBy == freezed
          ? _value.createBy
          : createBy // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updateBy: updateBy == freezed
          ? _value.updateBy
          : updateBy // ignore: cast_nullable_to_non_nullable
              as int?,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ARDTOEntity implements _ARDTOEntity {
  const _$_ARDTOEntity(
      {required this.id,
      required this.userId,
      required this.arCollectionId,
      required this.createBy,
      required this.createdAt,
      this.updateBy,
      this.updatedAt});

  factory _$_ARDTOEntity.fromJson(Map<String, dynamic> json) =>
      _$_$_ARDTOEntityFromJson(json);

  @override
  final int id;
  @override
  final int userId;
  @override
  final int arCollectionId;
  @override
  final int createBy;
  @override
  final String createdAt;
  @override
  final int? updateBy;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'ARDTOEntity(id: $id, userId: $userId, arCollectionId: $arCollectionId, createBy: $createBy, createdAt: $createdAt, updateBy: $updateBy, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ARDTOEntity &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.arCollectionId, arCollectionId) ||
                const DeepCollectionEquality()
                    .equals(other.arCollectionId, arCollectionId)) &&
            (identical(other.createBy, createBy) ||
                const DeepCollectionEquality()
                    .equals(other.createBy, createBy)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality()
                    .equals(other.createdAt, createdAt)) &&
            (identical(other.updateBy, updateBy) ||
                const DeepCollectionEquality()
                    .equals(other.updateBy, updateBy)) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality()
                    .equals(other.updatedAt, updatedAt)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(arCollectionId) ^
      const DeepCollectionEquality().hash(createBy) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updateBy) ^
      const DeepCollectionEquality().hash(updatedAt);

  @JsonKey(ignore: true)
  @override
  _$ARDTOEntityCopyWith<_ARDTOEntity> get copyWith =>
      __$ARDTOEntityCopyWithImpl<_ARDTOEntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_ARDTOEntityToJson(this);
  }
}

abstract class _ARDTOEntity implements ARDTOEntity {
  const factory _ARDTOEntity(
      {required int id,
      required int userId,
      required int arCollectionId,
      required int createBy,
      required String createdAt,
      int? updateBy,
      String? updatedAt}) = _$_ARDTOEntity;

  factory _ARDTOEntity.fromJson(Map<String, dynamic> json) =
      _$_ARDTOEntity.fromJson;

  @override
  int get id => throw _privateConstructorUsedError;
  @override
  int get userId => throw _privateConstructorUsedError;
  @override
  int get arCollectionId => throw _privateConstructorUsedError;
  @override
  int get createBy => throw _privateConstructorUsedError;
  @override
  String get createdAt => throw _privateConstructorUsedError;
  @override
  int? get updateBy => throw _privateConstructorUsedError;
  @override
  String? get updatedAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$ARDTOEntityCopyWith<_ARDTOEntity> get copyWith =>
      throw _privateConstructorUsedError;
}
