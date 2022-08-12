// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'my_ar_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MyAREntity _$MyAREntityFromJson(Map<String, dynamic> json) {
  return _MyAREntity.fromJson(json);
}

/// @nodoc
class _$MyAREntityTearOff {
  const _$MyAREntityTearOff();

  _MyAREntity call(
      {required ARDTOEntity myARDTO,
      required CollectionDTOEntity arCollectionDTO,
      bool selected = false}) {
    return _MyAREntity(
      myARDTO: myARDTO,
      arCollectionDTO: arCollectionDTO,
      selected: selected,
    );
  }

  MyAREntity fromJson(Map<String, Object> json) {
    return MyAREntity.fromJson(json);
  }
}

/// @nodoc
const $MyAREntity = _$MyAREntityTearOff();

/// @nodoc
mixin _$MyAREntity {
  ARDTOEntity get myARDTO => throw _privateConstructorUsedError;
  CollectionDTOEntity get arCollectionDTO => throw _privateConstructorUsedError;
  bool get selected => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MyAREntityCopyWith<MyAREntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyAREntityCopyWith<$Res> {
  factory $MyAREntityCopyWith(
          MyAREntity value, $Res Function(MyAREntity) then) =
      _$MyAREntityCopyWithImpl<$Res>;
  $Res call(
      {ARDTOEntity myARDTO,
      CollectionDTOEntity arCollectionDTO,
      bool selected});

  $ARDTOEntityCopyWith<$Res> get myARDTO;
  $CollectionDTOEntityCopyWith<$Res> get arCollectionDTO;
}

/// @nodoc
class _$MyAREntityCopyWithImpl<$Res> implements $MyAREntityCopyWith<$Res> {
  _$MyAREntityCopyWithImpl(this._value, this._then);

  final MyAREntity _value;
  // ignore: unused_field
  final $Res Function(MyAREntity) _then;

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
abstract class _$MyAREntityCopyWith<$Res> implements $MyAREntityCopyWith<$Res> {
  factory _$MyAREntityCopyWith(
          _MyAREntity value, $Res Function(_MyAREntity) then) =
      __$MyAREntityCopyWithImpl<$Res>;
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
class __$MyAREntityCopyWithImpl<$Res> extends _$MyAREntityCopyWithImpl<$Res>
    implements _$MyAREntityCopyWith<$Res> {
  __$MyAREntityCopyWithImpl(
      _MyAREntity _value, $Res Function(_MyAREntity) _then)
      : super(_value, (v) => _then(v as _MyAREntity));

  @override
  _MyAREntity get _value => super._value as _MyAREntity;

  @override
  $Res call({
    Object? myARDTO = freezed,
    Object? arCollectionDTO = freezed,
    Object? selected = freezed,
  }) {
    return _then(_MyAREntity(
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
class _$_MyAREntity implements _MyAREntity {
  const _$_MyAREntity(
      {required this.myARDTO,
      required this.arCollectionDTO,
      this.selected = false});

  factory _$_MyAREntity.fromJson(Map<String, dynamic> json) =>
      _$_$_MyAREntityFromJson(json);

  @override
  final ARDTOEntity myARDTO;
  @override
  final CollectionDTOEntity arCollectionDTO;
  @JsonKey(defaultValue: false)
  @override
  final bool selected;

  @override
  String toString() {
    return 'MyAREntity(myARDTO: $myARDTO, arCollectionDTO: $arCollectionDTO, selected: $selected)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _MyAREntity &&
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
  _$MyAREntityCopyWith<_MyAREntity> get copyWith =>
      __$MyAREntityCopyWithImpl<_MyAREntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_MyAREntityToJson(this);
  }
}

abstract class _MyAREntity implements MyAREntity {
  const factory _MyAREntity(
      {required ARDTOEntity myARDTO,
      required CollectionDTOEntity arCollectionDTO,
      bool selected}) = _$_MyAREntity;

  factory _MyAREntity.fromJson(Map<String, dynamic> json) =
      _$_MyAREntity.fromJson;

  @override
  ARDTOEntity get myARDTO => throw _privateConstructorUsedError;
  @override
  CollectionDTOEntity get arCollectionDTO => throw _privateConstructorUsedError;
  @override
  bool get selected => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$MyAREntityCopyWith<_MyAREntity> get copyWith =>
      throw _privateConstructorUsedError;
}
