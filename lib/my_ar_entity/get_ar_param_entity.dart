import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_ar_param_entity.freezed.dart';
part 'get_ar_param_entity.g.dart';

@freezed
class GetARParamEntity with _$GetARParamEntity {
  const factory GetARParamEntity({
    int? page,
    int? size,
  }) = _GetARParamEntity;

  factory GetARParamEntity.fromJson(Map<String, dynamic> json) =>
      _$GetARParamEntityFromJson(json);
}