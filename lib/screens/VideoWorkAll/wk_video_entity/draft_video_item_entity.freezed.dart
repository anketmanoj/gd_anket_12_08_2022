// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'draft_video_item_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DraftVideoItemEntity _$DraftVideoItemEntityFromJson(Map<String, dynamic> json) {
  return _DraftVideoItemEntity.fromJson(json);
}

/// @nodoc
class _$DraftVideoItemEntityTearOff {
  const _$DraftVideoItemEntityTearOff();

  _DraftVideoItemEntity call(
      {required LayerItemEntity layerItem,
      required LayerItemCusDTOEntity layerItemCusDTO}) {
    return _DraftVideoItemEntity(
      layerItem: layerItem,
      layerItemCusDTO: layerItemCusDTO,
    );
  }

  DraftVideoItemEntity fromJson(Map<String, Object> json) {
    return DraftVideoItemEntity.fromJson(json);
  }
}

/// @nodoc
const $DraftVideoItemEntity = _$DraftVideoItemEntityTearOff();

/// @nodoc
mixin _$DraftVideoItemEntity {
  LayerItemEntity get layerItem => throw _privateConstructorUsedError;
  LayerItemCusDTOEntity get layerItemCusDTO =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DraftVideoItemEntityCopyWith<DraftVideoItemEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DraftVideoItemEntityCopyWith<$Res> {
  factory $DraftVideoItemEntityCopyWith(DraftVideoItemEntity value,
          $Res Function(DraftVideoItemEntity) then) =
      _$DraftVideoItemEntityCopyWithImpl<$Res>;
  $Res call({LayerItemEntity layerItem, LayerItemCusDTOEntity layerItemCusDTO});

  $LayerItemEntityCopyWith<$Res> get layerItem;
  $LayerItemCusDTOEntityCopyWith<$Res> get layerItemCusDTO;
}

/// @nodoc
class _$DraftVideoItemEntityCopyWithImpl<$Res>
    implements $DraftVideoItemEntityCopyWith<$Res> {
  _$DraftVideoItemEntityCopyWithImpl(this._value, this._then);

  final DraftVideoItemEntity _value;
  // ignore: unused_field
  final $Res Function(DraftVideoItemEntity) _then;

  @override
  $Res call({
    Object? layerItem = freezed,
    Object? layerItemCusDTO = freezed,
  }) {
    return _then(_value.copyWith(
      layerItem: layerItem == freezed
          ? _value.layerItem
          : layerItem // ignore: cast_nullable_to_non_nullable
              as LayerItemEntity,
      layerItemCusDTO: layerItemCusDTO == freezed
          ? _value.layerItemCusDTO
          : layerItemCusDTO // ignore: cast_nullable_to_non_nullable
              as LayerItemCusDTOEntity,
    ));
  }

  @override
  $LayerItemEntityCopyWith<$Res> get layerItem {
    return $LayerItemEntityCopyWith<$Res>(_value.layerItem, (value) {
      return _then(_value.copyWith(layerItem: value));
    });
  }

  @override
  $LayerItemCusDTOEntityCopyWith<$Res> get layerItemCusDTO {
    return $LayerItemCusDTOEntityCopyWith<$Res>(_value.layerItemCusDTO,
        (value) {
      return _then(_value.copyWith(layerItemCusDTO: value));
    });
  }
}

/// @nodoc
abstract class _$DraftVideoItemEntityCopyWith<$Res>
    implements $DraftVideoItemEntityCopyWith<$Res> {
  factory _$DraftVideoItemEntityCopyWith(_DraftVideoItemEntity value,
          $Res Function(_DraftVideoItemEntity) then) =
      __$DraftVideoItemEntityCopyWithImpl<$Res>;
  @override
  $Res call({LayerItemEntity layerItem, LayerItemCusDTOEntity layerItemCusDTO});

  @override
  $LayerItemEntityCopyWith<$Res> get layerItem;
  @override
  $LayerItemCusDTOEntityCopyWith<$Res> get layerItemCusDTO;
}

/// @nodoc
class __$DraftVideoItemEntityCopyWithImpl<$Res>
    extends _$DraftVideoItemEntityCopyWithImpl<$Res>
    implements _$DraftVideoItemEntityCopyWith<$Res> {
  __$DraftVideoItemEntityCopyWithImpl(
      _DraftVideoItemEntity _value, $Res Function(_DraftVideoItemEntity) _then)
      : super(_value, (v) => _then(v as _DraftVideoItemEntity));

  @override
  _DraftVideoItemEntity get _value => super._value as _DraftVideoItemEntity;

  @override
  $Res call({
    Object? layerItem = freezed,
    Object? layerItemCusDTO = freezed,
  }) {
    return _then(_DraftVideoItemEntity(
      layerItem: layerItem == freezed
          ? _value.layerItem
          : layerItem // ignore: cast_nullable_to_non_nullable
              as LayerItemEntity,
      layerItemCusDTO: layerItemCusDTO == freezed
          ? _value.layerItemCusDTO
          : layerItemCusDTO // ignore: cast_nullable_to_non_nullable
              as LayerItemCusDTOEntity,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DraftVideoItemEntity implements _DraftVideoItemEntity {
  const _$_DraftVideoItemEntity(
      {required this.layerItem, required this.layerItemCusDTO});

  factory _$_DraftVideoItemEntity.fromJson(Map<String, dynamic> json) =>
      _$_$_DraftVideoItemEntityFromJson(json);

  @override
  final LayerItemEntity layerItem;
  @override
  final LayerItemCusDTOEntity layerItemCusDTO;

  @override
  String toString() {
    return 'DraftVideoItemEntity(layerItem: $layerItem, layerItemCusDTO: $layerItemCusDTO)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _DraftVideoItemEntity &&
            (identical(other.layerItem, layerItem) ||
                const DeepCollectionEquality()
                    .equals(other.layerItem, layerItem)) &&
            (identical(other.layerItemCusDTO, layerItemCusDTO) ||
                const DeepCollectionEquality()
                    .equals(other.layerItemCusDTO, layerItemCusDTO)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(layerItem) ^
      const DeepCollectionEquality().hash(layerItemCusDTO);

  @JsonKey(ignore: true)
  @override
  _$DraftVideoItemEntityCopyWith<_DraftVideoItemEntity> get copyWith =>
      __$DraftVideoItemEntityCopyWithImpl<_DraftVideoItemEntity>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_DraftVideoItemEntityToJson(this);
  }
}

abstract class _DraftVideoItemEntity implements DraftVideoItemEntity {
  const factory _DraftVideoItemEntity(
          {required LayerItemEntity layerItem,
          required LayerItemCusDTOEntity layerItemCusDTO}) =
      _$_DraftVideoItemEntity;

  factory _DraftVideoItemEntity.fromJson(Map<String, dynamic> json) =
      _$_DraftVideoItemEntity.fromJson;

  @override
  LayerItemEntity get layerItem => throw _privateConstructorUsedError;
  @override
  LayerItemCusDTOEntity get layerItemCusDTO =>
      throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$DraftVideoItemEntityCopyWith<_DraftVideoItemEntity> get copyWith =>
      throw _privateConstructorUsedError;
}
