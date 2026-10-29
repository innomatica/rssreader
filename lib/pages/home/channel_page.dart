import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' show GoRouterHelper;
import 'package:rssread/pages/home/model.dart';

import '../../models/channel.dart';
import '../../shared/widgets.dart' show ThumbnailImage;

class ChannelPage extends StatelessWidget {
  final HomeViewModel model;
  const new({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return model.channels.isNotEmpty
            ? SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    alignment: WrapAlignment.center,
                    children: model.channels
                        .map((e) => ChannelTile(channel: e))
                        .toList(),
                  ),
                ),
              )
            : Center(
                child: Icon(
                  Icons.subscriptions_rounded,
                  size: 100,
                  color: Theme.of(context).colorScheme.tertiary.withAlpha(100),
                ),
              );
      },
    );
  }
}

class ChannelTile extends StatelessWidget {
  final Channel channel;
  const new({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/channel/${channel.id}'),
      // onTap: () => print('channel:$channel'),
      child: SizedBox(
        width: 100.0,
        height: 130.0,
        child: Column(
          children: [
            ThumbnailImage(channel.image, width: 100.0, height: 100.0),
            Text(
              channel.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
