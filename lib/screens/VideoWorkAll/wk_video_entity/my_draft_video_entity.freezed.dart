// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'my_draft_video_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MyDraftVideoEntity _$MyDraftVideoEntityFromJson(Map<String, dynamic> json) {
  return _MyDraftVideoEntity.fromJson(json);
}

/// @nodoc
class _$MyDraftVideoEntityTearOff {
  const _$MyDraftVideoEntityTearOff();

  _MyDraftVideoEntity call(
      {dynamic id = -1,
      dynamic videoId = -1,
      String wkVideoName = '',
      int duration = 0,
      int status = 0,
      String lastUpdatedAt = '',
      List<DraftVideoItemEntity> listLayer = const []}) {
    return _MyDraftVideoEntity(
      id: id,
      videoId: videoId,
      wkVideoName: wkVideoName,
      duration: duration,
      status: status,
      lastUpdatedAt: lastUpdatedAt,
      listLayer: listLayer,
    );
  }

  MyDraftVideoEntity fromJson(Map<String, Object> json) {
    return MyDraftVideoEntity.fromJson(json);
  }
}

/// @nodoc
const $MyDraftVideoEntity = _$MyDraftVideoEntityTearOff();

/// @nodoc
mixin _$MyDraftVideoEntity {
  dynamic get id => throw _privateConstructorUsedError;
  dynamic get videoId => throw _privateConstructorUsedError;
  String get wkVideoName => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  String get lastUpdatedAt => throw _privateConstructorUsedError;
  List<DraftVideoItemEntity> get listLayer =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MyDraftVideoEntityCopyWith<MyDraftVideoEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyDraftVideoEntityCopyWith<$Res> {
  factory $MyDraftVideoEntityCopyWith(
          MyDraftVideoEntity value, $Res Function(MyDraftVideoEntity) then) =
      _$MyDraftVideoEntityCopyWithImpl<$Res>;
  $Res call(
      {dynamic id,
      dynamic videoId,
      String wkVideoName,
      int duration,
      int status,
      String lastUpdatedAt,
      List<DraftVideoItemEntity> listLayer});
}

/// @nodoc
class _$MyDraftVideoEntityCopyWithImpl<$Res>
    implements $MyDraftVideoEntityCopyWith<$Res> {
  _$MyDraftVideoEntityCopyWithImpl(this._value, this._then);

  final MyDraftVideoEntity _value;
  // ignore: unused_field
  final $Res Function(MyDraftVideoEntity) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? videoId = freezed,
    Object? wkVideoName = freezed,
    Object? duration = freezed,
    Object? status = freezed,
    Object? lastUpdatedAt = freezed,
    Object? listLayer = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      videoId: videoId == freezed
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as dynamic,
      wkVideoName: wkVideoName == freezed
          ? _value.wkVideoName
          : wkVideoName // ignore: cast_nullable_to_non_nullable
              as String,
      duration: duration == freezed
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      status: status == freezed
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdatedAt: lastUpdatedAt == freezed
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      listLayer: listLayer == freezed
          ? _value.listLayer
          : listLayer // ignore: cast_nullable_to_non_nullable
              as List<DraftVideoItemEntity>,
    ));
  }
}

/// @nodoc
abstract class _$MyDraftVideoEntityCopyWith<$Res>
    implements $MyDraftVideoEntityCopyWith<$Res> {
  factory _$MyDraftVideoEntityCopyWith(
          _MyDraftVideoEntity value, $Res Function(_MyDraftVideoEntity) then) =
      __$MyDraftVideoEntityCopyWithImpl<$Res>;
  @override
  $Res call(
      {dynamic id,
      dynamic videoId,
      String wkVideoName,
      int duration,
      int status,
      String lastUpdatedAt,
      List<DraftVideoItemEntity> listLayer});
}

