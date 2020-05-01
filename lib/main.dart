import 'package:flutter/material.dart';
import './storage.dart';
import './time.dart';
import './widgets/noteLog.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // needed for sqflite initialisation
  final storage = await SqfliteStorage.create();
  final formatTime = TimeAgoFormatTime();
  runApp(ElqeqeApp(storage, formatTime));
}

class ElqeqeApp extends StatelessWidget {
  final Storage _database;
  final FormatTime _formatTime;

  ElqeqeApp(this._database, this._formatTime);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Elqeqe',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: NoteLog(_database, _formatTime, title: 'Elqeqe'),
      );
}
