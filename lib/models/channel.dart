import 'dart:convert';

import 'package:rssread/shared/helpers.dart';

import '../shared/constants.dart'
    show appDocPath, chnImgFname, defaultUpdatePeriod;

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

  String get imagePath => "$appDocPath/$id/$chnImgFname";

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
