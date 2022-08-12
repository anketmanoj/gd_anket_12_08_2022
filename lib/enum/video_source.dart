enum VideoSource { 
   local, 
   network,
}

const _videoSourceEnumMap = {
  VideoSource.local: 'local',
  VideoSource.network: 'network',
};

extension VideoSourceParse on VideoSource {
  String? asString() => _videoSourceEnumMap[this];
}