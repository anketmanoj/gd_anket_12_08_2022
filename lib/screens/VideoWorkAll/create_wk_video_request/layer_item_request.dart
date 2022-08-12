import 'package:diamon_rose_app/enum/layer_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer_item_request.freezed.dart';
part 'layer_item_request.g.dart';

@freezed
class RequestLayerItemModel with _$RequestLayerItemModel {
  const factory RequestLayerItemModel({
    int? endTime,
    double? height,
    int? itemId,
    LayerType? itemType,
    int? position,
    double? radian,
    int? volume,
    int? startTime,
    double? width,
    double? xcoordinates,
    double? ycoordinates,
  }) = _RequestLayerItemModel;

  factory RequestLayerItemModel.fromJson(Map<String, dynamic> json) =>
      _$RequestLayerItemModelFromJson(json);
}
