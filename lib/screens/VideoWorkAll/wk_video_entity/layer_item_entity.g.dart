// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layer_item_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LayerItemEntity _$_$_LayerItemEntityFromJson(Map<String, dynamic> json) {
  return _$_LayerItemEntity(
    id: json['id'] as int? ?? -1,
    itemId: json['itemId'] as int? ?? -1,
    itemType: _$enumDecodeNullable(_$LayerTypeEnumMap, json['itemType']) ??
        LayerType.none,
    position: json['position'] as int? ?? 0,
    width: (json['width'] as num?)?.toDouble() ?? 0,
    height: (json['height'] as num?)?.toDouble() ?? 0,
    radian: (json['radian'] as num?)?.toDouble() ?? 0,
    startTime: json['startTime'] as int? ?? 0,
    endTime: json['endTime'] as int? ?? 0,
    volume: json['volume'] as int? ?? 0,
    xcoordinates: (json['xcoordinates'] as num?)?.toDouble() ?? 0,
    ycoordinates: (json['ycoordinates'] as num?)?.toDouble() ?? 0,
  );
}

Map<String, dynamic> _$_$_LayerItemEntityToJson(_$_LayerItemEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'itemType': _$LayerTypeEnumMap[instance.itemType],
      'position': instance.position,
      'width': instance.width,
      'height': instance.height,
      'radian': instance.radian,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'volume': instance.volume,
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
