enum VideoType { free, paid, all, setting }

const _videoTypeEnumMap = {
  VideoType.free: 1,
  VideoType.paid: 2,
  VideoType.all: 3,
  VideoType.setting: 4
};

extension VideoTypeParse on VideoType {
  int? asString() => _videoTypeEnumMap[this];
}
