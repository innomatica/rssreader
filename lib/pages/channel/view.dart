import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/channel.dart';
import 'model.dart';

class ChannelView extends StatefulWidget {
  final ChannelViewModel model;
  // final Channel? channel;
  // const new({super.key, required this.model, required this.channel});
  const new({super.key, required this.model});

  @override
  State<ChannelView> createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView> {
  @override
  void initState() {
    super.initState();
    widget.model.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    widget.model.removeListener(_onViewModelChange);
    super.dispose();
  }

  void _onViewModelChange() {
    if (widget.model.snackMessage.isNotEmpty) {
      if (widget.model.snackMessage.contains('deleted')) {
        widget.model.clearSnackMessage();
        context.go('/');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(widget.model.snackMessage)));
        widget.model.clearSnackMessage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(color: Theme.of(context).colorScheme.primary);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go("/"),
        ),
        title: ListenableBuilder(
          listenable: widget.model,
          builder: (context, _) {
            return Text(widget.model.channel?.title ?? '');
          },
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.model,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: widget.model.channel != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(10.8),
                        child: Image.file(
                          File(widget.model.channel!.imagePath),
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // subtitle
                            TextFormField(
                              initialValue:
                                  widget.model.channel!.subtitle ?? '',
                              maxLines: null,
                              decoration: InputDecoration(
                                label: Text('subtitle', style: labelStyle),
                                border: InputBorder.none,
                              ),
                            ),
                            // author
                            TextFormField(
                              initialValue: widget.model.channel!.author ?? '',
                              maxLines: null,
                              decoration: InputDecoration(
                                label: Text('author', style: labelStyle),
                                border: InputBorder.none,
                              ),
                            ),
                            // description
                            TextFormField(
                              initialValue:
                                  widget.model.channel!.description ?? '',
                              maxLines: null,
                              decoration: InputDecoration(
                                label: Text('description', style: labelStyle),
                                border: InputBorder.none,
                              ),
                            ),
                            // language
                            TextFormField(
                              readOnly: true,
                              initialValue:
                                  widget.model.channel!.language ?? '',
                              maxLines: null,
                              decoration: InputDecoration(
                                label: Text('language', style: labelStyle),
                                border: InputBorder.none,
                              ),
                            ),
                            // categories
                            TextFormField(
                              initialValue:
                                  widget.model.channel!.categories ?? '',
                              maxLines: null,
                              decoration: InputDecoration(
                                label: Text('categories', style: labelStyle),
                                border: InputBorder.none,
                              ),
                            ),
                            // categories
                            TextFormField(
                              readOnly: true,
                              initialValue:
                                  (widget.model.channel!.published ??
                                          widget.model.channel!.updated)
                                      .toString(),
                              maxLines: null,
                              decoration: InputDecoration(
                                label: Text('published', style: labelStyle),
                                border: InputBorder.none,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('podcast', style: labelStyle),
                                Switch(value: true, onChanged: (bool value) {}),
                              ],
                            ),
                            SizedBox(height: 32.0),
                            Center(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .error,
                                ),
                                onPressed: () => widget.model.unsubscribe(
                                  widget.model.channel!.id,
                                ),
                                child: Text('Cancel this channel'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(child: Text('Invalid channel data')),
          );
        },
      ),
    );
  }
}
