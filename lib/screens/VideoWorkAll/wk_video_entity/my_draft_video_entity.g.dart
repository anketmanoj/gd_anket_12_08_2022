// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_draft_video_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_MyDraftVideoEntity _$_$_MyDraftVideoEntityFromJson(
    Map<String, dynamic> json) {
  return _$_MyDraftVideoEntity(
    id: json['id'] ?? -1,
    videoId: json['videoId'] ?? -1,
    wkVideoName: json['wkVideoName'] as String? ?? '',
    duration: json['duration'] as int? ?? 0,
    status: json['status'] as int? ?? 0,
    lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    listLayer: (json['listLayer'] as List<dynamic>?)
            ?.map(
                (e) => DraftVideoItemEntity.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$_$_MyDraftVideoEntityToJson(
        _$_MyDraftVideoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoId': instance.videoId,
      'wkVideoName': instance.wkVideoName,
      'duration': instance.duration,
      'status': instance.status,
      'lastUpdatedAt': instance.lastUpdatedAt,
      'listLayer': instance.listLayer,
    };
