import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'dart:async';
import 'dart:math';
import '../storage.dart';
import '../notes.dart';
import './editNote.dart';

Route _navigateToEditNote(
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

class NoteLog extends StatefulWidget {
  final Storage _storage;
  NoteLog(
    this._storage, {
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  _NoteLogState createState() => _NoteLogState(_storage);
}

class _NoteLogState extends State<NoteLog> {
  List<Note> currentNotes = [];
  final Storage _storage;
  final Random random = Random();
  _NoteLogState(this._storage);

  Future<void> _replayState() async {
    final notes = await _storage.notes();
    setState(() => currentNotes = notes);
  }

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
                  await _storage.deleteNote(currentNote);
                  _replayState();
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                          Expanded(child: Text("Deleted ${currentNote.id}: ${currentNote.text}")),
                          OutlineButton(
                            onPressed: () {
                              _storage.insertNote(currentNote);
                              _replayState();
                            },
                        child: Text("Undo"))
                  ])));
                },
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(_navigateToEditNote(
                        saveValue: (textValue, date) async {
                          await _storage.updateNote(Note(
                              id: currentNote.id,
                              text: textValue,
                              localTimestamp: date.millisecondsSinceEpoch));
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
          Navigator.of(context).push(_navigateToEditNote(
              saveValue: (textValue, date) async {
                await _storage.insertNote(NotePartial(
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
