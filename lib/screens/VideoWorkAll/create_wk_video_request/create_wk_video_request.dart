import 'package:diamon_rose_app/enum/status_video_type.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_wk_video_request/layer_item_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_wk_video_request.freezed.dart';
part 'create_wk_video_request.g.dart';

@freezed
class RequestCreateWkVideoModel with _$RequestCreateWkVideoModel {
  const factory RequestCreateWkVideoModel({
    int? duration,
    double? canvasWidth,
    double? canvasHeight,
    List<RequestLayerItemModel>? layerItems,
    String? titleVideo,
    StatusVideoType? status,
  }) = _RequestCreateWkVideoModel;

  factory RequestCreateWkVideoModel.fromJson(Map<String, dynamic> json) =>
      _$RequestCreateWkVideoModelFromJson(json);
}
