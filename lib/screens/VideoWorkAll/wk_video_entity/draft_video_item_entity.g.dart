// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_video_item_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DraftVideoItemEntity _$$_DraftVideoItemEntityFromJson(
        Map<String, dynamic> json) =>
    _$_DraftVideoItemEntity(
      layerItem:
          LayerItemEntity.fromJson(json['layerItem'] as Map<String, dynamic>),
      layerItemCusDTO: LayerItemCusDTOEntity.fromJson(
          json['layerItemCusDTO'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_DraftVideoItemEntityToJson(
        _$_DraftVideoItemEntity instance) =>
    <String, dynamic>{
      'layerItem': instance.layerItem,
      'layerItemCusDTO': instance.layerItemCusDTO,
    };
