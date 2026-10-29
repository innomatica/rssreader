import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import './model.dart';
import '../../models/episode.dart';
import '../../shared/helpers.dart'
    show secsToHhMmSs, sizeStr, mmddHHMM, daysAgo;
import '../../shared/widgets.dart' show ThumbnailImage;

class EpisodePage extends StatelessWidget {
  final HomeViewModel model;
  final bool isPodcast;
  const new({super.key, required this.model, required this.isPodcast});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final episodes = model.episodes.where((e) => e.isPodcast == isPodcast);
        return episodes.isNotEmpty
            ? ListView.separated(
                key: const PageStorageKey('episode_list_key'),
                separatorBuilder: (context, _) => Padding(
                  padding: const .only(bottom: 8.0, left: 8.0, right: 8.0),
                  child: Divider(indent: 0, endIndent: 0, height: 0),
                ),
                itemCount: episodes.length,
                itemBuilder: (context, index) {
                  final episode = episodes.elementAt(index);
                  return Dismissible(
                    key: ValueKey<int>(episode.id),
                    direction: DismissDirection.endToStart,
                    background: SizedBox(),
                    secondaryBackground: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.redAccent,
                          size: 30,
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                    onDismissed: (direction) async {
                      await model.hideEpisode(episode, forceStop: true);
                    },
                    child: EpisodeTile(episode: episode, model: model),
                  );
                },
              )
            : Center(
                child: isPodcast
                    ? Icon(
                        Icons.mic,
                        size: 100,
                        color: Theme.of(context).colorScheme.secondary
                            .withAlpha(100),
                      )
                    : Icon(
                        Icons.newspaper_rounded,
                        size: 100,
                        color: Theme.of(context).colorScheme.secondary
                            .withAlpha(100),
                      ),
              );
      },
    );
  }
}

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
    final channelTextStyle = TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.secondary,
    );
    final titleTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    return ListTile(
      title: Column(
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
                    ThumbnailImage(
                      episode.channelImage,
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
              ? ThumbnailImage(
                  episode.image,
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
      ),
      // landscape mode
      onTap: () async {
        if (episode.link != null &&
            await canLaunchUrl(Uri.parse(episode.link!))) {
          launchUrl(Uri.parse(episode.link!));
        }
      },
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
          selected: model.currentSeqGuid == episode.guid,
          // thumbnail : channel title / episode title
          title: Row(
            spacing: 8.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(5.0),
                child: ThumbnailImage(
                  episode.channelImage,
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
              // published
              Text(daysAgo(episode.published)),
              SizedBox(width: 12.0),
              // duration or size
              episode.mediaDuration != null
                  ? Text(secsToHhMmSs(episode.mediaDuration))
                  : Text(sizeStr(episode.mediaSize)),
              // space
              Expanded(child: SizedBox()),
              // download button
              IconButton(
                icon: ListenableBuilder(
                  listenable: model,
                  builder: (context, _) {
                    return episode.localMedia?.isNotEmpty == true
                        ? Icon(Icons.audio_file_outlined)
                        : Icon(Icons.cloud_download_outlined);
                  },
                ),
                onPressed: episode.mediaType?.contains('audio') == true
                    ? () => model.downloadEpisode(episode)
                    : null,
              ),
            ],
          ),
          onTap: () => model.playEpisode(episode),
        );
      },
    );
  }
}
