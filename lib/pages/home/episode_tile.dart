import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../data/repo/feed.dart';
import '../../models/episode.dart';
import '../../pages/home/model.dart';
import '../../shared/helpers.dart' show secsToHhMmSs, sizeStr, mmddHHMM;
import '../../shared/widgets.dart' show UrlImage;

class EpisodeTile extends StatelessWidget {
  final Episode episode;
  final HomeViewModel model;
  const new({super.key, required this.episode, required this.model});

  @override
  Widget build(BuildContext context) {
    return episode.isPodcast == true
        // podcast episode
        ? PodcastTile(episode: episode, model: model)
        // news episode
        : NewsTile(episode: episode);
  }
}

class NewsTile extends StatelessWidget {
  final Episode episode;
  const new({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    final aspectRatio = MediaQuery.sizeOf(context).aspectRatio;
    final channelTextStyle = TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.secondary,
    );
    final titleTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    return ListTile(
      title: aspectRatio < 1.0
          // portrait mode
          ? Column(
              spacing: 8.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top row: favicon, channel title, date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        spacing: 8.0,
                        children: [
                          UrlImage(
                            episode.channelImageUrl,
                            width: 16,
                            height: 16,
                            borderRadius: 2.0,
                          ),
                          Flexible(
                            child: Text(
                              episode.channelTitle ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: channelTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(mmddHHMM(episode.published), style: channelTextStyle),
                  ],
                ),
                // image
                episode.imageUrl != null
                    ? UrlImage(
                        episode.imageUrl!,
                        width: double.maxFinite,
                        height: 180,
                      )
                    : SizedBox(),
                // title
                Text(
                  episode.title ?? '',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: titleTextStyle,
                ),
              ],
            )
          // landscape mode
          : Row(
              spacing: 8.0,
              children: [
                // // image
                // episode.imageUrl != null
                //     ? Image.network(
                //         episode.imageUrl!,
                //         width: 40,
                //         height: 40,
                //         fit: BoxFit.cover,
                //       )
                //     : SizedBox(width: 0, height: 0),
                // content
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // icon, channel, date
                      Row(
                        spacing: 24,
                        children: [
                          Row(
                            spacing: 8.0,
                            children: [
                              UrlImage(
                                episode.channelImageUrl,
                                width: 16,
                                height: 16,
                                borderRadius: 2.0,
                              ),
                              Text(
                                episode.channelTitle ?? "",
                                style: channelTextStyle,
                              ),
                            ],
                          ),
                          Text(
                            mmddHHMM(episode.published),
                            style: channelTextStyle,
                          ),
                        ],
                      ),
                      // episode title
                      // Row > Flexible: limit the width
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              episode.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: titleTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
      onTap: () => handleTap(context, episode),
    );
  }
}

class PodcastTile extends StatelessWidget {
  const new({super.key, required this.episode, required this.model});

  final Episode episode;
  final HomeViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return ListTile(
          selected: model.currentPlayingId == episode.guid,
          // thumbnail : channel title / episode title
          title: Row(
            spacing: 8.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(5.0),
                // child: ChannelImage(episode, width: 60, height: 60),
                child: UrlImage(
                  episode.channelImageUrl,
                  width: 60.0,
                  height: 60.0,
                  borderRadius: 2.0,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // channel title
                    Text(
                      episode.channelTitle ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // episode title
                    Text(
                      episode.title ?? 'unknown',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // published, duration/size
          subtitle: Row(
            children: [
              Text(timeago.format(episode.published)),
              SizedBox(width: 12.0),
              // duration or size
              episode.mediaDuration != null
                  ? Text(secsToHhMmSs(episode.mediaDuration))
                  : Text(sizeStr(episode.mediaSize)),
              Expanded(child: SizedBox()),
              IconButton(
                icon: ListenableBuilder(
                  listenable: model,
                  builder: (context, _) {
                    return model.currentPlayingId == episode.guid &&
                            model.playing
                        ? Icon(Icons.pause_rounded)
                        : Icon(Icons.play_arrow_rounded);
                  },
                ),
                onPressed: episode.mediaType?.contains('audio') == true
                    ? () => model.playEpisode(episode)
                    : null,
              ),
            ],
          ),
          onTap: () => handleTap(context, episode),
        );
      },
    );
  }
}

void handleTap(BuildContext context, Episode episode) {
  // print('episode:$episode');
  // return;
  if (episode.hasContent == true) {
    // show episode description in html format
    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: .symmetric(horizontal: 16.0),
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Padding(
                      padding: .only(top: 60),
                      child: Text(
                        episode.title ?? '',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    TextButton(
                      child: Text(
                        episode.link ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      onPressed: () async {
                        final url = Uri.tryParse(episode.link ?? '');
                        if (url != null && await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                    HtmlWidget(
                      episode.content ?? episode.description ?? '',
                      onTapUrl: (url) async {
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                          return true; // Return true if the link action was handled successfully
                        }
                        return false; // Return false if it failed to open
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 8,
                right: 8,
                child: Container(
                  // padding: .only(top: 4.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    spacing: 4.0,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          episode.channelTitle ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Text(episode.published.toString()),
                      Text(timeago.format(episode.published)),
                      SizedBox(width: 12.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  } else {
    if (episode.link != null) {
      // launch link
      launchUrl(Uri.parse(episode.link!));
    }
  }
}
