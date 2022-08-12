import 'package:diamon_rose_app/screens/VideoWorkAll/wk_video_entity/draft_video_item_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_draft_video_entity.freezed.dart';
part 'my_draft_video_entity.g.dart';

@freezed
class MyDraftVideoEntity with _$MyDraftVideoEntity {
  const factory MyDraftVideoEntity({
    @Default(-1) id,
    @Default(-1) videoId,
    @Default('') String wkVideoName,
    @Default(0) int duration,
    @Default(0) int status,
    @Default('') String lastUpdatedAt,
    @Default([]) List<DraftVideoItemEntity> listLayer,
  }) = _MyDraftVideoEntity;

  factory MyDraftVideoEntity.fromJson(Map<String, dynamic> json) =>
      _$MyDraftVideoEntityFromJson(json);
}
