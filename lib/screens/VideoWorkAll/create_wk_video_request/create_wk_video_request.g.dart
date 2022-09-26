// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_wk_video_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_RequestCreateWkVideoModel _$$_RequestCreateWkVideoModelFromJson(
        Map<String, dynamic> json) =>
    _$_RequestCreateWkVideoModel(
      duration: json['duration'] as int?,
      canvasWidth: (json['canvasWidth'] as num?)?.toDouble(),
      canvasHeight: (json['canvasHeight'] as num?)?.toDouble(),
      layerItems: (json['layerItems'] as List<dynamic>?)
          ?.map(
              (e) => RequestLayerItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      titleVideo: json['titleVideo'] as String?,
      status: $enumDecodeNullable(_$StatusVideoTypeEnumMap, json['status']),
    );

Map<String, dynamic> _$$_RequestCreateWkVideoModelToJson(
        _$_RequestCreateWkVideoModel instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'canvasWidth': instance.canvasWidth,
      'canvasHeight': instance.canvasHeight,
      'layerItems': instance.layerItems,
      'titleVideo': instance.titleVideo,
      'status': _$StatusVideoTypeEnumMap[instance.status],
    };

const _$StatusVideoTypeEnumMap = {
  StatusVideoType.draft: 1,
  StatusVideoType.completed: 2,
};
