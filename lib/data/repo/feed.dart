// ignore_for_file: prefer_initializing_formals

import 'dart:convert' show utf8;

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart' show AudioPlayer;
import 'package:logging/logging.dart';
import 'package:xml/xml.dart';

import '../../models/channel.dart';
import '../../models/episode.dart';
import '../../models/feed.dart';
import '../../models/pcindex.dart';
import '../../shared/constants.dart';
import '../service/api/pcindex.dart';
import '../service/local/sqflite.dart';
import '../service/local/storage.dart';

class FeedRepository {
  final DatabaseService _dbSrv;
  final PCIndexService _pcIdx;
  final StorageService _stSrv;

  new({
    required DatabaseService dbSrv,
    required PCIndexService pcIdx,
    required StorageService stSrv,
    required AudioPlayer player,
  }) : _dbSrv = dbSrv,
       _pcIdx = pcIdx,
       _stSrv = stSrv;

  final _log = Logger('FeedRepository');

  // String sanitizeXml(String input) {
  //   return input.replaceAll(
  //     RegExp(r'<br\s*\/?>', caseSensitive: false),
  //     '<br />',
  //   );
  // }

  // feed
  Future<Feed?> fetchFeed(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200 &&
          res.headers['content-type']?.contains("xml") == true) {
        final document = XmlDocument.parse(
          // fix unclosed <br> tag
          utf8
              .decode(res.bodyBytes)
              .replaceAll(
                RegExp(r'<br\s*\/?>', caseSensitive: false),
                '<br />',
              ),
        );
        // first children
        final children = document.childElements;
        if (children.isNotEmpty) {
          final root = children.first;
          // rss or atom
          if (root.name.toString() == 'rss') {
            return Feed.fromRss(root, url);
          } else if (root.name.toString() == 'feed') {
            return Feed.fromAtom(root, url);
          } else if (root.name.toString() == 'rdf:RDF') {
            return Feed.fromRdf(root, url);
          }
          _log.severe('unknown feed format');
          // throw Exception('unknown feed format');
        }
      } else {
        // http error or non xlm document
        _log.warning('${res.statusCode}: ${res.headers['content-type']}');
      }
    } catch (e) {
      _log.severe(e.toString);
      // throw Exception(e.toString);
    }
    return null;
  }

  Future<List<Channel>> searchPodcasts(
    PCIndexSearch method,
    String keywords,
  ) async {
    return await _pcIdx.searchPodcasts(method, keywords);
  }

  // subscription
  Future<bool> subscribe(Channel channel) async {
    _log.fine('subscribe');
    final channelId = await createChannel(channel);
    if (channelId > 0) {
      return await refreshEpisodesByChannel(channelId);
    }
    return false;
  }

  Future<bool> unsubscribe(int channelId) async {
    _log.fine('unsubscribe');
    try {
      await _dbSrv.delete("DELETE FROM episodes WHERE channel_id = ?", [
        channelId,
      ]);
      await _dbSrv.delete("DELETE FROM channels WHERE id = ?", [channelId]);
      await _stSrv.deleteDirectory(channelId);
      return true;
    } on Exception catch (e) {
      // rethrow;
      _log.severe(e.toString());
    }
    return false;
  }

  // channel
  Future<List<Channel>> getChannels() async {
    try {
      final rows = await _dbSrv.queryAll(
        "SELECT channels.*, group_concat(channel_label.label_id) as labels "
        "FROM channels LEFT JOIN channel_label "
        "  ON channels.id = channel_label.channel_id "
        "  GROUP BY channels.id",
      );
      return rows.map((e) => Channel.fromSqlite(e)).toList();
    } on Exception {
      return [];
    }
  }

  // channel
  Future<Channel?> getChannelById(int channelId) async {
    try {
      final row = await _dbSrv.query(
        "SELECT channels.*, group_concat(channel_label.label_id) as labels "
        "FROM channels LEFT JOIN channel_label "
        "  ON channels.id = channel_label.channel_id "
        "WHERE channels.id = ? "
        "GROUP BY channels.id",
        [channelId],
      );
      return row != null ? Channel.fromSqlite(row) : null;
    } on Exception {
      return null;
    }
  }

  Future<int> createChannel(Channel channel) async {
    try {
      final data = channel.toSqlite();
      final args = List.filled(data.length, '?').join(',');
      final res = await _dbSrv.insert(
        "INSERT INTO channels(${data.keys.join(',')}) VALUES($args)"
        " ON CONFLICT(id) DO NOTHING",
        [...data.values],
      );
      // create thumbnail when channel is created successfully
      if (res > 0) {
        /*
        // download channel image
        if (channel.imageUrl == null ||
            await _downloadResource(
                  channel.id,
                  channel.imageUrl!,
                  chnImgFname,
                ) ==
                false) {
          // failed to download channel thumbnail, use stock image instead
          final byteData = await rootBundle.load(
            channel.isPodcast == true
                ? defaultCastChannelImg
                : defaultNewsChannelImg,
          );
          // save the stock image for the channel thumbnail
          final file = await _stSrv.getFile(channel.id, chnImgFname);
          await file?.create(recursive: true);
          await file?.writeAsBytes(
            byteData.buffer.asUint8List(
              byteData.offsetInBytes,
              byteData.lengthInBytes,
            ),
          );
        }
        */
      }
      return res;
    } on Exception catch (e) {
      // rethrow;
      _log.severe(e.toString());
      return 0;
    }
  }

  Future<int> updateChannel(int channelId, Map<String, dynamic> params) async {
    try {
      final sets = params.keys.map((e) => '$e = ?').join(',');
      final res = await _dbSrv.update(
        "UPDATE channels SET $sets WHERE id = ?",
        [...params.values, channelId],
      );
      return res;
    } on Exception catch (e) {
      // rethrow;
      _log.severe(e.toString());
      return 0;
    }
  }

  // episode

  Future<List<Episode>> getEpisodes() async {
    try {
      final rows = await _dbSrv.queryAll(
        "SELECT episodes.*, channels.title as channel_title, "
        "  channels.image_url as channel_image_url, "
        "  channels.url as channel_url, "
        "  channels.is_podcast as is_podcast, "
        "  channels.has_content as has_content "
        "FROM episodes "
        "INNER JOIN channels ON channels.id=episodes.channel_id "
        "ORDER BY episodes.published DESC",
      );
      return rows.map((e) => Episode.fromSqlite(e)).toList();
    } on Exception {
      rethrow;
    }
  }

  Future<List<Episode>> getEpisodesByChannel(int channelId) async {
    try {
      final rows = await _dbSrv.queryAll(
        "SELECT episodes.*, channels.title as channel_title, "
        "  channels.image_url as channel_image_url, "
        "  channels.url as channel_url, "
        "  channels.is_podcast as is_podcast, "
        "  channels.has_content as has_content "
        "FROM episodes "
        "INNER JOIN channels ON channels.id=episodes.channel_id "
        "WHERE episodes.channel_id = ? "
        " ORDER BY episodes.published DESC",
        [channelId],
      );
      return rows.map((e) => Episode.fromSqlite(e)).toList();
    } on Exception {
      rethrow;
    }
  }

  Future<Episode?> getEpisodeByGuid(String? guid) async {
    try {
      final row = await _dbSrv.query(
        "SELECT episodes.*, channels.title as channel_title, "
        "  channels.image_url as channel_image_url, "
        "  channels.url as channel_url, "
        "  channels.is_podcast as is_podcast, "
        "  channels.has_content as has_content "
        "FROM episodes "
        "INNER JOIN channels ON channels.id=episodes.channel_id "
        "WHERE episodes.guid = ?",
        [guid],
      );
      return row != null ? Episode.fromSqlite(row) : null;
    } on Exception {
      rethrow;
    }
  }

  Future<int> createEpisode(Episode episode) async {
    try {
      final data = episode.toSqlite();
      // data.remove('id');
      final args = List.filled(data.length, '?').join(',');
      final sets = data.keys.map((e) => '$e = ?').join(',');
      return await _dbSrv.insert(
        "INSERT INTO episodes(${data.keys.join(',')}) VALUES($args)"
        " ON CONFLICT(guid) DO UPDATE SET $sets",
        [...data.values, ...data.values],
      );
    } on Exception catch (e) {
      _log.severe(e.toString());
      rethrow;
    }
  }

  Future<int> updateEpisode(int episodeId, Map<String, Object?> data) async {
    try {
      final sets = data.keys.map((e) => '$e = ?').join(',');
      return await _dbSrv.update("UPDATE episodes SET $sets WHERE id = ?", [
        ...data.values,
        episodeId,
      ]);
    } on Exception {
      rethrow;
    }
  }

  Future<void> deleteEpisode(int episodeId) async {
    try {
      await _dbSrv.delete("DELETE FROM episodes WHERE id = ?", [episodeId]);
    } on Exception {
      rethrow;
    }
  }

  Future<bool> refreshEpisodesByChannel(int channelId) async {
    bool flag = false;
    _log.fine('refreshEpisode: $channelId');
    final channel = await getChannelById(channelId);
    if (channel == null) {
      _log.info('no channel found with $channelId');
      return false;
    }

    // get existing episodes
    final episodes = await getEpisodesByChannel(channelId);
    final saveAfter = DateTime.now().subtract(
      Duration(days: dataRetentionPeriod),
    );
    // purge expired episodes
    for (final episode in episodes) {
      if (episode.published.isBefore(saveAfter)) {
        _log.fine('expired:${episode.published}');
        await deleteEpisode(episode.id);
      }
    }
    // get new episodes
    final feed = await fetchFeed(channel.url);
    if (feed == null) {
      _log.warning('fetching feeds yields null');
      return false;
    }

    for (final episode in feed.episodes) {
      // _log.fine('episode: ${episode.guid}');
      // save only new episodes
      if (!episodes.any((e) => e.guid == episode.guid) &&
          episode.published.isAfter(saveAfter)) {
        _log.fine('newly pub: ${episode.published}');
        // this is a not null field: check db schema
        episode.channelId = channelId;
        await createEpisode(episode);
        flag = true;
      }
    }
    return flag;
  }

  Future<bool> downloadEpisode(Episode episode) async {
    if (episode.channelId != null) {
      await updateEpisode(episode.id, {"downloaded": 1});
      return true;
    }
    /*
    if (episode.channelId != null && episode.mediaUrl != null) {
      if (await _downloadResource(
        episode.channelId!,
        episode.mediaUrl!,
        episode.mediaFname,
      )) {
        // download successful
        episode.downloaded = true;
        // note downloaded field type is integer
        await updateEpisode(episode.id, {"downloaded": 1});
        return true;
      }
    }
    */
    return false;
  }

  // Future<bool> _downloadResource(
  //   int channelId,
  //   String url,
  //   String fname,
  // ) async {
  //   try {
  //     final client = http.Client();
  //     final req = http.Request('GET', Uri.parse(url));
  //     final res = await client.send(req);

  //     if (res.statusCode == 200) {
  //       _logger.fine('downloading: $url to $fname');
  //       final file = await _stSrv.getFile(channelId, fname);
  //       if (file != null) {
  //         await file.create(recursive: true);
  //         final sink = file.openWrite();
  //         await res.stream.pipe(sink);
  //         return true;
  //       }
  //     }
  //     // client.close();
  //   } catch (e) {
  //     // rethrow;
  //     _logger.severe(e.toString());
  //   }
  //   return false;
  // }
}
