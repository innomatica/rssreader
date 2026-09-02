import 'package:flutter/foundation.dart';
import 'package:rssread/data/repo/feed.dart';

import '../../models/channel.dart';

class ChannelViewModel extends ChangeNotifier {
  final FeedRepository _feedRepo;

  // ignore: prefer_initializing_formals
  new({required FeedRepository feedRepo}) : _feedRepo = feedRepo;

  Channel? _channel;
  String _snackMessage = '';

  String get snackMessage => _snackMessage;
  Channel? get channel => _channel;

  Future load(int? channelId) async {
    if (channelId != null) {
      _channel = await _feedRepo.getChannelById(channelId);
      notifyListeners();
    }
  }

  Future unsubscribe(int channelId) async {
    bool flag = await _feedRepo.unsubscribe(channelId);

    _snackMessage = flag == true
        ? 'Channel data deleted'
        : 'Failed to delete the channel data';

    return notifyListeners();
  }

  void clearSnackMessage() {
    _snackMessage = '';
  }
}
