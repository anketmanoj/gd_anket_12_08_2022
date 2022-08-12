// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'layer_item_cus_dto_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LayerItemCusDTOEntity _$LayerItemCusDTOEntityFromJson(
    Map<String, dynamic> json) {
  return _LayerItemCusDTOEntity.fromJson(json);
}

/// @nodoc
class _$LayerItemCusDTOEntityTearOff {
  const _$LayerItemCusDTOEntityTearOff();

  _LayerItemCusDTOEntity call(
      {int? id, String itemUrl = '', String itemThumbnailUrl = ''}) {
    return _LayerItemCusDTOEntity(
      id: id,
      itemUrl: itemUrl,
      itemThumbnailUrl: itemThumbnailUrl,
    );
  }

  LayerItemCusDTOEntity fromJson(Map<String, Object> json) {
    return LayerItemCusDTOEntity.fromJson(json);
  }
}

/// @nodoc
const $LayerItemCusDTOEntity = _$LayerItemCusDTOEntityTearOff();

/// @nodoc
mixin _$LayerItemCusDTOEntity {
  int? get id => throw _privateConstructorUsedError;
  String get itemUrl => throw _privateConstructorUsedError;
  String get itemThumbnailUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LayerItemCusDTOEntityCopyWith<LayerItemCusDTOEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LayerItemCusDTOEntityCopyWith<$Res> {
  factory $LayerItemCusDTOEntityCopyWith(LayerItemCusDTOEntity value,
          $Res Function(LayerItemCusDTOEntity) then) =
      _$LayerItemCusDTOEntityCopyWithImpl<$Res>;
  $Res call({int? id, String itemUrl, String itemThumbnailUrl});
}

/// @nodoc
class _$LayerItemCusDTOEntityCopyWithImpl<$Res>
    implements $LayerItemCusDTOEntityCopyWith<$Res> {
  _$LayerItemCusDTOEntityCopyWithImpl(this._value, this._then);

  final LayerItemCusDTOEntity _value;
  // ignore: unused_field
  final $Res Function(LayerItemCusDTOEntity) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? itemUrl = freezed,
    Object? itemThumbnailUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      itemUrl: itemUrl == freezed
          ? _value.itemUrl
          : itemUrl // ignore: cast_nullable_to_non_nullable
              as String,
      itemThumbnailUrl: itemThumbnailUrl == freezed
          ? _value.itemThumbnailUrl
          : itemThumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$LayerItemCusDTOEntityCopyWith<$Res>
    implements $LayerItemCusDTOEntityCopyWith<$Res> {
  factory _$LayerItemCusDTOEntityCopyWith(_LayerItemCusDTOEntity value,
          $Res Function(_LayerItemCusDTOEntity) then) =
      __$LayerItemCusDTOEntityCopyWithImpl<$Res>;
  @override
  $Res call({int? id, String itemUrl, String itemThumbnailUrl});
}

/// @nodoc
class __$LayerItemCusDTOEntityCopyWithImpl<$Res>
    extends _$LayerItemCusDTOEntityCopyWithImpl<$Res>
    implements _$LayerItemCusDTOEntityCopyWith<$Res> {
  __$LayerItemCusDTOEntityCopyWithImpl(_LayerItemCusDTOEntity _value,
      $Res Function(_LayerItemCusDTOEntity) _then)
      : super(_value, (v) => _then(v as _LayerItemCusDTOEntity));

  @override
  _LayerItemCusDTOEntity get _value => super._value as _LayerItemCusDTOEntity;

  @override
  $Res call({
    Object? id = freezed,
    Object? itemUrl = freezed,
    Object? itemThumbnailUrl = freezed,
  }) {
    return _then(_LayerItemCusDTOEntity(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      itemUrl: itemUrl == freezed
          ? _value.itemUrl
          : itemUrl // ignore: cast_nullable_to_non_nullable
              as String,
      itemThumbnailUrl: itemThumbnailUrl == freezed
          ? _value.itemThumbnailUrl
          : itemThumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LayerItemCusDTOEntity implements _LayerItemCusDTOEntity {
  const _$_LayerItemCusDTOEntity(
      {this.id, this.itemUrl = '', this.itemThumbnailUrl = ''});

  factory _$_LayerItemCusDTOEntity.fromJson(Map<String, dynamic> json) =>
      _$_$_LayerItemCusDTOEntityFromJson(json);

  @override
  final int? id;
  @JsonKey(defaultValue: '')
  @override
  final String itemUrl;
  @JsonKey(defaultValue: '')
  @override
  final String itemThumbnailUrl;

  @override
  String toString() {
    return 'LayerItemCusDTOEntity(id: $id, itemUrl: $itemUrl, itemThumbnailUrl: $itemThumbnailUrl)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _LayerItemCusDTOEntity &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.itemUrl, itemUrl) ||
                const DeepCollectionEquality()
                    .equals(other.itemUrl, itemUrl)) &&
            (identical(other.itemThumbnailUrl, itemThumbnailUrl) ||
                const DeepCollectionEquality()
                    .equals(other.itemThumbnailUrl, itemThumbnailUrl)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(itemUrl) ^
      const DeepCollectionEquality().hash(itemThumbnailUrl);

  @JsonKey(ignore: true)
  @override
  _$LayerItemCusDTOEntityCopyWith<_LayerItemCusDTOEntity> get copyWith =>
      __$LayerItemCusDTOEntityCopyWithImpl<_LayerItemCusDTOEntity>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_LayerItemCusDTOEntityToJson(this);
  }
}

abstract class _LayerItemCusDTOEntity implements LayerItemCusDTOEntity {
  const factory _LayerItemCusDTOEntity(
      {int? id,
      String itemUrl,
      String itemThumbnailUrl}) = _$_LayerItemCusDTOEntity;

  factory _LayerItemCusDTOEntity.fromJson(Map<String, dynamic> json) =
      _$_LayerItemCusDTOEntity.fromJson;

  @override
  int? get id => throw _privateConstructorUsedError;
  @override
  String get itemUrl => throw _privateConstructorUsedError;
  @override
  String get itemThumbnailUrl => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$LayerItemCusDTOEntityCopyWith<_LayerItemCusDTOEntity> get copyWith =>
      throw _privateConstructorUsedError;
}