/// @nodoc
class __$MyDraftVideoEntityCopyWithImpl<$Res>
    extends _$MyDraftVideoEntityCopyWithImpl<$Res>
    implements _$MyDraftVideoEntityCopyWith<$Res> {
  __$MyDraftVideoEntityCopyWithImpl(
      _MyDraftVideoEntity _value, $Res Function(_MyDraftVideoEntity) _then)
      : super(_value, (v) => _then(v as _MyDraftVideoEntity));

  @override
  _MyDraftVideoEntity get _value => super._value as _MyDraftVideoEntity;

  @override
  $Res call({
    Object? id = freezed,
    Object? videoId = freezed,
    Object? wkVideoName = freezed,
    Object? duration = freezed,
    Object? status = freezed,
    Object? lastUpdatedAt = freezed,
    Object? listLayer = freezed,
  }) {
    return _then(_MyDraftVideoEntity(
      id: id == freezed ? _value.id : id,
      videoId: videoId == freezed ? _value.videoId : videoId,
      wkVideoName: wkVideoName == freezed
          ? _value.wkVideoName
          : wkVideoName // ignore: cast_nullable_to_non_nullable
              as String,
      duration: duration == freezed
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      status: status == freezed
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdatedAt: lastUpdatedAt == freezed
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      listLayer: listLayer == freezed
          ? _value.listLayer
          : listLayer // ignore: cast_nullable_to_non_nullable
              as List<DraftVideoItemEntity>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MyDraftVideoEntity implements _MyDraftVideoEntity {
  const _$_MyDraftVideoEntity(
      {this.id = -1,
      this.videoId = -1,
      this.wkVideoName = '',
      this.duration = 0,
      this.status = 0,
      this.lastUpdatedAt = '',
      this.listLayer = const []});

  factory _$_MyDraftVideoEntity.fromJson(Map<String, dynamic> json) =>
      _$_$_MyDraftVideoEntityFromJson(json);

  @JsonKey(defaultValue: -1)
  @override
  final dynamic id;
  @JsonKey(defaultValue: -1)
  @override
  final dynamic videoId;
  @JsonKey(defaultValue: '')
  @override
  final String wkVideoName;
  @JsonKey(defaultValue: 0)
  @override
  final int duration;
  @JsonKey(defaultValue: 0)
  @override
  final int status;
  @JsonKey(defaultValue: '')
  @override
  final String lastUpdatedAt;
  @JsonKey(defaultValue: const [])
  @override
  final List<DraftVideoItemEntity> listLayer;

  @override
  String toString() {
    return 'MyDraftVideoEntity(id: $id, videoId: $videoId, wkVideoName: $wkVideoName, duration: $duration, status: $status, lastUpdatedAt: $lastUpdatedAt, listLayer: $listLayer)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _MyDraftVideoEntity &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.videoId, videoId) ||
                const DeepCollectionEquality()
                    .equals(other.videoId, videoId)) &&
            (identical(other.wkVideoName, wkVideoName) ||
                const DeepCollectionEquality()
                    .equals(other.wkVideoName, wkVideoName)) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality()
                    .equals(other.duration, duration)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                const DeepCollectionEquality()
                    .equals(other.lastUpdatedAt, lastUpdatedAt)) &&
            (identical(other.listLayer, listLayer) ||
                const DeepCollectionEquality()
                    .equals(other.listLayer, listLayer)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(videoId) ^
      const DeepCollectionEquality().hash(wkVideoName) ^
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(lastUpdatedAt) ^
      const DeepCollectionEquality().hash(listLayer);

  @JsonKey(ignore: true)
  @override
  _$MyDraftVideoEntityCopyWith<_MyDraftVideoEntity> get copyWith =>
      __$MyDraftVideoEntityCopyWithImpl<_MyDraftVideoEntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_MyDraftVideoEntityToJson(this);
  }
}

abstract class _MyDraftVideoEntity implements MyDraftVideoEntity {
  const factory _MyDraftVideoEntity(
      {dynamic id,
      dynamic videoId,
      String wkVideoName,
      int duration,
      int status,
      String lastUpdatedAt,
      List<DraftVideoItemEntity> listLayer}) = _$_MyDraftVideoEntity;

  factory _MyDraftVideoEntity.fromJson(Map<String, dynamic> json) =
      _$_MyDraftVideoEntity.fromJson;

  @override
  dynamic get id => throw _privateConstructorUsedError;
  @override
  dynamic get videoId => throw _privateConstructorUsedError;
  @override
  String get wkVideoName => throw _privateConstructorUsedError;
  @override
  int get duration => throw _privateConstructorUsedError;
  @override
  int get status => throw _privateConstructorUsedError;
  @override
  String get lastUpdatedAt => throw _privateConstructorUsedError;
  @override
  List<DraftVideoItemEntity> get listLayer =>
      throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$MyDraftVideoEntityCopyWith<_MyDraftVideoEntity> get copyWith =>
      throw _privateConstructorUsedError;
}
