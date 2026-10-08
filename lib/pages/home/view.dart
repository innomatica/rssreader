import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import './channel_tile.dart';
import './episode_tile.dart';
import './player_page.dart';
import '../../pages/home/model.dart';
import '../../shared/constants.dart';

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
        // title: const Text(appName),
        actions: [
          // article button
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
          // podcast button
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
          // refresh button
          ListenableBuilder(
            listenable: widget.model,
            builder: (context, _) {
              return IconButton(
                icon: Icon(Icons.refresh_rounded),
                onPressed: widget.model.refreshing
                    ? null
                    : () async => await widget.model.refresh(),
              );
            },
          ),
        ],
      ),
      // drawer
      drawer: Drawer(
        child: ListView(
          padding: .zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // app name
                  Text(
                    appName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'free and open-source',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      // fontWeight: FontWeight.w600,
                    ),
                  ),
                  // app version
                  Text(
                    appVersion,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // source repository
            ListTile(
              // leading: const Icon(Icons.code_rounded),
              title: const Text('Source Repository'),
              onTap: () => launchUrl(Uri.parse(sourceRepository)),
            ),
            // privacy policy
            ListTile(
              // leading: const Icon(Icons.list_rounded),
              title: const Text('Privacy Policy'),
              onTap: () => launchUrl(Uri.parse(privacyPolicy)),
            ),
            // privacy policy
            ListTile(
              // leading: const Icon(Icons.play),
              title: const Text('Play Store'),
              onTap: () => launchUrl(Uri.parse(playStore)),
            ),
            // developer website
            ListTile(
              // leading: const Icon(Icons.web_rounded),
              title: const Text('Developer Website'),
              onTap: () => launchUrl(Uri.parse(developerWebsite)),
            ),
            // attributions
            ListTile(
              // leading: const Icon(Icons.web_rounded),
              title: const Text('Attributions'),
              subtitle: Column(
                children: [
                  ListTile(
                    title: const Text('Podcast Index'),
                    onTap: () => launchUrl(Uri.parse(pcIdxSite)),
                  ),
                  ListTile(
                    title: const Text('FlatIcon'),
                    onTap: () => launchUrl(Uri.parse(pcIdxSite)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const .symmetric(vertical: 8.0),
        child: <Widget>[
          // episodes
          ListenableBuilder(
            listenable: widget.model,
            builder: (context, _) {
              print('---------episode recreated----------');
              return ListView.separated(
                key: const PageStorageKey('episode_list_key'),
                separatorBuilder: (context, _) => Padding(
                  padding: const .only(bottom: 8.0, left: 8.0, right: 8.0),
                  child: Divider(indent: 0, endIndent: 0, height: 0),
                ),
                itemCount: widget.model.episodes.length,
                itemBuilder: (context, index) {
                  final episode = widget.model.episodes.elementAt(index);
                  return Dismissible(
                    key: ValueKey<int>(episode.id),
                    direction: DismissDirection.endToStart,
                    background: SizedBox(),
                    secondaryBackground: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.redAccent,
                          size: 30,
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                    onDismissed: (direction) async {
                      await widget.model.hideEpisode(episode, forceStop: true);
                    },
                    child: EpisodeTile(episode: episode, model: widget.model),
                  );
                },
              );
            },
          ),
          // channels
          ListenableBuilder(
            listenable: widget.model,
            builder: (context, _) {
              return SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    alignment: WrapAlignment.center,
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
