import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/channel.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;
  const new({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/channel/${channel.id}'),
      child: SizedBox(
        width: 120.0,
        height: 140.0,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(10.0),
              child: Image.file(
                File(channel.imagePath),
                width: 120.0,
                height: 120.0,
                fit: BoxFit.cover,
              ),
            ),
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
