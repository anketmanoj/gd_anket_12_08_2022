// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layer_item_cus_dto_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LayerItemCusDTOEntity _$$_LayerItemCusDTOEntityFromJson(
        Map<String, dynamic> json) =>
    _$_LayerItemCusDTOEntity(
      id: json['id'] as int?,
      itemUrl: json['itemUrl'] as String? ?? '',
      itemThumbnailUrl: json['itemThumbnailUrl'] as String? ?? '',
    );

Map<String, dynamic> _$$_LayerItemCusDTOEntityToJson(
        _$_LayerItemCusDTOEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemUrl': instance.itemUrl,
      'itemThumbnailUrl': instance.itemThumbnailUrl,
    };
