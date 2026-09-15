// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:just_audio/just_audio.dart'
    show AudioPlayer, AudioSource, IndexedAudioSource, ProcessingState;
import 'package:just_audio_background/just_audio_background.dart'
    show MediaItem;
import 'package:logging/logging.dart' show Logger;

import '../../data/repo/feed.dart' show FeedRepository;
import '../../models/channel.dart';
import '../../models/episode.dart' show Episode;

// import '../../models/feed.dart' show Feed;

class HomeViewModel extends ChangeNotifier {
  final FeedRepository _feedRepo;
  final AudioPlayer _player;

  new({required FeedRepository feedRepo, required AudioPlayer player})
    : _feedRepo = feedRepo,
      _player = player {
    _init();
  }

  final _log = Logger('HomeViewModel');
  final _episodes = <Episode>[];
  final _channels = <Channel>[];
  final _sequence = <IndexedAudioSource>[];

  late StreamSubscription _subPlayerState;
  late StreamSubscription _subSeqState;
  String _episodeType = 'any';
  String _snackMessage = "";
  String? _currentPlayingId;
  bool? _playing;

  String? get currentPlayingId => _currentPlayingId;
  Episode? get currentPlayingEpisode =>
      _episodes.where((e) => e.guid == _currentPlayingId).firstOrNull;
  bool get playing => _playing == true;
  List<IndexedAudioSource> get sequence => _sequence;

  void _init() async {
    _subPlayerState = _player.playerStateStream.listen((event) async {
      _log.fine(event.playing);
      _log.fine(event.processingState);
      if (event.processingState == ProcessingState.loading ||
          event.processingState == ProcessingState.buffering) {
      } else if (event.playing == true) {
        _playing = true;
        notifyListeners();
      } else {
        _playing = false;
        notifyListeners();
      }
    });
    _subSeqState = _player.sequenceStateStream.listen((event) async {
      final src = event.currentSource;
      _log.fine(event.sequence);
      _log.fine(event.currentIndex);
      _log.fine(event.currentSource);
      _log.fine(event.currentSource?.tag);
      _currentPlayingId = (src?.tag as MediaItem?)?.extras?['guid'];
      notifyListeners();
      _sequence.clear();
      _sequence.addAll(event.sequence);
    });
  }

  @override
  void dispose() {
    _subPlayerState.cancel();
    _subSeqState.cancel();
    super.dispose();
  }

  List<Episode> get episodes =>
      _episodes
          .where(
            (e) => _episodeType == 'any'
                ? true
                : _episodeType == 'podcast'
                ? e.isPodcast == true
                : e.isPodcast == false,
          )
          .toList()
        ..sort((a, b) => b.published.compareTo(a.published));
  List<Channel> get channels =>
      _channels
          .where(
            (e) => _episodeType == 'any'
                ? true
                : _episodeType == 'podcast'
                ? e.isPodcast == true
                : e.isPodcast == false,
          )
          .toList()
        ..sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
  String get snackMessage => _snackMessage;
  String get episodeType => _episodeType;

  Future<void> load() async {
    _channels.clear();
    _channels.addAll(await _feedRepo.getChannels());
    // _log.fine(_channels);
    notifyListeners();

    _episodes.clear();
    for (final channel in _channels) {
      _episodes.addAll(await _feedRepo.getEpisodesByChannel(channel.id));
      notifyListeners();
    }
  }

  void selectEpisodeType(String newType) {
    if (_episodeType == newType) {
      _episodeType = 'any';
    } else {
      _episodeType = newType;
    }
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

  Future playEpisode(Episode episode) async {
    if (_player.playing) {
      await _player.stop();
      return;
    }
    if (episode.mediaType?.contains('audio') == true &&
        episode.mediaUrl != null) {
      final source = AudioSource.uri(
        Uri.parse(episode.mediaUrl!),
        tag: MediaItem(
          id: '1',
          title: episode.title ?? 'title unknown',
          artUri: Uri.tryParse(episode.channelImageUrl ?? ''),
          extras: {"guid": episode.guid, "title": episode.title ?? "unknown"},
        ),
      );
      _player.setAudioSource(source);
      _player.play();
    }
  }

  Future playPause() async {
    _player.playing ? _player.pause() : _player.play();
  }

  Future forward() async {}
}
