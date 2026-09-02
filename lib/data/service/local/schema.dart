const dbName = 'rssread.db';
const dbVersion = 1;

const List<Map<String, dynamic>> dbMigration = [
  {
    "version": 1,
    "scripts": [
      createEpisodes,
      createChannels,
      createLabels,
      createChannelLabel,
      ...insertLabels,
    ],
  },
];

const pragmaFgKey = "PRAGMA foreign_keys = ON;";

// version 1 scripts
const createEpisodes = '''CREATE TABLE episodes (
  id INTEGER PRIMARY KEY,
  guid TEXT NOT NULL UNIQUE,
  title TEXT,
  subtitle TEXT,
  author TEXT,
  description TEXT,
  language TEXT,
  categories TEXT,
  keywords TEXT,
  updated TIMESTAMP,
  published TIMESTAMP,
  link TEXT,
  media_url TEXT,
  media_type TEXT,
  media_size INTEGER,
  media_duration INTEGER,
  media_seek_pos INTEGER,
  image_url TEXT,
  extras TEXT,
  channel_id INTEGER NOT NULL,
  downloaded INTEGER,
  hidden INTEGER,
  liked INTEGER,
  FOREIGN KEY (channel_id)
    REFERENCES channels (id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);''';

const createChannels = '''CREATE TABLE channels (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  url TEXT NOT NULL UNIQUE,
  title TEXT,
  subtitle TEXT,
  author TEXT,
  categories TEXT,
  description TEXT,
  language TEXT,
  link TEXT,
  updated TIMESTAMP,
  published TIMESTAMP,
  checked TIMESTAMP,
  period INTEGER,
  image_url TEXT,
  is_podcast INTEGER,
  has_content INTEGER,
  extras TEXT
);''';

const createLabels = '''CREATE TABLE labels (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL UNIQUE,
  color INTEGER NOT NULL DEFAULT 0
);''';

const createChannelLabel = '''CREATE TABLE channel_label (
  channel_id INTEGER NOT NULL,
  label_id INTEGER NOT NULL,
  FOREIGN KEY(channel_id) REFERENCES channels (id),
  FOREIGN KEY(label_id) REFERENCES labels (id),
  UNIQUE (channel_id, label_id)
);''';

// const createTablesV1 = [
//   createEpisodes,
//   createChannels,
//   createLabels,
//   createChannelLabel,
// ];

const insertLabels = [
  "INSERT INTO labels (title, color) VALUES ('Business', 1);",
  "INSERT INTO labels (title, color) VALUES ('Culture', 2);",
  "INSERT INTO labels (title, color) VALUES ('Health', 3);",
  "INSERT INTO labels (title, color) VALUES ('Lifestyle', 4);",
  "INSERT INTO labels (title, color) VALUES ('Local', 5);",
  "INSERT INTO labels (title, color) VALUES ('Opinion', 6);",
  "INSERT INTO labels (title, color) VALUES ('Politics', 7);",
  "INSERT INTO labels (title, color) VALUES ('Science', 8);",
  "INSERT INTO labels (title, color) VALUES ('Sports', 9);",
  "INSERT INTO labels (title, color) VALUES ('Technology', 10);",
  "INSERT INTO labels (title, color) VALUES ('Top Stories', 11);",
  "INSERT INTO labels (title, color) VALUES ('World', 12);",
];
