import 'package:freezed_annotation/freezed_annotation.dart';

part 'background_entity.freezed.dart';
part 'background_entity.g.dart';

@freezed
class BackgroundEntity with _$BackgroundEntity {
  const factory BackgroundEntity({
    @Default(0) int id,
    @Default("") String backgroundUrl,
    @Default("") String thumbnail,
    @Default("") String downloadKey,
    String? backgroundDesc,
    int? createBy,
    String? createdAt,
    int? updateBy,
    String? updatedAt,
    @Default(false) bool selected,
  }) = _BackgroundEntity;

  factory BackgroundEntity.fromJson(Map<String, dynamic> json) =>
      _$BackgroundEntityFromJson(json);
}
