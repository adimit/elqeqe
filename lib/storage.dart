import 'package:sqflite/sqflite.dart';
import 'dart:async';
import './notes.dart';
import 'package:path/path.dart';

abstract class Storage {
  Future<void> insertNote(NotePartial note);
  Future<void> updateNote(Note note);
  Future<List<Note>> notes();
  Future<void> deleteNote(Note note);
}

class SqfliteStorage extends Storage {
  final Database _database;

  SqfliteStorage._(this._database);

  static Future<SqfliteStorage> create() async {
    final database = await openDatabase(
        join(await getDatabasesPath(), 'elqeqe_database.db'),
        onCreate: (db, version) => db.execute(
            "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, localTimestamp int)"),
        version: 1);
    return SqfliteStorage._(database);
  }

  Future<void> insertNote(NotePartial note) async =>
      await _database.insert('notes', note.toMap());

  Future<void> updateNote(Note note) async => await _database
      .update('notes', note.toMap(), where: "id = ?", whereArgs: [note.id]);

  Future<List<Note>> notes() async {
    final List<Map<String, dynamic>> maps =
        await _database.query('notes', orderBy: 'localTimestamp DESC');
    return List.generate(
        maps.length,
        (i) => Note(
            id: maps[i]['id'],
            text: maps[i]['text'],
            localTimestamp: maps[i]['localTimestamp']));
  }

  Future<void> deleteNote(Note note) async => await _database
      .delete("notes", where: "id = ?", whereArgs: [note.id]);
}
