import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rssread/shared/constants.dart' show urlDefaultSearchEngine;

// import '../models/channel.dart';
import '../models/feed.dart';
import '../pages/channel/model.dart';
import '../pages/channel/view.dart';
import '../pages/home/view.dart';
import '../pages/home/model.dart';
import '../pages/search/model.dart';
import '../pages/search/view.dart';
import '../pages/webview/model.dart';
import '../pages/webview/view.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          HomeView(model: context.read<HomeViewModel>()..load()),
      routes: [
        GoRoute(
          path: '/search',
          builder: (context, state) {
            return SearchView(
              model: context.read<SearchViewModel>(),
              feed: state.extra as Feed?,
            );
          },
          routes: [
            GoRoute(
              path: '/webview/:url',
              builder: (context, state) {
                return WebView(
                  initialUrl: state.pathParameters['url'] != null
                      ? Uri.decodeComponent(state.pathParameters['url']!)
                      : urlDefaultSearchEngine,
                  model: context.read<WebViewModel>(),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/channel/:channelId',
          builder: (context, state) {
            final channelId = int.tryParse(
              state.pathParameters['channelId'] ?? '',
            );
            return ChannelView(
              model: context.read<ChannelViewModel>()..load(channelId),
              // channel: state.extra as Channel?,
            );
          },
        ),
      ],
    ),
  ],
);
