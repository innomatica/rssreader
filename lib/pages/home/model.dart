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
  String? _currentSeqGuid;
  bool? _playing;
  bool _refreshing = false;

  String? get currentSeqGuid => _currentSeqGuid;
  Episode? get currentSeqEpisode =>
      _episodes.where((e) => e.guid == _currentSeqGuid).firstOrNull;
  bool get playing => _playing == true;
  bool get refreshing => _refreshing;
  List<IndexedAudioSource> get sequence => _sequence;
  double get position => _player.position.inSeconds.toDouble();
  double? get duration => _player.duration?.inSeconds.toDouble();
  Stream<Duration> get positionStream => _player.positionStream;

  void _init() async {
    // _log.fine('init');
    _subPlayerState = _player.playerStateStream.listen((event) async {
      _log.fine('playing: ${event.playing}');
      _log.fine('processingState: ${event.processingState}');
      if (event.playing == true) {
        _playing = true;
        if (event.processingState == ProcessingState.buffering) {
          // playing & buffering
          // seek position: TODO: update bookmark of the episode
        } else if (event.processingState == ProcessingState.loading) {
          // playing & loading
          // media loaded: TODO update media size of the episode
        }
        notifyListeners();
      } else {
        _playing = false;
        if (event.processingState == ProcessingState.ready) {
          // not playing & ready
          // media paused: TODO update bookmark of the episode
        }
        notifyListeners();
      }
    });

    _subSeqState = _player.sequenceStateStream.listen((event) async {
      final src = event.currentSource;
      _log.fine('current index: ${event.currentIndex}');
      // _log.fine('tag:${src?.tag}');
      // _currentSeqGuid = (src?.tag as MediaItem?)?.extras?['guid'];
      _currentSeqGuid = (src?.tag as MediaItem?)?.id;
      _sequence.clear();
      _sequence.addAll(event.sequence);
      notifyListeners();
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
    // _log.fine('load');
    _channels.clear();
    _channels.addAll(await _feedRepo.getChannels());

    _episodes.clear();
    for (final channel in _channels) {
      _episodes.addAll(await _feedRepo.getEpisodesByChannel(channel.id));
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _refreshing = true;
    notifyListeners();

    for (final channel in _channels) {
      if (await _feedRepo.refreshEpisodesByChannel(channel.id)) {
        _log.fine('new episodes found for ${channel.title}');
        notifyListeners();
      }
    }

    _refreshing = false;
    notifyListeners();
  }

  void selectEpisodeType(String newType) {
    if (_episodeType == newType) {
      _episodeType = 'any';
    } else {
      _episodeType = newType;
    }
    notifyListeners();
  }

  void clearSnackMessage() {
    _snackMessage = '';
  }

  Future playEpisode(Episode episode) async {
    if (episode.guid == _currentSeqGuid) {
      return playPause();
    } else {
      // stop current sequence
      await _player.stop();
      // start new sequence
      if (episode.mediaType?.contains('audio') == true &&
          episode.mediaUrl != null) {
        final source = AudioSource.uri(
          episode.downloaded == true
              ? Uri.parse(episode.mediaPath)
              : Uri.parse(episode.mediaUrl!),
          tag: MediaItem(
            id: episode.guid,
            title: episode.title ?? 'title unknown',
            artUri: Uri.tryParse(episode.channelImageUrl ?? ''),
            extras: {"guid": episode.guid, "title": episode.title ?? "unknown"},
          ),
        );
        _player.setAudioSource(source);
        // TODO: apply bookmark here
        _player.play();
      }
    }
  }

  Future downloadEpisode(Episode episode) async {
    final res = await _feedRepo.downloadEpisodeMedia(episode);
    if (res) {
      notifyListeners();
    }
  }

  Future playPause() async {
    _player.playing ? await _player.pause() : await _player.play();
  }

  Future forward(int seconds) async {
    await _player.seek(_player.position + Duration(seconds: seconds));
  }

  Future seek(Duration duration) async {
    await _player.seek(duration);
  }

  Future seekToStart() async {
    await _player.seek(Duration(seconds: 0));
  }

  Future seekToEnd() async {
    await _player.seek(_player.duration);
  }
}
