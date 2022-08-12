// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_wk_video_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_RequestCreateWkVideoModel _$_$_RequestCreateWkVideoModelFromJson(
    Map<String, dynamic> json) {
  return _$_RequestCreateWkVideoModel(
    duration: json['duration'] as int?,
    canvasWidth: (json['canvasWidth'] as num?)?.toDouble(),
    canvasHeight: (json['canvasHeight'] as num?)?.toDouble(),
    layerItems: (json['layerItems'] as List<dynamic>?)
        ?.map((e) => RequestLayerItemModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    titleVideo: json['titleVideo'] as String?,
    status: _$enumDecodeNullable(_$StatusVideoTypeEnumMap, json['status']),
  );
}

Map<String, dynamic> _$_$_RequestCreateWkVideoModelToJson(
        _$_RequestCreateWkVideoModel instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'canvasWidth': instance.canvasWidth,
      'canvasHeight': instance.canvasHeight,
      'layerItems': instance.layerItems,
      'titleVideo': instance.titleVideo,
      'status': _$StatusVideoTypeEnumMap[instance.status],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$StatusVideoTypeEnumMap = {
  StatusVideoType.draft: 1,
  StatusVideoType.completed: 2,
};
