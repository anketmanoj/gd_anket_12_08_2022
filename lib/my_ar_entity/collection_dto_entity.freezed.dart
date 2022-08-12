// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'collection_dto_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CollectionDTOEntity _$CollectionDTOEntityFromJson(Map<String, dynamic> json) {
  return _CollectionDTOEntity.fromJson(json);
}

/// @nodoc
class _$CollectionDTOEntityTearOff {
  const _$CollectionDTOEntityTearOff();

  _CollectionDTOEntity call(
      {required int id,
      required String arUrl,
      required int arType,
      required String arName,
      String thumbnail = '',
      String downloadKey = '',
      String thumbnailDownloadKey = '',
      bool deleteFlag = false,
      required int createBy,
      required String createdAt,
      int? updateBy,
      String? updatedAt}) {
    return _CollectionDTOEntity(
      id: id,
      arUrl: arUrl,
      arType: arType,
      arName: arName,
      thumbnail: thumbnail,
      downloadKey: downloadKey,
      thumbnailDownloadKey: thumbnailDownloadKey,
      deleteFlag: deleteFlag,
      createBy: createBy,
      createdAt: createdAt,
      updateBy: updateBy,
      updatedAt: updatedAt,
    );
  }

  CollectionDTOEntity fromJson(Map<String, Object> json) {
    return CollectionDTOEntity.fromJson(json);
  }
}

/// @nodoc
const $CollectionDTOEntity = _$CollectionDTOEntityTearOff();

