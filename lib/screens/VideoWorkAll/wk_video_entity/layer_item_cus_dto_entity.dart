import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer_item_cus_dto_entity.freezed.dart';
part 'layer_item_cus_dto_entity.g.dart';

@freezed
class LayerItemCusDTOEntity with _$LayerItemCusDTOEntity {
  const factory LayerItemCusDTOEntity({
    int? id,
    @Default('') String itemUrl,
    @Default('') String  itemThumbnailUrl,
  }) = _LayerItemCusDTOEntity;

  factory LayerItemCusDTOEntity.fromJson(Map<String, dynamic> json) =>
      _$LayerItemCusDTOEntityFromJson(json);
}
