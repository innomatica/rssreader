import 'dart:convert' show base64Decode;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';

import './constants.dart' show defaultChannelImg;

// placeholder
final Uint8List placeholderImage = base64Decode(
  // 30
  // 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mOUqwcAAMEAnwarUJAAAAAASUVORK5CYII=',
  // 50
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mM0qgcAAOkAsw4XxxMAAAAASUVORK5CYII=',
);

class MediaImage extends StatelessWidget {
  final ImageProvider? image;
  final double? width;
  final double? height;
  final double opacity;
  final BoxFit fit;
  final double borderRadius;
  const MediaImage(
    this.image, {
    super.key,
    this.width,
    this.height,
    this.opacity = 1.0,
    this.fit = BoxFit.cover,
    this.borderRadius = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(borderRadius),
      child: image != null
          ? FadeInImage(
              placeholder: MemoryImage(placeholderImage),
              fadeInDuration: Duration(milliseconds: 100),
              fadeOutDuration: Duration(milliseconds: 50),
              image: image!,
              width: width,
              height: height,
              fit: fit,
              imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                defaultChannelImg,
                width: width,
                height: height,
                fit: fit,
              ),
            )
          : Image.asset(
              defaultChannelImg,
              width: width,
              height: height,
              fit: fit,
            ),
    );
  }
}
