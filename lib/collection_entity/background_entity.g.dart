// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BackgroundEntity _$_$_BackgroundEntityFromJson(Map<String, dynamic> json) {
  return _$_BackgroundEntity(
    id: json['id'] as int? ?? 0,
    backgroundUrl: json['backgroundUrl'] as String? ?? '',
    thumbnail: json['thumbnail'] as String? ?? '',
    downloadKey: json['downloadKey'] as String? ?? '',
    backgroundDesc: json['backgroundDesc'] as String?,
    createBy: json['createBy'] as int?,
    createdAt: json['createdAt'] as String?,
    updateBy: json['updateBy'] as int?,
    updatedAt: json['updatedAt'] as String?,
    selected: json['selected'] as bool? ?? false,
  );
}

Map<String, dynamic> _$_$_BackgroundEntityToJson(
        _$_BackgroundEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'backgroundUrl': instance.backgroundUrl,
      'thumbnail': instance.thumbnail,
      'downloadKey': instance.downloadKey,
      'backgroundDesc': instance.backgroundDesc,
      'createBy': instance.createBy,
      'createdAt': instance.createdAt,
      'updateBy': instance.updateBy,
      'updatedAt': instance.updatedAt,
      'selected': instance.selected,
    };
