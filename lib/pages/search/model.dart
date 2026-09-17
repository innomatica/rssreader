import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rssread/data/repo/feed.dart';
import 'package:rssread/models/pcindex.dart';

import '../../models/channel.dart';
import '../../models/feed.dart';

class SearchViewModel extends ChangeNotifier {
  final FeedRepository _feedRepo;
  // ignore: prefer_initializing_formals
  new({required FeedRepository feedRepo}) : _feedRepo = feedRepo;

  final _log = Logger("SearchViewModel");
  String _snackMessage = '';
  String get snackMessage => _snackMessage;

  Future subscribe(Channel? channel) async {
    _log.fine(channel);
    _snackMessage = 'Invalid channel data';
    if (channel != null) {
      final res = await _feedRepo.subscribe(channel);
      if (res) {
        _snackMessage = 'Subscribed to ${channel.title}';
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

  Future<List<Channel>> pciSearch(PCIndexSearch method, String keywords) async {
    return await _feedRepo.searchPodcasts(method, keywords);
  }

  void clearSnackMessage() {
    _snackMessage = '';
  }
}
