import 'package:flutter/material.dart';
import './storage.dart';
import './widgets/noteLog.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // needed for sqflite initialisation
  final storage = await SqfliteStorage.create();
  runApp(ElqeqeApp(storage));
}

class ElqeqeApp extends StatelessWidget {
  final Storage _database;
  ElqeqeApp(this._database);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Elqeqe',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: NoteLog(_database, title: 'Elqeqe'),
      );
}
