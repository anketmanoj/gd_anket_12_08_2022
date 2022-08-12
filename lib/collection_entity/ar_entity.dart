import 'package:freezed_annotation/freezed_annotation.dart';

part 'ar_entity.freezed.dart';
part 'ar_entity.g.dart';

@freezed
class AREntity with _$AREntity {
  const factory AREntity({
    @Default(0) int id,
    @Default("") String arUrl,
    @Default("") String thumbnail,
    String? arName,
    @Default(0) int arType,
    bool? deleteFlag,
    int? createBy,
    String? createdAt,
    int? updateBy,
    String? updatedAt,
  }) = _AREntity;

  factory AREntity.fromJson(Map<String, dynamic> json) =>
      _$AREntityFromJson(json);
}
