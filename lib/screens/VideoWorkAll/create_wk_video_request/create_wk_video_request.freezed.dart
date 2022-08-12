// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'create_wk_video_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

RequestCreateWkVideoModel _$RequestCreateWkVideoModelFromJson(
    Map<String, dynamic> json) {
  return _RequestCreateWkVideoModel.fromJson(json);
}

/// @nodoc
class _$RequestCreateWkVideoModelTearOff {
  const _$RequestCreateWkVideoModelTearOff();

  _RequestCreateWkVideoModel call(
      {int? duration,
      double? canvasWidth,
      double? canvasHeight,
      List<RequestLayerItemModel>? layerItems,
      String? titleVideo,
      StatusVideoType? status}) {
    return _RequestCreateWkVideoModel(
      duration: duration,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      layerItems: layerItems,
      titleVideo: titleVideo,
      status: status,
    );
  }

  RequestCreateWkVideoModel fromJson(Map<String, Object> json) {
    return RequestCreateWkVideoModel.fromJson(json);
  }
}

/// @nodoc
const $RequestCreateWkVideoModel = _$RequestCreateWkVideoModelTearOff();

/// @nodoc
mixin _$RequestCreateWkVideoModel {
  int? get duration => throw _privateConstructorUsedError;
  double? get canvasWidth => throw _privateConstructorUsedError;
  double? get canvasHeight => throw _privateConstructorUsedError;
  List<RequestLayerItemModel>? get layerItems =>
      throw _privateConstructorUsedError;
  String? get titleVideo => throw _privateConstructorUsedError;
  StatusVideoType? get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RequestCreateWkVideoModelCopyWith<RequestCreateWkVideoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestCreateWkVideoModelCopyWith<$Res> {
  factory $RequestCreateWkVideoModelCopyWith(RequestCreateWkVideoModel value,
          $Res Function(RequestCreateWkVideoModel) then) =
      _$RequestCreateWkVideoModelCopyWithImpl<$Res>;
  $Res call(
      {int? duration,
      double? canvasWidth,
      double? canvasHeight,
      List<RequestLayerItemModel>? layerItems,
      String? titleVideo,
      StatusVideoType? status});
}

/// @nodoc
class _$RequestCreateWkVideoModelCopyWithImpl<$Res>
    implements $RequestCreateWkVideoModelCopyWith<$Res> {
  _$RequestCreateWkVideoModelCopyWithImpl(this._value, this._then);

  final RequestCreateWkVideoModel _value;
  // ignore: unused_field
  final $Res Function(RequestCreateWkVideoModel) _then;

  @override
  $Res call({
    Object? duration = freezed,
    Object? canvasWidth = freezed,
    Object? canvasHeight = freezed,
    Object? layerItems = freezed,
    Object? titleVideo = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      duration: duration == freezed
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      canvasWidth: canvasWidth == freezed
          ? _value.canvasWidth
          : canvasWidth // ignore: cast_nullable_to_non_nullable
              as double?,
      canvasHeight: canvasHeight == freezed
          ? _value.canvasHeight
          : canvasHeight // ignore: cast_nullable_to_non_nullable
              as double?,
      layerItems: layerItems == freezed
          ? _value.layerItems
          : layerItems // ignore: cast_nullable_to_non_nullable
              as List<RequestLayerItemModel>?,
      titleVideo: titleVideo == freezed
          ? _value.titleVideo
          : titleVideo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: status == freezed
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusVideoType?,
    ));
  }
}

/// @nodoc
abstract class _$RequestCreateWkVideoModelCopyWith<$Res>
    implements $RequestCreateWkVideoModelCopyWith<$Res> {
  factory _$RequestCreateWkVideoModelCopyWith(_RequestCreateWkVideoModel value,
          $Res Function(_RequestCreateWkVideoModel) then) =
      __$RequestCreateWkVideoModelCopyWithImpl<$Res>;
  @override
  $Res call(
      {int? duration,
      double? canvasWidth,
      double? canvasHeight,
      List<RequestLayerItemModel>? layerItems,
      String? titleVideo,
      StatusVideoType? status});
}

