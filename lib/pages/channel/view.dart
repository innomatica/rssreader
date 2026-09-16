import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets.dart' show UrlImage;
import './model.dart';

class ChannelView extends StatefulWidget {
  final ChannelViewModel model;
  const new({super.key, required this.model});

  @override
  State<ChannelView> createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView> {
  late final TextEditingController _authorController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _authorController = TextEditingController(text: widget.model.author);
    _imageUrlController = TextEditingController(text: widget.model.imageUrl);
    _categoryController = TextEditingController(text: widget.model.categories);
    widget.model.addListener(_onViewModelChange);
  }

  @override
  void dispose() async {
    _authorController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
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
    if (_authorController.text != widget.model.author) {
      _authorController.text = widget.model.author ?? '';
    }
    if (_imageUrlController.text != widget.model.imageUrl) {
      _imageUrlController.text = widget.model.imageUrl ?? '';
    }
    if (_categoryController.text != widget.model.categories) {
      _categoryController.text = widget.model.categories ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(color: Theme.of(context).colorScheme.primary);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () async {
            // await widget.model.update(_channel);
            if (context.mounted) context.go("/");
          },
        ),
        title: ListenableBuilder(
          listenable: widget.model,
          builder: (context, _) {
            return Text(widget.model.channel?.title ?? '');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // channel image
            ListenableBuilder(
              listenable: widget.model,
              builder: (context, _) {
                return UrlImage(
                  widget.model.channel?.imageUrl,
                  height: 100.0,
                  width: double.maxFinite,
                );
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // author
                Focus(
                  child: TextFormField(
                    controller: _authorController,
                    decoration: InputDecoration(
                      label: Text('author', style: labelStyle),
                      border: InputBorder.none,
                    ),
                  ),
                  onFocusChange: (value) {
                    if (!value) {
                      widget.model.update({'author': _authorController.text});
                    }
                  },
                ),
                // image url
                Focus(
                  child: TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      label: Text('image url', style: labelStyle),
                      border: InputBorder.none,
                    ),
                  ),
                  onFocusChange: (value) {
                    if (!value) {
                      widget.model.update({
                        'image_url': _imageUrlController.text,
                      });
                    }
                  },
                ),
                // categories
                Focus(
                  child: TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      label: Text('categories', style: labelStyle),
                      border: InputBorder.none,
                    ),
                  ),
                  onFocusChange: (value) {
                    if (!value) {
                      widget.model.update({
                        'categories': _categoryController.text,
                      });
                    }
                  },
                ),
                // podcast
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('podcast channel', style: labelStyle),
                    ListenableBuilder(
                      listenable: widget.model,
                      builder: (context, _) {
                        return Switch(
                          value: widget.model.isPodcast,
                          onChanged: (value) {
                            widget.model.update({'is_podcast': value});
                          },
                        );
                      },
                    ),
                  ],
                ),
                // has content
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('episode has content', style: labelStyle),
                    ListenableBuilder(
                      listenable: widget.model,
                      builder: (context, _) {
                        return Switch(
                          value: widget.model.hasContent,
                          onChanged: (value) {
                            widget.model.update({'has_content': value});
                          },
                        );
                      },
                    ),
                  ],
                ),
                // space
                SizedBox(height: 32.0),
                // cancel the channel
                Center(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => widget.model.unsubscribe(),
                    child: Text('Cancel this channel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
