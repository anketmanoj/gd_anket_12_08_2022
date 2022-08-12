import 'package:freezed_annotation/freezed_annotation.dart';

part 'ar_dto_entity.freezed.dart';
part 'ar_dto_entity.g.dart';

@freezed
class ARDTOEntity with _$ARDTOEntity {
  const factory ARDTOEntity(
      {required int id,
      required int userId,
      required int arCollectionId,
      required int createBy,
      required String createdAt,
      int? updateBy,
      String? updatedAt}) = _ARDTOEntity;

  factory ARDTOEntity.fromJson(Map<String, dynamic> json) =>
      _$ARDTOEntityFromJson(json);
}
