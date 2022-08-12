import 'package:diamon_rose_app/screens/VideoWorkAll/wk_video_entity/layer_item_cus_dto_entity.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/wk_video_entity/layer_item_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draft_video_item_entity.freezed.dart';
part 'draft_video_item_entity.g.dart';

@freezed
class DraftVideoItemEntity with _$DraftVideoItemEntity {
  const factory DraftVideoItemEntity({
    required LayerItemEntity layerItem,
    required LayerItemCusDTOEntity layerItemCusDTO,
  }) = _DraftVideoItemEntity;

  factory DraftVideoItemEntity.fromJson(Map<String, dynamic> json) =>
      _$DraftVideoItemEntityFromJson(json);
}
