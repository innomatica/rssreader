import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './channel_tile.dart';
import './episode_tile.dart';
import './player_page.dart';
import '../../pages/home/model.dart';

class HomeView extends StatefulWidget {
  final HomeViewModel model;

  const new({super.key, required this.model});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // subscribe to model
    widget.model.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    widget.model.removeListener(_onViewModelChange);
    super.dispose();
  }

  void _onViewModelChange() {
    if (widget.model.snackMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(widget.model.snackMessage)));
      // need to clear message not to trigger again
      widget.model.clearSnackMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    const selectedStyle = TextStyle(
      color: Colors.white,
      shadows: [
        Shadow(blurRadius: 10.0, color: Colors.cyan, offset: Offset(0, 0)),
        Shadow(
          blurRadius: 20.0,
          color: Colors.cyanAccent,
          offset: Offset(0, 0),
        ),
        Shadow(blurRadius: 30.0, color: Colors.blue, offset: Offset(0, 0)),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("RSS Reader"),
        actions: [
          ListenableBuilder(
            listenable: widget.model,
            builder: (context, _) {
              return TextButton(
                onPressed: () => widget.model.selectEpisodeType('article'),
                child: Text(
                  'article',
                  style: widget.model.episodeType == 'article'
                      ? selectedStyle
                      : null,
                ),
              );
            },
          ),
          ListenableBuilder(
            listenable: widget.model,
            builder: (context, _) {
              return TextButton(
                onPressed: () => widget.model.selectEpisodeType('podcast'),
                child: Text(
                  'podcast',
                  style: widget.model.episodeType == 'podcast'
                      ? selectedStyle
                      : null,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () => widget.model.refreshEpisodes(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: <Widget>[
          // episodes
          ListenableBuilder(
            listenable: widget.model,
            builder: (context, _) {
              return ListView.separated(
                key: const PageStorageKey('episode_list_key'),
                separatorBuilder: (context, _) => Padding(
                  padding: const .only(bottom: 8.0, left: 8.0, right: 8.0),
                  child: Divider(indent: 0, endIndent: 0, height: 0),
                ),
                itemCount: widget.model.episodes.length,
                itemBuilder: (context, index) {
                  return EpisodeTile(
                    episode: widget.model.episodes.elementAt(index),
                    model: widget.model,
                  );
                },
              );
            },
          ),
          // channels
          ListenableBuilder(
            listenable: widget.model,
            builder: (context, _) {
              return Center(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    // alignment: WrapAlignment.center,
                    children: widget.model.channels
                        .map((e) => ChannelTile(channel: e))
                        .toList(),
                  ),
                ),
              );
            },
          ),
          // audio player
          PlayerPage(model: widget.model),
        ][currentPageIndex],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() => currentPageIndex = index);
        },
        selectedIndex: currentPageIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Episodes',
          ),
          NavigationDestination(
            icon: Icon(Icons.subscriptions_rounded),
            label: 'Channels',
          ),
          NavigationDestination(icon: Icon(Icons.play_circle), label: 'Player'),
        ],
      ),
      floatingActionButton: currentPageIndex == 1
          ? FloatingActionButton(
              onPressed: () => context.go('/search'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
