import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rssread/shared/helpers.dart';

import 'model.dart';

class PlayerFAB extends StatefulWidget {
  final HomeViewModel model;
  const new({super.key, required this.model});
  @override
  State<PlayerFAB> createState() => _PlayerFABState();
}

class _PlayerFABState extends State<PlayerFAB> {
  bool _showSlider = false;
  Timer? _timer;
  double sliderPos = 0;
  bool sliderChg = false;

  @override
  void initState() {
    super.initState();
  }

  void showSlider() {
    setState(() {
      _showSlider = true;
      startTimer();
    });
  }

  void startTimer() {
    _timer = Timer(
      const Duration(seconds: 3),
      () => setState(() => _showSlider = false),
    );
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  // provides safe value for the slider position during media switching
  double safeSliderPos() =>
      widget.model.duration != null &&
          sliderPos < widget.model.duration!.inSeconds.toDouble()
      ? sliderPos
      : 0.0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, _) {
        final buttonColor = Theme.of(context).colorScheme.onPrimaryContainer;
        return widget.model.processingState == ProcessingState.idle
            ? SizedBox()
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer
                      .withAlpha(200),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: _showSlider
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // current position
                          // Text('start', style: TextStyle(fontSize: 12)),
                          StreamBuilder(
                            stream: widget.model.positionStream.distinct(
                              (prev, next) => prev.inSeconds == next.inSeconds,
                            ),
                            builder: (context, snapshot) => Text(
                              secsToHhMmSs(snapshot.data?.inSeconds),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          // slider
                          SizedBox(
                            height: 56,
                            width: 200,
                            child: StreamBuilder(
                              stream: widget.model.positionStream.distinct(
                                (prev, next) =>
                                    prev.inSeconds == next.inSeconds,
                              ),
                              builder:
                                  (context, AsyncSnapshot<Duration> snapshot) {
                                    if (snapshot.hasData &&
                                        sliderChg == false) {
                                      sliderPos = snapshot.data!.inSeconds
                                          .toDouble();
                                    }
                                    return Slider(
                                      value: safeSliderPos(),
                                      max:
                                          widget.model.duration?.inSeconds
                                              .toDouble() ??
                                          100000.0,
                                      divisions:
                                          widget.model.duration?.inSeconds
                                              .toInt() ??
                                          100000,
                                      label: secsToHhMmSs(sliderPos.toInt()),
                                      onChanged: (value) {
                                        setState(() {});
                                        sliderPos = value;
                                      },
                                      onChangeStart: (value) {
                                        sliderChg = true;
                                        cancelTimer();
                                      },
                                      onChangeEnd: (value) {
                                        sliderChg = false;
                                        widget.model.seek(
                                          Duration(seconds: value.toInt()),
                                        );
                                        startTimer();
                                      },
                                    );
                                  },
                            ),
                          ),
                          // media size
                          Text(
                            secsToHhMmSs(
                              widget.model.duration?.inSeconds ?? 3600,
                            ),
                            style: TextStyle(fontSize: 12),
                          ),
                          // Text('end', style: TextStyle(fontSize: 12)),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 0,
                        children: [
                          IconButton(
                            onPressed: showSlider,
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: buttonColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () => widget.model.seekToStart(),
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: buttonColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () => widget.model.forward(-30),
                            icon: Icon(Icons.replay_30_rounded),
                          ),
                          IconButton(
                            onPressed: () => widget.model.playPause(),
                            icon: widget.model.playing
                                ? Icon(Icons.pause_rounded, color: buttonColor)
                                : Icon(
                                    Icons.play_arrow_rounded,
                                    color: buttonColor,
                                  ),
                            iconSize: 36,
                          ),
                          IconButton(
                            onPressed: () => widget.model.forward(30),
                            icon: Icon(
                              Icons.forward_30_rounded,
                              color: buttonColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () => widget.model.seekToEnd(),
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: buttonColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () => widget.model.stop(),
                            icon: Icon(Icons.stop_rounded, color: buttonColor),
                          ),
                        ],
                      ),
              );
      },
    );
  }
}
