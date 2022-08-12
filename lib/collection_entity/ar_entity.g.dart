// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ar_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_AREntity _$_$_AREntityFromJson(Map<String, dynamic> json) {
  return _$_AREntity(
    id: json['id'] as int? ?? 0,
    arUrl: json['arUrl'] as String? ?? '',
    thumbnail: json['thumbnail'] as String? ?? '',
    arName: json['arName'] as String?,
    arType: json['arType'] as int? ?? 0,
    deleteFlag: json['deleteFlag'] as bool?,
    createBy: json['createBy'] as int?,
    createdAt: json['createdAt'] as String?,
    updateBy: json['updateBy'] as int?,
    updatedAt: json['updatedAt'] as String?,
  );
}

Map<String, dynamic> _$_$_AREntityToJson(_$_AREntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'arUrl': instance.arUrl,
      'thumbnail': instance.thumbnail,
      'arName': instance.arName,
      'arType': instance.arType,
      'deleteFlag': instance.deleteFlag,
      'createBy': instance.createBy,
      'createdAt': instance.createdAt,
      'updateBy': instance.updateBy,
      'updatedAt': instance.updatedAt,
    };
