import 'package:diamon_rose_app/enum/layer_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer_item_entity.freezed.dart';
part 'layer_item_entity.g.dart';

@freezed
class LayerItemEntity with _$LayerItemEntity {
  const factory LayerItemEntity({
    @Default(-1) int id,
    @Default(-1) int itemId,
    @Default(LayerType.none) LayerType itemType,
    @Default(0) int position,
    @Default(0) double width,
    @Default(0) double height,
    @Default(0) double radian,
    @Default(0) int startTime,
    @Default(0) int endTime,
    @Default(0) int volume,
    @Default(0) double xcoordinates,
    @Default(0) double ycoordinates,
  }) = _LayerItemEntity;

  factory LayerItemEntity.fromJson(Map<String, dynamic> json) =>
      _$LayerItemEntityFromJson(json);
}
