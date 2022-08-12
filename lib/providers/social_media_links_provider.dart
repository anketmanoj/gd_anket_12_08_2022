import 'package:flutter/material.dart';

class SocialMediaLinksProvider extends ChangeNotifier {
  String? _url;
  String? _youtubeUrl;
  String? _instagramUrl;
  String? _twitterUrl;

  String? get url => _url;
  String? get youtubeUrl => _youtubeUrl;
  String? get instagramUrl => _instagramUrl;
  String? get twitterUrl => _twitterUrl;

  // set url
  Function(String) setUrl({String? url}) {
    return (String url) {
      _url = url;
      notifyListeners();
    };
  }

  // set youtube url
  Function(String) setYoutubeUrl({String? youtubeUrl}) {
    return (String youtubeUrl) {
      _youtubeUrl = youtubeUrl.replaceAll(' ', '');
      notifyListeners();
    };
  }

  // set instagram url
  Function(String) setInstagramUrl({String? instagramUrl}) {
    return (String instagramUrl) {
      _instagramUrl = instagramUrl.replaceAll(' ', '');
      notifyListeners();
    };
  }

  // set twitter url
  Function(String) setTwitterUrl({String? twitterUrl}) {
    return (String twitterUrl) {
      _twitterUrl = twitterUrl.replaceAll(' ', '');
      notifyListeners();
    };
  }

  // set social media links
  void setSocialMediaLinks({
    String? url,
    String? youtubeUrl,
    String? instagramUrl,
    String? twitterUrl,
  }) {
    _url = url;
    _youtubeUrl = youtubeUrl;
    _instagramUrl = instagramUrl;
    _twitterUrl = twitterUrl;
    notifyListeners();
  }
}
