// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ar_dto_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ARDTOEntity _$_$_ARDTOEntityFromJson(Map<String, dynamic> json) {
  return _$_ARDTOEntity(
    id: json['id'] as int,
    userId: json['userId'] as int,
    arCollectionId: json['arCollectionId'] as int,
    createBy: json['createBy'] as int,
    createdAt: json['createdAt'] as String,
    updateBy: json['updateBy'] as int?,
    updatedAt: json['updatedAt'] as String?,
  );
}

Map<String, dynamic> _$_$_ARDTOEntityToJson(_$_ARDTOEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'arCollectionId': instance.arCollectionId,
      'createBy': instance.createBy,
      'createdAt': instance.createdAt,
      'updateBy': instance.updateBy,
      'updatedAt': instance.updatedAt,
    };
