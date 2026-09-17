import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:rssread/models/pcindex.dart';
import 'package:rssread/shared/constants.dart';

import '../../models/channel.dart';
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
  // final _controller = TextEditingController();

  String _keywords = '';
  String _feedUrl = '';
  final List<Channel> _channels = [];

  @override
  void initState() {
    super.initState();
    // show bottom modal sheet if channel data is given
    if (widget.feed != null) {
      _showChannelModal(widget.feed!.channel);
    }
    // subscribe to model
    widget.model.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    widget.model.removeListener(_onViewModelChange);
    // _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // show bottom modal sheet if channel data is given
    // if (widget.feed != null && oldWidget.feed == null) {
    if (widget.feed != null && oldWidget.feed == null) {
      _showChannelModal(widget.feed!.channel);
    }
  }

  void _onViewModelChange() {
    if (widget.model.snackMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(widget.model.snackMessage)));
      widget.model.clearSnackMessage();
    }
  }

  void _showChannelModal(Channel channel) {
    // Wait for the widget tree to finish building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          _log.fine(channel);
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
                        initialValue: channel.title ?? '',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter channel title';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() => channel.title = value);
                        },
                      ),
                      // author
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Author'),
                        initialValue: channel.author ?? 'unknown',
                        onChanged: (value) {
                          setState(() => channel.author = value);
                        },
                      ),
                      // categories
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Categories'),
                        initialValue: channel.categories ?? 'unknown',
                        onChanged: (value) {
                          setState(() => channel.categories = value);
                        },
                      ),
                      // last update
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Last update'),
                        initialValue: channel.updated.toString(),
                        readOnly: true,
                      ),
                      // podcast switch
                      SwitchListTile(
                        title: const Text('Podcast'),
                        value: channel.isPodcast ?? false,
                        onChanged: (bool value) {
                          setState(() => channel.isPodcast = value);
                        },
                      ),
                      // subscribe button
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          FilledButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                widget.model.subscribe(channel);
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
                child: Column(
                  spacing: 8.0,
                  children: [
                    Row(
                      children: [
                        // text field
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              label: Text('keywords'),
                            ),
                            onChanged: (value) => _keywords = value,
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
                              onPressed: () async {
                                final channels = await widget.model.pciSearch(
                                  PCIndexSearch.byTerm,
                                  _keywords,
                                );
                                _channels.clear();
                                _channels.addAll(channels);
                                setState(() {});
                              },
                              child: Text('By Term'),
                            ),
                            MenuItemButton(
                              onPressed: () async {
                                final channels = await widget.model.pciSearch(
                                  PCIndexSearch.byTitle,
                                  _keywords,
                                );
                                _channels.clear();
                                _channels.addAll(channels);
                                setState(() {});
                              },
                              child: Text('By Title'),
                            ),
                            MenuItemButton(
                              onPressed: () async {
                                final channels = await widget.model.pciSearch(
                                  PCIndexSearch.byCategories,
                                  _keywords,
                                );
                                _channels.clear();
                                _channels.addAll(channels);
                                setState(() {});
                              },
                              child: Text('By Category'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _channels.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                              '${_channels[index].title} by ${_channels[index].author}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _showChannelModal(_channels[index]),
                          ),
                        );
                      },
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
              body: Padding(
                padding: .only(left: 20, right: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(label: Text('feed URL')),
                        onChanged: (value) => _feedUrl = value,
                      ),
                    ),
                    IconButton.filledTonal(
                      icon: Icon(Icons.check_rounded),
                      onPressed: () async {
                        if (_feedUrl.isNotEmpty) {
                          final feed = await widget.model.fetch(_feedUrl);
                          if (feed?.channel != null) {
                            _showChannelModal(feed!.channel);
                          }
                        }
                      },
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
