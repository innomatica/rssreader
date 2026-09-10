import 'package:flutter/material.dart';

import './constants.dart'
    show defaultChannelImg, defaultEpisodeImg, placeholderImage;

class UrlImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final double opacity;
  final BoxFit fit;
  final double borderRadius;
  const UrlImage(
    this.url, {
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
      child: Stack(
        children: <Widget>[
          SizedBox(
            width: width,
            height: height,
            child: Center(
              child:
                  width == null ||
                      height == null ||
                      width! < 20.0 ||
                      height! < 20.0
                  ? null
                  : SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
          url != null
              ? FadeInImage.memoryNetwork(
                  placeholder: placeholderImage,
                  image: url!,
                  width: width,
                  height: height,
                  fit: fit,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return StockImage(
                      assetName: defaultEpisodeImg,
                      width: width,
                      height: height,
                      fit: fit,
                    );
                  },
                )
              : StockImage(
                  assetName: defaultChannelImg,
                  width: width,
                  height: height,
                  fit: fit,
                ),
        ],
      ),
    );
  }
}

IconData mediaIcon(String? mediaType) {
  if (mediaType?.contains('audio') == true) {
    return Icons.volume_up_rounded;
  }
  return Icons.question_mark_rounded;
}

class StockImage extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final double opacity;
  final BoxFit fit;

  const StockImage({
    super.key,
    required this.assetName,
    this.width,
    this.height,
    this.opacity = 1.0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
      opacity: AlwaysStoppedAnimation(opacity),
    );
  }
}
