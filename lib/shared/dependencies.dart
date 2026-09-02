import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart' show SingleChildWidget;

import '../data/repo/feed.dart';
import '../data/service/api/pcindex.dart';
import '../data/service/local/sqflite.dart';
import '../data/service/local/storage.dart';
import '../pages/channel/model.dart';
import '../pages/home/model.dart';
import '../pages/search/model.dart';
import '../pages/webview/model.dart';

List<SingleChildWidget> get providers => [
  Provider(
    create: (context) => FeedRepository(
      dbSrv: DatabaseService(),
      pcIdx: PCIndexService(),
      stSrv: StorageService(),
    ),
  ),
  ChangeNotifierProvider(
    create: (context) =>
        HomeViewModel(feedRepo: context.read<FeedRepository>()),
  ),
  ChangeNotifierProvider(
    create: (context) =>
        SearchViewModel(feedRepo: context.read<FeedRepository>()),
  ),
  ChangeNotifierProvider(
    create: (context) => WebViewModel(feedRepo: context.read<FeedRepository>()),
  ),
  ChangeNotifierProvider(
    create: (context) =>
        ChannelViewModel(feedRepo: context.read<FeedRepository>()),
  ),
];
