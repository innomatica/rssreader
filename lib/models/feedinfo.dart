const curatedFeedFiles = [
  {
    'title': 'Community',
    'url':
        'https://raw.githubusercontent.com/innomatica/rssnews/refs/heads/master/data/feeds/community.json',
  },
  {
    'title': 'Gadgets',
    'url':
        'https://raw.githubusercontent.com/innomatica/rssnews/refs/heads/master/data/feeds/gadgets.json',
  },
  {
    'title': 'Government',
    'url':
        'https://raw.githubusercontent.com/innomatica/rssnews/refs/heads/master/data/feeds/government.json',
  },
  {
    'title': 'Korean',
    'url':
        'https://raw.githubusercontent.com/innomatica/rssnews/refs/heads/master/data/feeds/korean.json',
  },
  {
    'title': 'News',
    'url':
        'https://raw.githubusercontent.com/innomatica/rssnews/refs/heads/master/data/feeds/news.json',
  },
  {
    'title': 'Science',
    'url':
        'https://raw.githubusercontent.com/innomatica/rssnews/refs/heads/master/data/feeds/science.json',
  },
  {
    'title': 'Software',
    'url':
        'https://raw.githubusercontent.com/innomatica/rssnews/refs/heads/master/data/feeds/software.json',
  },
  {
    'title': 'Technology',
    'url':
        'https://raw.githubusercontent.com/innomatica/rssnews/refs/heads/master/data/feeds/technology.json',
  },
];

class FeedInfoItem {
  String title;
  String website;
  String description;
  String language;
  String keywords;
  String feedUrl;
  String favicon;

  FeedInfoItem({
    required this.title,
    required this.website,
    required this.description,
    required this.language,
    required this.keywords,
    required this.feedUrl,
    required this.favicon,
  });

  @override
  String toString() {
    return {
      "title": title,
      "website": website,
      "description": description,
      "language": language,
      "keywords": keywords,
      "feedUrl": feedUrl,
      "favicon": favicon,
    }.toString();
  }
}

class FeedInfo {
  String category;
  List<FeedInfoItem> items;

  FeedInfo({required this.category, required this.items});

  @override
  String toString() {
    return {"category": category, "items": items}.toString();
  }
}
