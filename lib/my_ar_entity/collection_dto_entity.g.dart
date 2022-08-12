// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_dto_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CollectionDTOEntity _$_$_CollectionDTOEntityFromJson(
    Map<String, dynamic> json) {
  return _$_CollectionDTOEntity(
    id: json['id'] as int,
    arUrl: json['arUrl'] as String,
    arType: json['arType'] as int,
    arName: json['arName'] as String,
    thumbnail: json['thumbnail'] as String? ?? '',
    downloadKey: json['downloadKey'] as String? ?? '',
    thumbnailDownloadKey: json['thumbnailDownloadKey'] as String? ?? '',
    deleteFlag: json['deleteFlag'] as bool? ?? false,
    createBy: json['createBy'] as int,
    createdAt: json['createdAt'] as String,
    updateBy: json['updateBy'] as int?,
    updatedAt: json['updatedAt'] as String?,
  );
}

Map<String, dynamic> _$_$_CollectionDTOEntityToJson(
        _$_CollectionDTOEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'arUrl': instance.arUrl,
      'arType': instance.arType,
      'arName': instance.arName,
      'thumbnail': instance.thumbnail,
      'downloadKey': instance.downloadKey,
      'thumbnailDownloadKey': instance.thumbnailDownloadKey,
      'deleteFlag': instance.deleteFlag,
      'createBy': instance.createBy,
      'createdAt': instance.createdAt,
      'updateBy': instance.updateBy,
      'updatedAt': instance.updatedAt,
    };
