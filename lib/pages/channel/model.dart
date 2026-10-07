import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart' show Logger;

import '../../data/repo/feed.dart';
import '../../models/channel.dart';
import '../../models/episode.dart';

class ChannelViewModel extends ChangeNotifier {
  final FeedRepository _feedRepo;

  // ignore: prefer_initializing_formals
  new({required FeedRepository feedRepo}) : _feedRepo = feedRepo;

  final _log = Logger('ChannelViewModel');
  Channel? _channel;
  final List<Episode> _episodes = <Episode>[];
  String _snackMessage = '';
  bool _isLoading = true;

  String get snackMessage => _snackMessage;
  Channel? get channel => _channel;
  List<Episode> get episodes => _episodes;
  bool get isPodcast => _channel?.isPodcast == true;
  bool get hasContent => _channel?.hasContent == true;
  String? get author => _channel?.author;
  String? get imageUrl => _channel?.imageUrl;
  String? get categories => _channel?.categories;
  bool get isLoading => _isLoading;

  Future<bool> load(int? channelId) async {
    // this is required to prevent previous data from showing at view
    _isLoading = true;

    if (channelId != null) {
      _channel = await _feedRepo.getChannelById(channelId);
      final episodes = await _feedRepo.getEpisodesByChannel(channelId);
      _episodes.clear();
      _episodes.addAll(episodes);
      _isLoading = false;
      _log.fine('load:$_channel');
      notifyListeners();
      return true;
    }
    return false;
  }

  Future unsubscribe() async {
    if (_channel != null) {
      bool flag = await _feedRepo.unsubscribe(_channel!);
      _snackMessage = flag == true
          ? 'Channel data deleted'
          : 'Failed to delete the channel data';

      notifyListeners();
    }
  }

  Future update(Map<String, dynamic> params) async {
    _log.fine('params: $params');
    if (_channel != null) {
      await _feedRepo.updateChannel(_channel!.id, params);
      _channel = await _feedRepo.getChannelById(_channel!.id);
      _log.fine('channe:$_channel');
      notifyListeners();
    }
  }

  Future showHideEpisode(Episode episode) async {
    if (episode.hidden == true) {
      await _feedRepo.updateEpisode(episode.id, {'hidden': 0});
      episode.hidden = false;
    } else {
      await _feedRepo.updateEpisode(episode.id, {'hidden': 1});
      episode.hidden = true;
    }
    notifyListeners();
  }

  void clearSnackMessage() {
    _snackMessage = '';
  }
}
