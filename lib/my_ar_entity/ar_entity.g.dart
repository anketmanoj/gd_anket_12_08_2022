// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_ar_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_AREntity _$_$_AREntityFromJson(Map<String, dynamic> json) {
  return _$_AREntity(
    myARDTO: ARDTOEntity.fromJson(json['myARDTO'] as Map<String, dynamic>),
    arCollectionDTO: CollectionDTOEntity.fromJson(
        json['arCollectionDTO'] as Map<String, dynamic>),
    selected: json['selected'] as bool? ?? false,
  );
}

Map<String, dynamic> _$_$_AREntityToJson(_$_AREntity instance) =>
    <String, dynamic>{
      'myARDTO': instance.myARDTO,
      'arCollectionDTO': instance.arCollectionDTO,
      'selected': instance.selected,
    };
