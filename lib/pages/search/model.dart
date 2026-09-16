import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rssread/data/repo/feed.dart';
import 'package:rssread/models/pcindex.dart';

import '../../models/feed.dart';

class SearchViewModel extends ChangeNotifier {
  final FeedRepository _feedRepo;
  // ignore: prefer_initializing_formals
  new({required FeedRepository feedRepo}) : _feedRepo = feedRepo;

  final _log = Logger("SearchViewModel");
  String _snackMessage = '';
  String get snackMessage => _snackMessage;

  Future subscribe(Feed? feed) async {
    _log.fine(feed);
    _snackMessage = 'Invalid feed data';
    if (feed != null) {
      final res = await _feedRepo.subscribe(feed);
      if (res) {
        _snackMessage = 'Subscribed to ${feed.channel.title}';
      } else {
        _snackMessage = 'Subscription failed';
      }
    }
    notifyListeners();
  }

  Future<Feed?> fetch(String? url) async {
    if (url != null) {
      return await _feedRepo.fetchFeed(url);
    }
    return null;
  }

  Future pciSearch(PCIndexSearch method, String keywords) async {
    await _feedRepo.searchFeed(method, keywords);
  }

  void clearSnackMessage() {
    _snackMessage = '';
  }
}
