import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart' show Logger;

import '../../data/repo/feed.dart';
import '../../models/channel.dart';
import '../../models/feed.dart';

class WebViewModel extends ChangeNotifier {
  final FeedRepository _feedRepo;
  // ignore: prefer_initializing_formals
  new({required FeedRepository feedRepo}) : _feedRepo = feedRepo;

  final _log = Logger("WebViewModel");
  Feed? _feed;

  bool get found => _feed != null;
  Feed? get feed => _feed;
  Channel? get channel => _feed?.channel;

  Future fetchFeed(String url) async {
    _feed = await _feedRepo.fetchFeed(url);
    _log.fine('url: $url, feed: $_feed');
    notifyListeners();
  }

  void reset() async {
    _feed = null;
    notifyListeners();
  }
}
