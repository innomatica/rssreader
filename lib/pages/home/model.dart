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
  // String _episodeType = 'any';
  String _snackMessage = "";
  // String? _currentSeqGuid;
  MediaItem? _currentTag;
  bool _refreshing = false;

  // String? get currentSeqGuid => _currentSeqGuid;
  MediaItem? get currentTag => _currentTag;
  Episode? get currentSeqEpisode =>
      _episodes.where((e) => e.guid == _currentTag?.id).firstOrNull;
  bool get playing => _player.playing == true;
  bool get refreshing => _refreshing;
  ProcessingState? get processingState => _player.processingState;
  List<IndexedAudioSource> get sequence => _sequence;
  double get position => _player.position.inSeconds.toDouble();
  Duration? get duration => _player.duration;
  Stream<Duration> get positionStream => _player.positionStream;

  void _init() async {
    // _log.fine('init');
    _subPlayerState = _player.playerStateStream.listen((event) async {
      _log.fine('playing: ${event.playing}');
      _log.fine('processingState: ${event.processingState}');
      if (event.playing == true) {
        if (event.processingState == ProcessingState.buffering) {
          // playing & buffering
          // user taps seek button: update bookmark
          _saveBookmark(currentSeqEpisode, _player.position);
        } else if (event.processingState == ProcessingState.loading) {
          // playing & loading
          // media loaded: update media size of the episode
          _updateDuration(currentSeqEpisode, _player.duration);
        } else if (event.processingState == ProcessingState.completed) {
          // completed
          if (currentSeqEpisode != null) {
            hideEpisode(currentSeqEpisode!, forceStop: true);
          }
        }
        notifyListeners();
      } else {
        if (event.processingState == ProcessingState.ready) {
          // not playing & ready
          if (_player.position > Duration(seconds: 100)) {
            // media paused during playing: update bookmark
            _saveBookmark(currentSeqEpisode, _player.position);
          } else {
            // media just loaded: do not update bookmark
          }
        }
        notifyListeners();
      }
    });

    _subSeqState = _player.sequenceStateStream.listen((event) async {
      final src = event.currentSource;
      _log.fine('current index: ${event.currentIndex}');
      // _log.fine('tag:${src?.tag}');
      // _currentSeqGuid = (src?.tag as MediaItem?)?.extras?['guid'];
      // _currentSeqGuid = (src?.tag as MediaItem?)?.id;
      _currentTag = src?.tag as MediaItem?;
      _sequence.clear();
      _sequence.addAll(event.sequence);
      notifyListeners();
    });
  }

  void _updateDuration(Episode? episode, Duration? duration) {
    if (episode != null && duration != null) {
      // update local data
      episode.mediaDuration = duration.inSeconds;
      // but not the database for now
    }
  }

  Future _saveBookmark(Episode? episode, Duration? position) async {
    if (episode != null && position != null) {
      // update local data
      episode.mediaSeekPos = position.inSeconds;
      // update database
      await _feedRepo.updateEpisode(episode.id, {
        "media_seek_pos": position.inSeconds,
      });
    }
  }

  @override
  void dispose() {
    _subPlayerState.cancel();
    _subSeqState.cancel();
    super.dispose();
  }

  List<Episode> get episodes =>
      _episodes.where((e) => e.hidden != true).toList()
        ..sort((a, b) => b.published.compareTo(a.published));
  List<Channel> get channels =>
      _channels.toList()
        ..sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
  String get snackMessage => _snackMessage;

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
      final res = await _feedRepo.refreshEpisodesByChannel(channel.id);

      if (res['created'] != null && (res['created'] as List).isNotEmpty) {
        _log.fine('episodes created for ${channel.title}');
        _episodes.addAll(res['created']! as List<Episode>);
        notifyListeners();
      }

      if (res['deleted'] != null && (res['deleted'] as List).isNotEmpty) {
        _log.fine('episodes deleted for ${channel.title}');
        _episodes.removeWhere((e) => res['deleted']!.contains(e));
        notifyListeners();
      }
    }
    _refreshing = false;
    // FIXME: this doesn't work why?
    // notifyListeners();
    // but this does
    await load();
  }

  void clearSnackMessage() {
    _snackMessage = '';
  }

  Future playEpisode(Episode episode) async {
    if (episode.guid == _currentTag?.id) {
      return playPause();
    } else {
      // stop current sequence
      await _player.stop();
      // start new sequence
      if (episode.mediaType?.contains('audio') == true &&
          episode.mediaUrl != null) {
        final source = AudioSource.uri(
          episode.localMedia?.isNotEmpty == true
              ? Uri.parse(episode.localMedia!)
              : Uri.parse(episode.mediaUrl!),
          tag: MediaItem(
            id: episode.guid,
            title: episode.title ?? 'title unknown',
            artUri: Uri.tryParse(episode.channelImageUrl ?? ''),
            extras: {"id": episode.id},
          ),
        );
        print(episode);
        await _player.setAudioSource(source);
        _log.fine('play episide: ${episode.id} -${episode.mediaSeekPos}');
        if (episode.mediaSeekPos != null) {
          // apply bookmark
          await _player.seek(Duration(seconds: episode.mediaSeekPos!));
        }
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

  Future hideEpisode(Episode episode, {bool forceStop = false}) async {
    // NOTE: do not change the order of executions
    episode.hidden = true;
    episode.localMedia = null;
    episode.mediaSeekPos = 0;
    await _feedRepo.updateEpisode(episode.id, {
      'hidden': 1,
      'local_media': null,
      'media_seek_pos': null,
    });
    await _feedRepo.deleteEpisodeMedia(episode);
    if (episode.guid == _currentTag?.id && forceStop) {
      // NOTE: this will fire notifyListeners()
      await _player.stop();
    } else {
      // otherwise need to call notifyListeners() here
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

  Future stop() async {
    await _player.stop();
  }
}
