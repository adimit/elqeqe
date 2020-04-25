import 'package:flutter/material.dart';
import './storage.dart';
import './widgets/noteLog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // needed for sqflite initialisation
  final storage = await SqfliteStorage.create();
  runApp(MyApp(storage));
}

class MyApp extends StatelessWidget {
  final Storage _database;
  MyApp(this._database);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Elqeqe',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: MyHomePage(_database, title: 'Elqeqe'),
      );
}

