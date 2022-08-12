// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layer_item_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_RequestLayerItemModel _$_$_RequestLayerItemModelFromJson(
    Map<String, dynamic> json) {
  return _$_RequestLayerItemModel(
    endTime: json['endTime'] as int?,
    height: (json['height'] as num?)?.toDouble(),
    itemId: json['itemId'] as int?,
    itemType: _$enumDecodeNullable(_$LayerTypeEnumMap, json['itemType']),
    position: json['position'] as int?,
    radian: (json['radian'] as num?)?.toDouble(),
    volume: json['volume'] as int?,
    startTime: json['startTime'] as int?,
    width: (json['width'] as num?)?.toDouble(),
    xcoordinates: (json['xcoordinates'] as num?)?.toDouble(),
    ycoordinates: (json['ycoordinates'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _$_$_RequestLayerItemModelToJson(
        _$_RequestLayerItemModel instance) =>
    <String, dynamic>{
      'endTime': instance.endTime,
      'height': instance.height,
      'itemId': instance.itemId,
      'itemType': _$LayerTypeEnumMap[instance.itemType],
      'position': instance.position,
      'radian': instance.radian,
      'volume': instance.volume,
      'startTime': instance.startTime,
      'width': instance.width,
      'xcoordinates': instance.xcoordinates,
      'ycoordinates': instance.ycoordinates,
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

const _$LayerTypeEnumMap = {
  LayerType.ar: 1,
  LayerType.effect: 2,
  LayerType.background: 3,
  LayerType.none: 0,
};
