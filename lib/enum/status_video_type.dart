import 'package:freezed_annotation/freezed_annotation.dart';

enum StatusVideoType {
  @JsonValue(1)
  draft,
  @JsonValue(2)
  completed
}

const _statusVideoTypeEnumMap = {
  StatusVideoType.draft: 'draft',
  StatusVideoType.completed: 'completed',
};

extension StatusVideoTypeParse on StatusVideoType {
  String? asString() => _statusVideoTypeEnumMap[this];
}
