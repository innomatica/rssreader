import 'dart:convert';
import 'dart:io' show File;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'
    show ImageProvider, AssetImage, FileImage, NetworkImage;
import 'package:logging/logging.dart';

import '../shared/constants.dart'
    show appDocPath, chnImgFname, defaultUpdatePeriod, defaultChannelImg;
import '../shared/helpers.dart';

class Channel {
  int id;
  String url;
  String? title;
  String? subtitle;
  String? author;
  String? categories;
  String? description;
  String? content;
  String? language;
  String? link;
  DateTime? published;
  DateTime? updated;
  DateTime? checked;
  int? period;
  String? imageUrl;
  bool? isPodcast;
  bool? hasContent;
  Map<String, dynamic>? extras;
  // from JOIN
  List<dynamic>? labels;

  Channel({
    required this.id,
    required this.url,
    this.title,
    this.subtitle,
    this.author,
    this.categories,
    this.description,
    this.content,
    this.language,
    this.link,
    this.published,
    this.updated,
    this.checked,
    this.period,
    this.imageUrl,
    this.isPodcast,
    this.hasContent,
    this.extras,
    this.labels,
  });

  final _log = Logger('Channel');

  String get imagePath => "$appDocPath/$id/$chnImgFname";

  ImageProvider get image {
    if (imageUrl == null) {
      // _log.fine('assetimage for $title');
      return AssetImage(defaultChannelImg);
    }

    final file = File(imagePath);
    if (file.existsSync()) {
      // _log.fine('file image for $title');
      return FileImage(file);
    } else {
      _downloadImage();
      // _log.fine('network image for $title');
      return NetworkImage(imageUrl!);
    }
  }

  Future<void> _downloadImage() async {
    if (imageUrl != null) {
      try {
        final client = http.Client();
        final req = http.Request('GET', Uri.parse(imageUrl!));
        final res = await client.send(req);
        if (res.statusCode == 200) {
          _log.fine('downloading: $imageUrl to $imagePath');
          final file = File(imagePath);
          await file.create(recursive: true);
          final sink = file.openWrite();
          await res.stream.pipe(sink);
        }
        client.close();
      } catch (e) {
        _log.warning(e.toString());
      }
    }
  }

  factory Channel.fromPCIndex(Map<String, dynamic> data) {
    final lastUpdateSec =
        data['newestItemPublishTime'] ?? data['lastUpdateTime'];

    if (data['url'] is String && data['url'].isNotEmpty) {
      return Channel(
        id: data['url'].hashCode,
        title: data['title'],
        url: data['url'],
        link: data['link'],
        description: data['description'],
        content: data['content'],
        author: data['author'],
        imageUrl: data['image'] ?? googleFaviconUrl(data['link']),
        language: data['language'],
        updated: lastUpdateSec != null && lastUpdateSec is int
            ? DateTime.fromMillisecondsSinceEpoch(
                lastUpdateSec * 1000,
                isUtc: true,
              )
            : DateTime.now(),
        checked: DateTime.now(),
        period: defaultUpdatePeriod,
        categories: data['categories']?.entries
            .map((e) => e.value.toString())
            .join(','),
        isPodcast: true,
        hasContent: true,
        extras: {
          'id': data['id'],
          'itunesId': data['itunesId'],
          'explicit': data['explicit'],
          'episodeCount': data['episodeCount'],
        },
      );
    }
    throw Exception({"message": "invalid data from PodcastIndex: no url"});
  }

  factory Channel.fromSqlite(Map<String, Object?> row) {
    return Channel(
      id: row['id'] as int,
      url: row['url'] as String,
      title: row['title'] as String?,
      subtitle: row['subtitle'] as String?,
      author: row['author'] as String?,
      categories: row['categories'] as String?,
      description: row['description'] as String?,
      content: row['content'] as String?,
      language: row['language'] as String?,
      link: row['link'] as String?,
      updated: DateTime.tryParse(row['updated'] as String? ?? ""),
      published: DateTime.tryParse(row['published'] as String? ?? ""),
      checked: DateTime.tryParse(row['checked'] as String? ?? ""),
      period: row['period'] as int?,
      imageUrl: row['image_url'] as String?,
      isPodcast: row['is_podcast'] as int == 1,
      hasContent: row['has_content'] as int == 1,
      extras: jsonDecode(row['extras'] as String? ?? "null"),
      labels:
          (row['labels'] as String?)
              ?.split(",")
              .map((e) => int.tryParse(e))
              .toList() ??
          [],
    );
  }

  Map<String, Object?> toSqlite() {
    return {
      "id": id,
      "url": url,
      "title": title,
      "subtitle": subtitle,
      "author": author,
      "categories": categories,
      "description": description,
      "content": content,
      "language": language,
      "link": link,
      "updated": updated?.toIso8601String(),
      "published": published?.toIso8601String(),
      "checked": checked?.toIso8601String(),
      "period": period,
      "image_url": imageUrl,
      "is_podcast": isPodcast == true ? 1 : 0,
      "has_content": hasContent == true ? 1 : 0,
      "extras": jsonEncode(extras),
    };
  }

  @override
  String toString() =>
      (toSqlite()
            ..remove('subtitle')
            ..remove('description'))
          .toString();
}
