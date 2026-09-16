import 'dart:convert';

class Episode {
  int id;
  String guid;
  String? title;
  String? subtitle;
  String? author;
  String? description;
  String? content;
  String? language;
  String? categories;
  String? keywords;
  DateTime? updated;
  DateTime published;
  String? link;
  String? mediaUrl;
  String? mediaType;
  int? mediaSize;
  int? mediaDuration;
  int? mediaSeekPos;
  String? imageUrl;
  Map<String, dynamic>? extras;
  // internal use
  bool? downloaded;
  bool? hidden;
  bool? liked;
  // filled after channel save
  int? channelId;
  // from join with channel
  String? channelUrl;
  String? channelTitle;
  String? channelImageUrl;
  bool? isPodcast;
  bool? hasContent;
  // from joint table
  List<dynamic>? labels;

  Episode({
    required this.id,
    required this.guid,
    this.title,
    this.subtitle,
    this.author,
    this.description,
    this.content,
    this.language,
    this.categories,
    this.keywords,
    this.updated,
    required this.published,
    this.link,
    this.mediaUrl,
    this.mediaType,
    this.mediaSize,
    this.mediaDuration,
    this.mediaSeekPos,
    this.imageUrl,
    this.extras,
    this.channelId,
    this.downloaded,
    this.hidden,
    this.liked,
    // from JOIN with channel
    this.channelUrl,
    this.channelTitle,
    this.channelImageUrl,
    this.isPodcast,
    this.hasContent,
    this.labels,
  });

  // String get imagePath => "$appDocPath/$channelId/$id";
  // String get channelImagePath => "$appDocPath/$channelId/$chnImgFname";
  // url could be used as guid
  String get mediaFname => guid.replaceAll('/', '\\');
  String? get imageFname =>
      imageUrl != null ? Uri.tryParse(imageUrl!)?.path.split('/').last : null;

  factory Episode.fromSqlite(Map<String, Object?> row) {
    return Episode(
      id: row['id'] as int,
      guid: row['guid'] as String,
      title: row['title'] as String?,
      subtitle: row['subtitle'] as String?,
      author: row['author'] as String?,
      description: row['description'] as String?,
      content: row['content'] as String?,
      language: row['language'] as String?,
      categories: row['categories'] as String?,
      keywords: row['keywords'] as String?,
      updated: DateTime.tryParse(row['updated'] as String? ?? ""),
      published:
          DateTime.tryParse(row['published'] as String? ?? "") ??
          DateTime.now(),
      link: row['link'] as String?,
      mediaUrl: row['media_url'] as String?,
      mediaType: row['media_type'] as String?,
      mediaSize: row['media_size'] as int?,
      mediaDuration: row['media_duration'] as int?,
      mediaSeekPos: row['media_seek_pos'] as int?,
      imageUrl: row['image_url'] as String?,
      extras: jsonDecode(row['extras'] as String? ?? "null"),
      downloaded: row['downloaded'] == 1,
      hidden: row['hidden'] == 1,
      liked: row['liked'] == 1,
      // from channel by inner join
      channelId: row['channel_id'] as int?,
      channelUrl: row['channel_url'] as String?,
      channelTitle: row['channel_title'] as String?,
      channelImageUrl: row['channel_image_url'] as String?,
      isPodcast: (row['is_podcast'] as int?) == 1 ? true : false,
      hasContent: (row['has_content'] as int?) == 1 ? true : false,
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
      "guid": guid,
      "title": title,
      "subtitle": subtitle,
      "author": author,
      "description": description,
      "content": content,
      "language": language,
      "categories": categories,
      "keywords": keywords,
      "updated": updated?.toIso8601String(),
      "published": published.toIso8601String(),
      "link": link,
      "media_url": mediaUrl,
      "media_type": mediaType,
      "media_size": mediaSize,
      "media_duration": mediaDuration,
      "media_seek_pos": mediaSeekPos,
      "image_url": imageUrl,
      "extras": jsonEncode(extras),
      "channel_id": channelId,
      "downloaded": downloaded == true ? 1 : 0,
      "hidden": hidden == true ? 1 : 0,
      "liked": liked == true ? 1 : 0,
    };
  }

  @override
  String toString() =>
      (toSqlite()
            ..remove('subtitle')
            ..remove('description'))
          .toString();
}
