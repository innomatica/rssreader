import 'package:flutter/material.dart';
import 'package:rssread/shared/helpers.dart';

import '../../shared/widgets.dart' show MediaImage;
import './model.dart';

class PlayerPage extends StatelessWidget {
  final HomeViewModel model;
  const new({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    double sliderPos = 0;
    bool sliderChg = false;
    // print('screenSize:$screenSize');

    return Center(
      child: Column(
        crossAxisAlignment: .center,
        mainAxisAlignment: .center,
        children: [
          // channel image
          screenSize.height > 700
              ? Padding(
                  padding: const .only(bottom: 32.0),
                  child: MediaImage(
                    model.currentSeqEpisode?.channelImage,
                    width: 200,
                    height: 200,
                    borderRadius: 12.0,
                  ),
                )
              : SizedBox(height: 0.0),
          // position slider
          StreamBuilder(
            stream: model.positionStream.distinct(
              // filter out subsecond events
              (prev, next) => prev.inSeconds == next.inSeconds,
            ),
            builder: (context, AsyncSnapshot<Duration> snapshot) {
              if (snapshot.hasData && sliderChg == false) {
                sliderPos = snapshot.data!.inSeconds.toDouble();
              }
              return StatefulBuilder(
                builder: (context, setState) {
                  return Slider(
                    value: sliderPos,
                    max: model.duration ?? 100.0,
                    divisions: model.duration?.toInt() ?? 100,
                    padding: .symmetric(
                      horizontal: screenSize.width > 500 ? 200.0 : 32.0,
                    ),
                    label: secsToHhMmSs(sliderPos.toInt()),
                    onChanged: (value) {
                      setState(() {});
                      sliderPos = value;
                    },
                    onChangeStart: (value) {
                      sliderChg = true;
                    },
                    onChangeEnd: (value) {
                      sliderChg = false;
                      model.seek(Duration(seconds: value.toInt()));
                    },
                  );
                },
              );
            },
          ),
          // current position and media duration
          Padding(
            padding: .symmetric(
              horizontal: screenSize.width > 500 ? 200.0 : 32.0,
            ),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                StreamBuilder(
                  stream: model.positionStream.distinct(
                    (prev, next) => prev.inSeconds == next.inSeconds,
                  ),
                  builder: (context, snapshot) =>
                      Text(secsToHhMmSs(snapshot.data?.inSeconds)),
                ),
                ListenableBuilder(
                  listenable: model,
                  builder: (context, _) =>
                      Text(secsToHhMmSs(model.duration?.toInt() ?? 3600)),
                ),
              ],
            ),
          ),
          // media control
          Row(
            mainAxisSize: .max,
            mainAxisAlignment: .center,
            spacing: 8.0,
            children: [
              // seek to zero
              IconButton(
                onPressed: () => model.seekToStart(),
                icon: Icon(Icons.skip_previous_rounded, size: 26.0),
              ),
              // back 30 sec
              IconButton(
                onPressed: () => model.forward(-30),
                icon: Icon(Icons.replay_30_rounded, size: 26.0),
              ),
              // play / pause
              ListenableBuilder(
                listenable: model,
                builder: (context, _) {
                  return IconButton(
                    onPressed: () => model.playPause(),
                    icon: model.playing
                        ? Icon(Icons.pause_rounded, size: 56.0)
                        : Icon(Icons.play_arrow_rounded, size: 50.0),
                  );
                },
              ),
              // forward 30 sec
              IconButton(
                onPressed: () => model.forward(30),
                icon: Icon(Icons.forward_30_rounded, size: 26.0),
              ),
              // seek to end
              IconButton(
                onPressed: () => model.seekToEnd(),
                icon: Icon(Icons.skip_next_rounded, size: 26.0),
              ),
            ],
          ),
          screenSize.height > 700
              ? Container(
                  height: 200,
                  padding: .symmetric(horizontal: 20.0),
                  child: ListView.builder(
                    itemCount: model.sequence.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          model.sequence[index].tag.extras['title'] ??
                              'unknown',
                          maxLines: 1,
                          overflow: .ellipsis,
                        ),
                      );
                    },
                  ),
                )
              : SizedBox(height: 0.0),
        ],
      ),
    );
  }
}