/// @nodoc
class __$RequestCreateWkVideoModelCopyWithImpl<$Res>
    extends _$RequestCreateWkVideoModelCopyWithImpl<$Res>
    implements _$RequestCreateWkVideoModelCopyWith<$Res> {
  __$RequestCreateWkVideoModelCopyWithImpl(_RequestCreateWkVideoModel _value,
      $Res Function(_RequestCreateWkVideoModel) _then)
      : super(_value, (v) => _then(v as _RequestCreateWkVideoModel));

  @override
  _RequestCreateWkVideoModel get _value =>
      super._value as _RequestCreateWkVideoModel;

  @override
  $Res call({
    Object? duration = freezed,
    Object? canvasWidth = freezed,
    Object? canvasHeight = freezed,
    Object? layerItems = freezed,
    Object? titleVideo = freezed,
    Object? status = freezed,
  }) {
    return _then(_RequestCreateWkVideoModel(
      duration: duration == freezed
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      canvasWidth: canvasWidth == freezed
          ? _value.canvasWidth
          : canvasWidth // ignore: cast_nullable_to_non_nullable
              as double?,
      canvasHeight: canvasHeight == freezed
          ? _value.canvasHeight
          : canvasHeight // ignore: cast_nullable_to_non_nullable
              as double?,
      layerItems: layerItems == freezed
          ? _value.layerItems
          : layerItems // ignore: cast_nullable_to_non_nullable
              as List<RequestLayerItemModel>?,
      titleVideo: titleVideo == freezed
          ? _value.titleVideo
          : titleVideo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: status == freezed
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusVideoType?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_RequestCreateWkVideoModel implements _RequestCreateWkVideoModel {
  const _$_RequestCreateWkVideoModel(
      {this.duration,
      this.canvasWidth,
      this.canvasHeight,
      this.layerItems,
      this.titleVideo,
      this.status});

  factory _$_RequestCreateWkVideoModel.fromJson(Map<String, dynamic> json) =>
      _$_$_RequestCreateWkVideoModelFromJson(json);

  @override
  final int? duration;
  @override
  final double? canvasWidth;
  @override
  final double? canvasHeight;
  @override
  final List<RequestLayerItemModel>? layerItems;
  @override
  final String? titleVideo;
  @override
  final StatusVideoType? status;

  @override
  String toString() {
    return 'RequestCreateWkVideoModel(duration: $duration, canvasWidth: $canvasWidth, canvasHeight: $canvasHeight, layerItems: $layerItems, titleVideo: $titleVideo, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _RequestCreateWkVideoModel &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality()
                    .equals(other.duration, duration)) &&
            (identical(other.canvasWidth, canvasWidth) ||
                const DeepCollectionEquality()
                    .equals(other.canvasWidth, canvasWidth)) &&
            (identical(other.canvasHeight, canvasHeight) ||
                const DeepCollectionEquality()
                    .equals(other.canvasHeight, canvasHeight)) &&
            (identical(other.layerItems, layerItems) ||
                const DeepCollectionEquality()
                    .equals(other.layerItems, layerItems)) &&
            (identical(other.titleVideo, titleVideo) ||
                const DeepCollectionEquality()
                    .equals(other.titleVideo, titleVideo)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(canvasWidth) ^
      const DeepCollectionEquality().hash(canvasHeight) ^
      const DeepCollectionEquality().hash(layerItems) ^
      const DeepCollectionEquality().hash(titleVideo) ^
      const DeepCollectionEquality().hash(status);

  @JsonKey(ignore: true)
  @override
  _$RequestCreateWkVideoModelCopyWith<_RequestCreateWkVideoModel>
      get copyWith =>
          __$RequestCreateWkVideoModelCopyWithImpl<_RequestCreateWkVideoModel>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_RequestCreateWkVideoModelToJson(this);
  }
}

abstract class _RequestCreateWkVideoModel implements RequestCreateWkVideoModel {
  const factory _RequestCreateWkVideoModel(
      {int? duration,
      double? canvasWidth,
      double? canvasHeight,
      List<RequestLayerItemModel>? layerItems,
      String? titleVideo,
      StatusVideoType? status}) = _$_RequestCreateWkVideoModel;

  factory _RequestCreateWkVideoModel.fromJson(Map<String, dynamic> json) =
      _$_RequestCreateWkVideoModel.fromJson;

  @override
  int? get duration => throw _privateConstructorUsedError;
  @override
  double? get canvasWidth => throw _privateConstructorUsedError;
  @override
  double? get canvasHeight => throw _privateConstructorUsedError;
  @override
  List<RequestLayerItemModel>? get layerItems =>
      throw _privateConstructorUsedError;
  @override
  String? get titleVideo => throw _privateConstructorUsedError;
  @override
  StatusVideoType? get status => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$RequestCreateWkVideoModelCopyWith<_RequestCreateWkVideoModel>
      get copyWith => throw _privateConstructorUsedError;
}
