import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rssread/pages/home/player_fab.dart';

import './channel_page.dart';
import './episode_page.dart';
// import './player_page.dart';
import './side_panel.dart';
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

  Future<void> _handleRefresh() async {
    await widget.model.refresh();
    // TODO: check if necessary
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text(appName),
        actions: [
          // TODO: sleep button
        ],
      ),
      // drawer
      drawer: SidePanel(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        notificationPredicate: (notification) {
          if (widget.model.refreshing) {
            return false;
          }
          return notification.depth == 0;
        },
        child: Padding(
          padding: const .symmetric(vertical: 8.0),
          child: <Widget>[
            // episodes: news
            EpisodePage(model: widget.model, isPodcast: false),
            // episodes: podcast
            EpisodePage(model: widget.model, isPodcast: true),
            // channels
            ChannelPage(model: widget.model),
            // // audio player
            // PlayerPage(model: widget.model),
          ][currentPageIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() => currentPageIndex = index);
        },
        selectedIndex: currentPageIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.newspaper_rounded),
            label: 'News',
          ),
          NavigationDestination(icon: Icon(Icons.mic), label: 'Podcasts'),
          NavigationDestination(
            icon: Icon(Icons.subscriptions_rounded),
            label: 'Channels',
          ),
          // NavigationDestination(icon: Icon(Icons.play_circle), label: 'Player'),
        ],
      ),
      floatingActionButton: currentPageIndex == 2
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer
                  .withAlpha(100),
              onPressed: () => context.go('/search'),
              child: const Icon(Icons.add),
            )
          : PlayerFAB(model: widget.model),
      floatingActionButtonLocation: currentPageIndex == 2
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
    );
  }
}
