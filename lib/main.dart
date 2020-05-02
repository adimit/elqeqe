import 'package:flutter/material.dart';
import './storage.dart';
import './time.dart';
import './widgets/noteLog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          title: 'Elqeqe',
          theme: ThemeData(
            primarySwatch: Colors.orange,
          ),
          home: Intermediary(_database));
}

class Intermediary extends StatelessWidget {
  final Storage _database;

  Intermediary(this._database);

  @override
  Widget build(BuildContext context) =>
      NoteLog(_database, TimeAgoFormatTime(context), title: 'Elqeqe');
}
