// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'my_ar_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AREntity _$AREntityFromJson(Map<String, dynamic> json) {
  return _AREntity.fromJson(json);
}

/// @nodoc
class _$AREntityTearOff {
  const _$AREntityTearOff();

  _AREntity call(
      {required ARDTOEntity myARDTO,
      required CollectionDTOEntity arCollectionDTO,
      bool selected = false}) {
    return _AREntity(
      myARDTO: myARDTO,
      arCollectionDTO: arCollectionDTO,
      selected: selected,
    );
  }

  AREntity fromJson(Map<String, Object> json) {
    return AREntity.fromJson(json);
  }
}

/// @nodoc
const $AREntity = _$AREntityTearOff();

/// @nodoc
mixin _$AREntity {
  ARDTOEntity get myARDTO => throw _privateConstructorUsedError;
  CollectionDTOEntity get arCollectionDTO => throw _privateConstructorUsedError;
  bool get selected => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AREntityCopyWith<AREntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AREntityCopyWith<$Res> {
  factory $AREntityCopyWith(AREntity value, $Res Function(AREntity) then) =
      _$AREntityCopyWithImpl<$Res>;
  $Res call(
      {ARDTOEntity myARDTO,
      CollectionDTOEntity arCollectionDTO,
      bool selected});

  $ARDTOEntityCopyWith<$Res> get myARDTO;
  $CollectionDTOEntityCopyWith<$Res> get arCollectionDTO;
}

/// @nodoc
class _$AREntityCopyWithImpl<$Res> implements $AREntityCopyWith<$Res> {
  _$AREntityCopyWithImpl(this._value, this._then);

  final AREntity _value;
  // ignore: unused_field
  final $Res Function(AREntity) _then;

  @override
  $Res call({
    Object? myARDTO = freezed,
    Object? arCollectionDTO = freezed,
    Object? selected = freezed,
  }) {
    return _then(_value.copyWith(
      myARDTO: myARDTO == freezed
          ? _value.myARDTO
          : myARDTO // ignore: cast_nullable_to_non_nullable
              as ARDTOEntity,
      arCollectionDTO: arCollectionDTO == freezed
          ? _value.arCollectionDTO
          : arCollectionDTO // ignore: cast_nullable_to_non_nullable
              as CollectionDTOEntity,
      selected: selected == freezed
          ? _value.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  @override
  $ARDTOEntityCopyWith<$Res> get myARDTO {
    return $ARDTOEntityCopyWith<$Res>(_value.myARDTO, (value) {
      return _then(_value.copyWith(myARDTO: value));
    });
  }

  @override
  $CollectionDTOEntityCopyWith<$Res> get arCollectionDTO {
    return $CollectionDTOEntityCopyWith<$Res>(_value.arCollectionDTO, (value) {
      return _then(_value.copyWith(arCollectionDTO: value));
    });
  }
}

/// @nodoc
abstract class _$AREntityCopyWith<$Res> implements $AREntityCopyWith<$Res> {
  factory _$AREntityCopyWith(_AREntity value, $Res Function(_AREntity) then) =
      __$AREntityCopyWithImpl<$Res>;
  @override
  $Res call(
      {ARDTOEntity myARDTO,
      CollectionDTOEntity arCollectionDTO,
      bool selected});

  @override
  $ARDTOEntityCopyWith<$Res> get myARDTO;
  @override
  $CollectionDTOEntityCopyWith<$Res> get arCollectionDTO;
}

/// @nodoc
class __$AREntityCopyWithImpl<$Res> extends _$AREntityCopyWithImpl<$Res>
    implements _$AREntityCopyWith<$Res> {
  __$AREntityCopyWithImpl(_AREntity _value, $Res Function(_AREntity) _then)
      : super(_value, (v) => _then(v as _AREntity));

  @override
  _AREntity get _value => super._value as _AREntity;

  @override
  $Res call({
    Object? myARDTO = freezed,
    Object? arCollectionDTO = freezed,
    Object? selected = freezed,
  }) {
    return _then(_AREntity(
      myARDTO: myARDTO == freezed
          ? _value.myARDTO
          : myARDTO // ignore: cast_nullable_to_non_nullable
              as ARDTOEntity,
      arCollectionDTO: arCollectionDTO == freezed
          ? _value.arCollectionDTO
          : arCollectionDTO // ignore: cast_nullable_to_non_nullable
              as CollectionDTOEntity,
      selected: selected == freezed
          ? _value.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_AREntity implements _AREntity {
  const _$_AREntity(
      {required this.myARDTO,
      required this.arCollectionDTO,
      this.selected = false});

  factory _$_AREntity.fromJson(Map<String, dynamic> json) =>
      _$_$_AREntityFromJson(json);

  @override
  final ARDTOEntity myARDTO;
  @override
  final CollectionDTOEntity arCollectionDTO;
  @JsonKey(defaultValue: false)
  @override
  final bool selected;

  @override
  String toString() {
    return 'AREntity(myARDTO: $myARDTO, arCollectionDTO: $arCollectionDTO, selected: $selected)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _AREntity &&
            (identical(other.myARDTO, myARDTO) ||
                const DeepCollectionEquality()
                    .equals(other.myARDTO, myARDTO)) &&
            (identical(other.arCollectionDTO, arCollectionDTO) ||
                const DeepCollectionEquality()
                    .equals(other.arCollectionDTO, arCollectionDTO)) &&
            (identical(other.selected, selected) ||
                const DeepCollectionEquality()
                    .equals(other.selected, selected)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(myARDTO) ^
      const DeepCollectionEquality().hash(arCollectionDTO) ^
      const DeepCollectionEquality().hash(selected);

  @JsonKey(ignore: true)
  @override
  _$AREntityCopyWith<_AREntity> get copyWith =>
      __$AREntityCopyWithImpl<_AREntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_AREntityToJson(this);
  }
}

abstract class _AREntity implements AREntity {
  const factory _AREntity(
      {required ARDTOEntity myARDTO,
      required CollectionDTOEntity arCollectionDTO,
      bool selected}) = _$_AREntity;

  factory _AREntity.fromJson(Map<String, dynamic> json) = _$_AREntity.fromJson;

  @override
  ARDTOEntity get myARDTO => throw _privateConstructorUsedError;
  @override
  CollectionDTOEntity get arCollectionDTO => throw _privateConstructorUsedError;
  @override
  bool get selected => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$AREntityCopyWith<_AREntity> get copyWith =>
      throw _privateConstructorUsedError;
}
