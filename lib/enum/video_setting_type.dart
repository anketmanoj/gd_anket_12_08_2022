import 'package:freezed_annotation/freezed_annotation.dart';

enum VideoSettingType {
  @JsonValue(1)
  free,
  @JsonValue(2)
  paid,
}
