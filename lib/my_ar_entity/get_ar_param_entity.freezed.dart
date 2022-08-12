// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'get_ar_param_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

GetARParamEntity _$GetARParamEntityFromJson(Map<String, dynamic> json) {
  return _GetARParamEntity.fromJson(json);
}

/// @nodoc
class _$GetARParamEntityTearOff {
  const _$GetARParamEntityTearOff();

  _GetARParamEntity call({int? page, int? size}) {
    return _GetARParamEntity(
      page: page,
      size: size,
    );
  }

  GetARParamEntity fromJson(Map<String, Object> json) {
    return GetARParamEntity.fromJson(json);
  }
}

/// @nodoc
const $GetARParamEntity = _$GetARParamEntityTearOff();

/// @nodoc
mixin _$GetARParamEntity {
  int? get page => throw _privateConstructorUsedError;
  int? get size => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetARParamEntityCopyWith<GetARParamEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetARParamEntityCopyWith<$Res> {
  factory $GetARParamEntityCopyWith(
          GetARParamEntity value, $Res Function(GetARParamEntity) then) =
      _$GetARParamEntityCopyWithImpl<$Res>;
  $Res call({int? page, int? size});
}

/// @nodoc
class _$GetARParamEntityCopyWithImpl<$Res>
    implements $GetARParamEntityCopyWith<$Res> {
  _$GetARParamEntityCopyWithImpl(this._value, this._then);

  final GetARParamEntity _value;
  // ignore: unused_field
  final $Res Function(GetARParamEntity) _then;

  @override
  $Res call({
    Object? page = freezed,
    Object? size = freezed,
  }) {
    return _then(_value.copyWith(
      page: page == freezed
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      size: size == freezed
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
abstract class _$GetARParamEntityCopyWith<$Res>
    implements $GetARParamEntityCopyWith<$Res> {
  factory _$GetARParamEntityCopyWith(
          _GetARParamEntity value, $Res Function(_GetARParamEntity) then) =
      __$GetARParamEntityCopyWithImpl<$Res>;
  @override
  $Res call({int? page, int? size});
}

/// @nodoc
class __$GetARParamEntityCopyWithImpl<$Res>
    extends _$GetARParamEntityCopyWithImpl<$Res>
    implements _$GetARParamEntityCopyWith<$Res> {
  __$GetARParamEntityCopyWithImpl(
      _GetARParamEntity _value, $Res Function(_GetARParamEntity) _then)
      : super(_value, (v) => _then(v as _GetARParamEntity));

  @override
  _GetARParamEntity get _value => super._value as _GetARParamEntity;

  @override
  $Res call({
    Object? page = freezed,
    Object? size = freezed,
  }) {
    return _then(_GetARParamEntity(
      page: page == freezed
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      size: size == freezed
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetARParamEntity implements _GetARParamEntity {
  const _$_GetARParamEntity({this.page, this.size});

  factory _$_GetARParamEntity.fromJson(Map<String, dynamic> json) =>
      _$_$_GetARParamEntityFromJson(json);

  @override
  final int? page;
  @override
  final int? size;

  @override
  String toString() {
    return 'GetARParamEntity(page: $page, size: $size)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _GetARParamEntity &&
            (identical(other.page, page) ||
                const DeepCollectionEquality().equals(other.page, page)) &&
            (identical(other.size, size) ||
                const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(page) ^
      const DeepCollectionEquality().hash(size);

  @JsonKey(ignore: true)
  @override
  _$GetARParamEntityCopyWith<_GetARParamEntity> get copyWith =>
      __$GetARParamEntityCopyWithImpl<_GetARParamEntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_GetARParamEntityToJson(this);
  }
}

abstract class _GetARParamEntity implements GetARParamEntity {
  const factory _GetARParamEntity({int? page, int? size}) = _$_GetARParamEntity;

  factory _GetARParamEntity.fromJson(Map<String, dynamic> json) =
      _$_GetARParamEntity.fromJson;

  @override
  int? get page => throw _privateConstructorUsedError;
  @override
  int? get size => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$GetARParamEntityCopyWith<_GetARParamEntity> get copyWith =>
      throw _privateConstructorUsedError;
}
