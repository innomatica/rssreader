import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:rssread/models/pcindex.dart';
import 'package:rssread/shared/constants.dart';

import '../../models/feed.dart';
import './model.dart';

class SearchView extends StatefulWidget {
  final SearchViewModel model;
  final Feed? feed;
  const new({super.key, required this.model, this.feed});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _log = Logger('SearchView');
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // show bottom modal sheet if channel data is given
    if (widget.feed != null) {
      _showChannelModal(widget.feed!);
    }
    // subscribe to model
    widget.model.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    widget.model.removeListener(_onViewModelChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // show bottom modal sheet if channel data is given
    // if (widget.feed != null && oldWidget.feed == null) {
    if (widget.feed != null && oldWidget.feed == null) {
      _showChannelModal(widget.feed!);
    }
  }

  void _onViewModelChange() {
    if (widget.model.snackMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(widget.model.snackMessage)));
      widget.model.clearSnackMessage();
    }
  }

  void _showChannelModal(Feed feed) {
    // Wait for the widget tree to finish building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          _log.fine(feed);
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const .all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      // title
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Channel Title'),
                        initialValue: feed.channel.title ?? '',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter channel title';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() => feed.channel.title = value);
                        },
                      ),
                      // author
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Author'),
                        initialValue: feed.channel.author ?? 'unknown',
                        onChanged: (value) {
                          setState(() => feed.channel.author = value);
                        },
                      ),
                      // categories
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Categories'),
                        initialValue: feed.channel.categories ?? 'unknown',
                        onChanged: (value) {
                          setState(() => feed.channel.categories = value);
                        },
                      ),
                      // last update
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Last update'),
                        initialValue: feed.channel.updated.toString(),
                        readOnly: true,
                      ),
                      // podcast switch
                      SwitchListTile(
                        title: const Text('Podcast'),
                        value: feed.channel.isPodcast ?? false,
                        onChanged: (bool value) {
                          setState(() => feed.channel.isPodcast = value);
                        },
                      ),
                      // subscribe button
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          FilledButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                widget.model.subscribe(feed);
                                Navigator.pop(context);
                              }
                            },
                            child: Text('Subscribe'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    String keywords = '';
    return Scaffold(
      appBar: AppBar(
        // back
        leading: IconButton(
          onPressed: () => context.go("/"),
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),
        title: Text("Search RSS Channel"),
      ),
      body: SingleChildScrollView(
        child: ExpansionPanelList.radio(
          children: [
            // podcast index search
            ExpansionPanelRadio(
              value: 0,
              headerBuilder: (context, isExpanded) {
                return ListTile(title: Text('PodcastIndex Search'));
              },
              body: Padding(
                padding: .only(left: 16, right: 16, bottom: 8),
                child: Row(
                  children: [
                    // text field
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(label: Text('keywords')),
                        onChanged: (value) => keywords = value,
                      ),
                    ),
                    // menu button
                    MenuAnchor(
                      builder: (context, controller, child) {
                        return IconButton.filledTonal(
                          icon: Icon(Icons.search_rounded),
                          onPressed: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                        );
                      },
                      menuChildren: [
                        MenuItemButton(
                          onPressed: () => widget.model.pciSearch(
                            PCIndexSearch.byTerm,
                            keywords,
                          ),
                          child: Text('By Term'),
                        ),
                        MenuItemButton(
                          onPressed: () => widget.model.pciSearch(
                            PCIndexSearch.byTitle,
                            keywords,
                          ),
                          child: Text('By Title'),
                        ),
                        MenuItemButton(
                          onPressed: () => widget.model.pciSearch(
                            PCIndexSearch.byCategories,
                            keywords,
                          ),
                          child: Text('By Category'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // popular rss feed directories
            ExpansionPanelRadio(
              value: 1,
              headerBuilder: (context, isExpanded) {
                return ListTile(title: Text('RSS Directories'));
              },
              body: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rssDirectories
                      .map(
                        (e) => TextButton(
                          onPressed: () {
                            context.go(
                              '/search/webview/${Uri.encodeComponent(e["url"]!)}',
                            );
                          },
                          child: Text(e["title"]!),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            // search engines
            ExpansionPanelRadio(
              value: 2,
              headerBuilder: (context, isExpanded) {
                return ListTile(title: Text('Search Engines'));
              },
              body: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: searchEngines
                      .map(
                        (e) => TextButton(
                          onPressed: () {
                            context.go(
                              '/search/webview/${Uri.encodeComponent(e["url"]!)}',
                            );
                          },
                          child: Text(e["title"]!),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            // manual entry
            ExpansionPanelRadio(
              value: 3,
              headerBuilder: (context, isExpanded) {
                return ListTile(title: Text('Manual Entry'));
              },
              body: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(label: Text('feed url')),
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: FilledButton.tonal(
                        onPressed: () async {
                          final feed = await widget.model.fetch(
                            _controller.text,
                          );
                          if (feed != null) {
                            _showChannelModal(feed);
                          }
                        },
                        child: Text('register channel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
