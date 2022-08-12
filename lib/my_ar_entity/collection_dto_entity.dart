import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_dto_entity.freezed.dart';
part 'collection_dto_entity.g.dart';

@freezed
class CollectionDTOEntity with _$CollectionDTOEntity {
  const factory CollectionDTOEntity(
      {required int id,
      required String arUrl,
      required int arType,
      required String arName,
      @Default('') String thumbnail,
      @Default('') String downloadKey,
      @Default('') String thumbnailDownloadKey,
      @Default(false) bool deleteFlag,
      required int createBy,
      required String createdAt,
      int? updateBy,
      String? updatedAt}) = _CollectionDTOEntity;

  factory CollectionDTOEntity.fromJson(Map<String, dynamic> json) =>
      _$CollectionDTOEntityFromJson(json);
}
