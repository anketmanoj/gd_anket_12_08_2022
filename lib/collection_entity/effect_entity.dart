import 'package:freezed_annotation/freezed_annotation.dart';

part 'effect_entity.freezed.dart';
part 'effect_entity.g.dart';

@freezed
class EffectEntity with _$EffectEntity {
  const factory EffectEntity({
    @Default(0) int id,
    @Default("") String effectUrl,
    @Default("") String thumbnail,
    @Default("") String downloadKey,
    String? effectDesc,
    int? createBy,
    String? createdAt,
    int? updateBy,
    String? updatedAt,
    @Default(false) bool selected,
  }) = _EffectEntity;

  factory EffectEntity.fromJson(Map<String, dynamic> json) =>
      _$EffectEntityFromJson(json);
}
