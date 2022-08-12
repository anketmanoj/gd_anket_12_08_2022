import 'package:freezed_annotation/freezed_annotation.dart';

enum LayerType {
  @JsonValue(1)
  ar,

  @JsonValue(2)
  effect,

  @JsonValue(3)
  background,

  @JsonValue(0)
  none,
}

extension LayerTypeParse on LayerType {
  String asString() => _layerTypeEnumMap[this] ?? '';

  int? asInt() => _layerTypeEnumMapInt[this];

  bool get isAR {
    switch (this) {// ignore: missing_enum_constant_in_switch
      case LayerType.ar:
        return true;
    }
    return false;
  }

  bool get isEffect {
    switch (this) {// ignore: missing_enum_constant_in_switch
      case LayerType.effect:
        return true;
    }
    return false;
  }

  bool get isBackground {
    switch (this) {// ignore: missing_enum_constant_in_switch
      case LayerType.background:
        return true;
    }
    return false;
  }
}

const _layerTypeEnumMapInt = {
  LayerType.ar: 1,
  LayerType.effect: 2,
  LayerType.background: 3,
  LayerType.none: 0,
};

const _layerTypeEnumMap = {
  LayerType.ar: 'AR',
  LayerType.background: 'Background',
  LayerType.effect: 'Effect',
  LayerType.none: 'None',
};
