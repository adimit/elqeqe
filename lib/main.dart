import 'dart:async';
import 'dart:math';
import 'package:timeago/timeago.dart' as timeago;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/material.dart';

class Note extends NotePartial {
  final int id;

  Note({this.id, text, localTimestamp})
      : super(text: text, localTimestamp: localTimestamp);

  @override
  Map<String, dynamic> toMap() {
    final map = {'id': id};
    map.addAll(super.toMap());
    return map;
  }
}

class NotePartial {
  final String text;
  final int localTimestamp;

  NotePartial({this.text, this.localTimestamp});

  Map<String, dynamic> toMap() =>
      {'text': text, 'localTimestamp': localTimestamp};
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openDatabase(
      join(await getDatabasesPath(), 'elqeqe_database.db'),
      onCreate: (db, version) => db.execute(
          "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, localTimestamp int)"),
      version: 1);
  runApp(MyApp(database: database));
}

class EditNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: Center(child: Text('hello')));
}

class MyApp extends StatelessWidget {
  final Database database;
  MyApp({this.database});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page', database: database),
      );
}

class MyHomePage extends StatefulWidget {
  final Database database;
  MyHomePage({Key key, this.title, this.database}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(database: database);
}

Route _createRoute() => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EditNote(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final begin = Offset(0.0, 1.0);
      final end = Offset.zero;
      final curve = Curves.ease;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    });

class _MyHomePageState extends State<MyHomePage> {
  List<Note> currentNotes = [];
  final Database database;
  final Random random = Random();
  _MyHomePageState({this.database});

  Future<void> _insertNote(NotePartial note) async =>
      await database.insert('notes', note.toMap());

  Future<List<Note>> _notes() async {
    final List<Map<String, dynamic>> maps = await database.query('notes');
    return List.generate(
        maps.length,
        (i) => Note(
            id: maps[i]['id'],
            text: maps[i]['text'],
            localTimestamp: maps[i]['localTimestamp']));
  }

  Future<void> _replayState() async {
    final notes = await _notes();
    setState(() => currentNotes = notes);
  }

  Future<void> _deleteNote(Note note) async =>
      await database.delete("notes", where: "id = ?", whereArgs: [note.id]);

  @override
  Widget build(BuildContext context) {
    _replayState();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: currentNotes.length,
          itemBuilder: (context, index) {
            final currentNote = currentNotes[index];
            return Dismissible(
                key: Key(currentNote.id.toString()),
                background: Container(color: Colors.red),
                onDismissed: (direction) async {
                  // can't await the sql call, we need to delete immediately
                  setState(() => currentNotes.removeAt(index));
                  await _deleteNote(currentNote);
                  _replayState();
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "Deleted ${currentNote.id}: ${currentNote.text}")));
                },
                child: ListTile(
                  title: Text(currentNotes[index].text),
                  trailing: Text(timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          currentNotes[index].localTimestamp))),
                ));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(_createRoute());
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
