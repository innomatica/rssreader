import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:logging/logging.dart' show Logger;

import '../../data/repo/feed.dart' show FeedRepository;
import '../../models/channel.dart';
import '../../models/episode.dart' show Episode;

// import '../../models/feed.dart' show Feed;

class HomeViewModel extends ChangeNotifier {
  final FeedRepository _feedRepo;
  final _log = Logger('HomeViewModel');
  final _episodes = <Episode>[];
  final _channels = <Channel>[];
  bool _isPodcast = false;

  String _snackMessage = "";

  List<Episode> get episodes =>
      _episodes.where((e) => e.isPodcast == _isPodcast).toList()
        ..sort((a, b) => b.published.compareTo(a.published));
  List<Channel> get channels =>
      _channels..sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
  String get snackMessage => _snackMessage;
  bool get isPodcast => _isPodcast;

  // ignore: prefer_initializing_formals
  new({required FeedRepository feedRepo}) : _feedRepo = feedRepo;

  Future<void> load() async {
    _channels.clear();
    _channels.addAll(await _feedRepo.getChannels());
    _log.fine(_channels);
    notifyListeners();

    _episodes.clear();
    for (final channel in _channels) {
      _episodes.addAll(await _feedRepo.getEpisodesByChannel(channel.id));
      notifyListeners();
    }
  }

  void selectPodcasts(bool flag) {
    _isPodcast = flag;
    _log.fine(_isPodcast);
    notifyListeners();
  }

  void refreshEpisodes() async {
    _snackMessage = "Checking science daily";
    notifyListeners();

    /*
    var feed = await _feedRepo.fetchFeed(
      'https://sciencedaily.com/rss/top/technology.xml',
    );
    if (feed != null) {
      // _log.fine(feed);
      // _log.fine(feed.channel);
      // _log.fine(feed.episodes);
      _episodes.addAll(feed.episodes);
      notifyListeners();
    }
    _snackMessage = "Checking cbc";
    feed = await _feedRepo.fetchFeed(
      'https://www.cbc.ca/webfeed/rss/rss-canada-ottawa',
    );
    if (feed != null) {
      // _log.fine(feed);
      // _log.fine(feed.channel);
      // _log.fine(feed.episodes);
      _episodes.addAll(feed.episodes);
      notifyListeners();
    }
    */
  }

  void clearSnackMessage() {
    _snackMessage = '';
  }
}
