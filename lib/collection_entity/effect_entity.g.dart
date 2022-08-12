// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effect_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_EffectEntity _$_$_EffectEntityFromJson(Map<String, dynamic> json) {
  return _$_EffectEntity(
    id: json['id'] as int? ?? 0,
    effectUrl: json['effectUrl'] as String? ?? '',
    thumbnail: json['thumbnail'] as String? ?? '',
    downloadKey: json['downloadKey'] as String? ?? '',
    effectDesc: json['effectDesc'] as String?,
    createBy: json['createBy'] as int?,
    createdAt: json['createdAt'] as String?,
    updateBy: json['updateBy'] as int?,
    updatedAt: json['updatedAt'] as String?,
    selected: json['selected'] as bool? ?? false,
  );
}

Map<String, dynamic> _$_$_EffectEntityToJson(_$_EffectEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'effectUrl': instance.effectUrl,
      'thumbnail': instance.thumbnail,
      'downloadKey': instance.downloadKey,
      'effectDesc': instance.effectDesc,
      'createBy': instance.createBy,
      'createdAt': instance.createdAt,
      'updateBy': instance.updateBy,
      'updatedAt': instance.updatedAt,
      'selected': instance.selected,
    };
