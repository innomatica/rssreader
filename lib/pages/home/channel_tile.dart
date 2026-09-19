import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rssread/shared/widgets.dart' show UrlImage;

import '../../models/channel.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;
  const new({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/channel/${channel.id}'),
      // onTap: () => print('channel:$channel'),
      child: SizedBox(
        width: 110.0,
        height: 130.0,
        child: Column(
          children: [
            UrlImage(channel.imageUrl, width: 110.0, height: 110.0),
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
