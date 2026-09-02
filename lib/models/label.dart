import 'dart:convert';

class Label {
  int? id;
  String title;
  int color;

  Label({this.id, required this.title, required this.color});

  factory Label.fromSqlite(Map<String, Object?> row) {
    return Label(
      id: row['id'] as int?,
      title: row['title'] as String,
      color: row['color'] as int,
    );
  }

  Map<String, Object?> toSqlite() {
    return {'id': id, 'title': title, 'color': color};
  }

  factory Label.fromPrefStr(String dataStr) {
    final data = jsonDecode(dataStr);
    return Label(id: data['id'], title: data['title'], color: data['color']);
  }

  String toPrefStr() {
    return jsonEncode({'id': id, 'title': title, 'color': color});
  }

  @override
  String toString() {
    return toSqlite().toString();
  }
}