/// @nodoc
mixin _$CollectionDTOEntity {
  int get id => throw _privateConstructorUsedError;
  String get arUrl => throw _privateConstructorUsedError;
  int get arType => throw _privateConstructorUsedError;
  String get arName => throw _privateConstructorUsedError;
  String get thumbnail => throw _privateConstructorUsedError;
  String get downloadKey => throw _privateConstructorUsedError;
  String get thumbnailDownloadKey => throw _privateConstructorUsedError;
  bool get deleteFlag => throw _privateConstructorUsedError;
  int get createBy => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  int? get updateBy => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CollectionDTOEntityCopyWith<CollectionDTOEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectionDTOEntityCopyWith<$Res> {
  factory $CollectionDTOEntityCopyWith(
          CollectionDTOEntity value, $Res Function(CollectionDTOEntity) then) =
      _$CollectionDTOEntityCopyWithImpl<$Res>;
  $Res call(
      {int id,
      String arUrl,
      int arType,
      String arName,
      String thumbnail,
      String downloadKey,
      String thumbnailDownloadKey,
      bool deleteFlag,
      int createBy,
      String createdAt,
      int? updateBy,
      String? updatedAt});
}

/// @nodoc
class _$CollectionDTOEntityCopyWithImpl<$Res>
    implements $CollectionDTOEntityCopyWith<$Res> {
  _$CollectionDTOEntityCopyWithImpl(this._value, this._then);

  final CollectionDTOEntity _value;
  // ignore: unused_field
  final $Res Function(CollectionDTOEntity) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? arUrl = freezed,
    Object? arType = freezed,
    Object? arName = freezed,
    Object? thumbnail = freezed,
    Object? downloadKey = freezed,
    Object? thumbnailDownloadKey = freezed,
    Object? deleteFlag = freezed,
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
      arUrl: arUrl == freezed
          ? _value.arUrl
          : arUrl // ignore: cast_nullable_to_non_nullable
              as String,
      arType: arType == freezed
          ? _value.arType
          : arType // ignore: cast_nullable_to_non_nullable
              as int,
      arName: arName == freezed
          ? _value.arName
          : arName // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnail: thumbnail == freezed
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String,
      downloadKey: downloadKey == freezed
          ? _value.downloadKey
          : downloadKey // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailDownloadKey: thumbnailDownloadKey == freezed
          ? _value.thumbnailDownloadKey
          : thumbnailDownloadKey // ignore: cast_nullable_to_non_nullable
              as String,
      deleteFlag: deleteFlag == freezed
          ? _value.deleteFlag
          : deleteFlag // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$CollectionDTOEntityCopyWith<$Res>
    implements $CollectionDTOEntityCopyWith<$Res> {
  factory _$CollectionDTOEntityCopyWith(_CollectionDTOEntity value,
          $Res Function(_CollectionDTOEntity) then) =
      __$CollectionDTOEntityCopyWithImpl<$Res>;
  @override
  $Res call(
      {int id,
      String arUrl,
      int arType,
      String arName,
      String thumbnail,
      String downloadKey,
      String thumbnailDownloadKey,
      bool deleteFlag,
      int createBy,
      String createdAt,
      int? updateBy,
      String? updatedAt});
}

/// @nodoc
class __$CollectionDTOEntityCopyWithImpl<$Res>
    extends _$CollectionDTOEntityCopyWithImpl<$Res>
    implements _$CollectionDTOEntityCopyWith<$Res> {
  __$CollectionDTOEntityCopyWithImpl(
      _CollectionDTOEntity _value, $Res Function(_CollectionDTOEntity) _then)
      : super(_value, (v) => _then(v as _CollectionDTOEntity));

  @override
  _CollectionDTOEntity get _value => super._value as _CollectionDTOEntity;

  @override
  $Res call({
    Object? id = freezed,
    Object? arUrl = freezed,
    Object? arType = freezed,
    Object? arName = freezed,
    Object? thumbnail = freezed,
    Object? downloadKey = freezed,
    Object? thumbnailDownloadKey = freezed,
    Object? deleteFlag = freezed,
    Object? createBy = freezed,
    Object? createdAt = freezed,
    Object? updateBy = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_CollectionDTOEntity(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      arUrl: arUrl == freezed
          ? _value.arUrl
          : arUrl // ignore: cast_nullable_to_non_nullable
              as String,
      arType: arType == freezed
          ? _value.arType
          : arType // ignore: cast_nullable_to_non_nullable
              as int,
      arName: arName == freezed
          ? _value.arName
          : arName // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnail: thumbnail == freezed
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String,
      downloadKey: downloadKey == freezed
          ? _value.downloadKey
          : downloadKey // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailDownloadKey: thumbnailDownloadKey == freezed
          ? _value.thumbnailDownloadKey
          : thumbnailDownloadKey // ignore: cast_nullable_to_non_nullable
              as String,
      deleteFlag: deleteFlag == freezed
          ? _value.deleteFlag
          : deleteFlag // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$_CollectionDTOEntity implements _CollectionDTOEntity {
  const _$_CollectionDTOEntity(
      {required this.id,
      required this.arUrl,
      required this.arType,
      required this.arName,
      this.thumbnail = '',
      this.downloadKey = '',
      this.thumbnailDownloadKey = '',
      this.deleteFlag = false,
      required this.createBy,
      required this.createdAt,
      this.updateBy,
      this.updatedAt});

  factory _$_CollectionDTOEntity.fromJson(Map<String, dynamic> json) =>
      _$_$_CollectionDTOEntityFromJson(json);

  @override
  final int id;
  @override
  final String arUrl;
  @override
  final int arType;
  @override
  final String arName;
  @JsonKey(defaultValue: '')
  @override
  final String thumbnail;
  @JsonKey(defaultValue: '')
  @override
  final String downloadKey;
  @JsonKey(defaultValue: '')
  @override
  final String thumbnailDownloadKey;
  @JsonKey(defaultValue: false)
  @override
  final bool deleteFlag;
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
    return 'CollectionDTOEntity(id: $id, arUrl: $arUrl, arType: $arType, arName: $arName, thumbnail: $thumbnail, downloadKey: $downloadKey, thumbnailDownloadKey: $thumbnailDownloadKey, deleteFlag: $deleteFlag, createBy: $createBy, createdAt: $createdAt, updateBy: $updateBy, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _CollectionDTOEntity &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.arUrl, arUrl) ||
                const DeepCollectionEquality().equals(other.arUrl, arUrl)) &&
            (identical(other.arType, arType) ||
                const DeepCollectionEquality().equals(other.arType, arType)) &&
            (identical(other.arName, arName) ||
                const DeepCollectionEquality().equals(other.arName, arName)) &&
            (identical(other.thumbnail, thumbnail) ||
                const DeepCollectionEquality()
                    .equals(other.thumbnail, thumbnail)) &&
            (identical(other.downloadKey, downloadKey) ||
                const DeepCollectionEquality()
                    .equals(other.downloadKey, downloadKey)) &&
            (identical(other.thumbnailDownloadKey, thumbnailDownloadKey) ||
                const DeepCollectionEquality().equals(
                    other.thumbnailDownloadKey, thumbnailDownloadKey)) &&
            (identical(other.deleteFlag, deleteFlag) ||
                const DeepCollectionEquality()
                    .equals(other.deleteFlag, deleteFlag)) &&
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
      const DeepCollectionEquality().hash(arUrl) ^
      const DeepCollectionEquality().hash(arType) ^
      const DeepCollectionEquality().hash(arName) ^
      const DeepCollectionEquality().hash(thumbnail) ^
      const DeepCollectionEquality().hash(downloadKey) ^
      const DeepCollectionEquality().hash(thumbnailDownloadKey) ^
      const DeepCollectionEquality().hash(deleteFlag) ^
      const DeepCollectionEquality().hash(createBy) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updateBy) ^
      const DeepCollectionEquality().hash(updatedAt);

  @JsonKey(ignore: true)
  @override
  _$CollectionDTOEntityCopyWith<_CollectionDTOEntity> get copyWith =>
      __$CollectionDTOEntityCopyWithImpl<_CollectionDTOEntity>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_CollectionDTOEntityToJson(this);
  }
}

abstract class _CollectionDTOEntity implements CollectionDTOEntity {
  const factory _CollectionDTOEntity(
      {required int id,
      required String arUrl,
      required int arType,
      required String arName,
      String thumbnail,
      String downloadKey,
      String thumbnailDownloadKey,
      bool deleteFlag,
      required int createBy,
      required String createdAt,
      int? updateBy,
      String? updatedAt}) = _$_CollectionDTOEntity;

  factory _CollectionDTOEntity.fromJson(Map<String, dynamic> json) =
      _$_CollectionDTOEntity.fromJson;

  @override
  int get id => throw _privateConstructorUsedError;
  @override
  String get arUrl => throw _privateConstructorUsedError;
  @override
  int get arType => throw _privateConstructorUsedError;
  @override
  String get arName => throw _privateConstructorUsedError;
  @override
  String get thumbnail => throw _privateConstructorUsedError;
  @override
  String get downloadKey => throw _privateConstructorUsedError;
  @override
  String get thumbnailDownloadKey => throw _privateConstructorUsedError;
  @override
  bool get deleteFlag => throw _privateConstructorUsedError;
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
  _$CollectionDTOEntityCopyWith<_CollectionDTOEntity> get copyWith =>
      throw _privateConstructorUsedError;
}
