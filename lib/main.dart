import 'dart:async';
import 'dart:math';
import 'package:timeago/timeago.dart' as timeago;

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/material.dart';

class Note extends NotePartial {
  final int id;

  Note({this.id, text, localTimestamp})
      : super(text: text, localTimestamp: localTimestamp);

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {'id': id};
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

class EditNoteForm extends StatefulWidget {
  final void Function(String, DateTime) saveValue;
  final Note initialNote;

  EditNoteForm({@required this.saveValue, this.initialNote});
  @override
  State<StatefulWidget> createState() =>
      EditNoteState(saveValue: saveValue, initialNote: initialNote);
}

class EditNoteState extends State<EditNoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _noteEditingController = TextEditingController();
  var _pickedDate;
  final _dateEditingController = TextEditingController();
  final void Function(String, DateTime) saveValue;
  final Note initialNote;

  EditNoteState({@required this.saveValue, this.initialNote}) {
    if (initialNote?.localTimestamp != null) {
      _pickedDate =
          DateTime.fromMillisecondsSinceEpoch(initialNote.localTimestamp);
    } else {
      _pickedDate = DateTime.now();
    }
    _dateEditingController.text = timeago.format(_pickedDate);
    _noteEditingController.text = initialNote?.text ?? "";
  }

  @override
  void dispose() {
    _noteEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              TextFormField(
                controller: _noteEditingController,
                autofocus: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateEditingController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
                onTap: () {
                  DatePicker.showDateTimePicker(context,
                      currentTime: _pickedDate, onConfirm: (date) {
                    setState(() => _pickedDate = date);
                    _dateEditingController.text = timeago.format(date);
                  });
                },
              ),
              RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      saveValue(_noteEditingController.text, _pickedDate);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Submit'))
            ])));
}

class MyApp extends StatelessWidget {
  final Database database;
  MyApp({this.database});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Elqeqe',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: MyHomePage(title: 'Elqeqe', database: database),
      );
}

class MyHomePage extends StatefulWidget {
  final Database database;
  MyHomePage({Key key, this.title, this.database}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(database: database);
}

Route _createRoute(
        {@required void Function(String, DateTime) saveValue,
        initialNote: Note}) =>
    PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditNoteForm(saveValue: saveValue, initialNote: initialNote),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final begin = Offset(0.0, 1.0);
          final end = Offset.zero;
          final curve = Curves.ease;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
              position: animation.drive(tween), child: child);
        });

class _MyHomePageState extends State<MyHomePage> {
  List<Note> currentNotes = [];
  final Database database;
  final Random random = Random();
  _MyHomePageState({this.database});

  Future<void> _insertNote(NotePartial note) async =>
      await database.insert('notes', note.toMap());

  Future<void> _updateNote(Note note) async => await database
      .update('notes', note.toMap(), where: "id = ?", whereArgs: [note.id]);

  Future<List<Note>> _notes() async {
    final List<Map<String, dynamic>> maps =
        await database.query('notes', orderBy: 'localTimestamp DESC');
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
                  onTap: () {
                    Navigator.of(context).push(_createRoute(
                        saveValue: (textValue, date) async {
                          await _updateNote(Note(
                              id: currentNote.id,
                              text: textValue,
                              localTimestamp: date.millisecondsSinceEpoch
                          ));
                          _replayState();
                        },
                        initialNote: currentNote));
                  },
                  title: Text(currentNotes[index].text),
                  trailing: Text(timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          currentNotes[index].localTimestamp))),
                ));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(_createRoute(
              saveValue: (textValue, date) async {
                await _insertNote(NotePartial(
                    text: textValue,
                    localTimestamp: date.millisecondsSinceEpoch));
                _replayState();
              },
              initialNote: null));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
