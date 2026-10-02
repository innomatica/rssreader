const appName = "RSS Reader";
const appVersion = '0.1.4+5';
const appId = 'ca.innomatic.rssread';

const developerWebsite = 'https://innomatic.ca';
const sourceRepository = 'https://github.com/innomatica/rssreader';
const privacyPolicy = 'https://innomatica.github.io/rssreader/privacy';
const playStore =
    'https://play.google.com/store/apps/details?id=ca.innomatic.rssread';

// podcast index
const pcIdxSite = 'https://podcastindex.org/';
const pcIdxEndpoint = 'https://api.podcastindex.org/api/1.0';
const pcIdxHost = 'api.podcastindex.org';

// sample feeds
const sampleFeeds = 'https://innomatica.github.io/rssreader/sample_feed';

// other urls
const flatIconSite = 'https://www.flaticon.com/';

// asset images
const assetImgMicrophone = 'assets/images/microphone.png';
const assetImgNewspaper = 'assets/images/newspaper.png';
const assetImgPodcaster = 'assets/images/podcaster.png';
const assetImgRssIcon = 'assets/images/rssicon.png';

// retention days
final dataRetentionPeriod = 30;

// application document directory path
late final String appDocPath;

// feed update period
const defaultUpdatePeriod = 1;

// channel thumbnail image file name
const chnImgFname = 'thumbnail';
const defaultNewsChannelImg = assetImgNewspaper;
const defaultCastChannelImg = assetImgMicrophone;
const defaultChannelImg = assetImgMicrophone;
const defaultEpisodeImg = assetImgPodcaster;

// rss finder
const List<Map<String, String>> rssDirectories = [
  // {"title": 'Feedle: Search Feedle Catalog', "url": 'https://feedle.world'},
  {
    "title": 'FeedSpot: RSS Directory',
    "url": 'https://rss.feedspot.com/rss_directory/',
  },
  {
    "title": 'GitHub: awesome-rss-feed',
    "url": 'https://github.com/plenaryapp/awesome-rss-feeds',
  },
  {
    "title": 'Lighthouse Feed Finder',
    "url": 'https://lighthouseapp.io/tools/feed-finder',
  },
  // {"title": 'Open RSS', "url": 'https://openrss.org/'},
  // {"title": "Podnews.net", "url": 'https://podnews.net/podcasts'},
  // {
  //   "title": 'RSS.com: Podcast RSS Feed Finder',
  //   "url": 'https://rss.com/tools/find-my-feed/',
  // },
  // {"title": 'RSS Lookup', "url": 'https://rsslookup.com/'},
  // {"title": 'WP RSS Aggregator', "url": 'https://finder.wprssaggregator.com/'},
];

// search engines
const List<Map<String, String>> searchEngines = [
  {"title": 'Brave Search', "url": 'https://search.brave.com'},
  {"title": 'DuckDuckGo', "url": 'https://duckduckgo.com'},
  {"title": 'Google', "url": 'https://google.com'},
  {"title": 'Microsoft Bing', "url": 'https://bing.com'},
  {"title": 'Yahoo Search', "url": 'https://search.yahoo.com'},
];

const urlDefaultSearchEngine = 'https://search.brave.com';
