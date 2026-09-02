import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import './schema.dart';

class DatabaseService {
  Database? _db;
  final _log = Logger('DatabaseService');

  Future<Database> getDatabase() async {
    return _db ??
        await openDatabase(
          dbName,
          version: dbVersion,
          onConfigure: (db) => db.execute(pragmaFgKey),
          onCreate: (db, version) {
            _log.info('create database:$db, $version');
            for (int i = 1; i <= version; i++) {
              try {
                final item = dbMigration.firstWhere((e) => e["version"] == i);
                for (final sql in item["scripts"]) {
                  _log.fine({"version": i, "sql": sql});
                  db.execute(sql);
                }
              } on Exception catch (e) {
                _log.severe(e.toString());
                rethrow;
              }
            }
          },
          onUpgrade: (db, oldVersion, newVersion) {
            _log.info('upgrade database:$db from $oldVersion to $newVersion');
            for (int i = oldVersion + 1; i <= newVersion; i++) {
              try {
                final item = dbMigration.firstWhere((e) => e["version"] == i);
                for (String sql in item["scripts"]) {
                  _log.fine({"version": i, "sql": sql});
                  db.execute(sql);
                }
              } on Exception catch (e) {
                _log.severe(e.toString());
                rethrow;
              }
            }
          },
        );
  }

  Future<List<Map<String, Object?>>> queryAll(
    String sql, [
    List<Object?>? args,
  ]) async {
    try {
      final db = await getDatabase();
      return await db.rawQuery(sql, args);
    } on Exception catch (e) {
      _log.info(e.toString());
      rethrow;
    }
  }

  Future<Map<String, Object?>?> query(String sql, [List<Object?>? args]) async {
    try {
      final db = await getDatabase();
      final res = await db.rawQuery(sql, args);
      return res.isNotEmpty ? res.first : null;
    } on Exception catch (e) {
      _log.info(e.toString());
      rethrow;
    }
  }

  Future<int> insert(String sql, [List<Object?>? args]) async {
    try {
      final db = await getDatabase();
      return await db.rawInsert(sql, args);
    } on Exception catch (e) {
      _log.info(e.toString());
      rethrow;
    }
  }

  Future<int> update(String sql, [List<Object?>? args]) async {
    try {
      final db = await getDatabase();
      return await db.rawUpdate(sql, args);
    } on Exception catch (e) {
      _log.info(e.toString());
      rethrow;
    }
  }

  Future<int> delete(String sql, [List<Object?>? args]) async {
    try {
      final db = await getDatabase();
      return await db.rawDelete(sql, args);
    } on Exception catch (e) {
      _log.info(e.toString());
      rethrow;
    }
  }
}
