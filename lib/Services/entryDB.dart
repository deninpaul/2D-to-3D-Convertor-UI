import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Data/entry.dart';

class EntryDBProvider {
  EntryDBProvider._();
  String table = "Entry";
  static final EntryDBProvider db = EntryDBProvider._();

  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "$table.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE $table ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "photo TEXT"
          ")");
    });
  }

  newEntry(Entry entry) async {
    final db = await database;
    var res = await db.insert(table, entry.toMap());
    return res;
  }

  getAllEntry() async {
    final db = await database;
    var res = await db.query(
      table,
      orderBy: "id DESC",
    );
    List<Entry> list =
        res.isNotEmpty ? res.map((c) => Entry.fromMap(c)).toList() : [];
    return list;
  }

  getEntry(int id) async {
    final db = await database;
    var res = await db.query(table, where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Entry.fromMap(res.first) : Null;
  }

  updateEntry(Entry entry) async {
    final db = await database;
    var res = await db
        .update(table, entry.toMap(), where: "id = ?", whereArgs: [entry.id]);
    return res;
  }

  deleteEntry(int id) async {
    final db = await database;
    db.delete(table, where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from $table");
  }
}
