import 'package:flutter/material.dart';

import '../notes.dart';
import '../time.dart';

class EditNoteForm extends StatefulWidget {
  final void Function(String, DateTime) saveValue;
  final FormatTime formatTime;
  final Note initialNote;

  EditNoteForm(
      {@required this.saveValue, @required this.formatTime, this.initialNote});
  @override
  State<StatefulWidget> createState() =>
      EditNoteState(saveValue: saveValue, formatTime: formatTime, initialNote: initialNote);
}

class EditNoteState extends State<EditNoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _noteEditingController = TextEditingController();
  final _dateEditingController = TextEditingController();
  final void Function(String, DateTime) saveValue;
  final Note initialNote;
  final FormatTime formatTime;
  DateTime _pickedDate;

  EditNoteState(
      {@required this.saveValue, @required this.formatTime, this.initialNote}) {
    if (initialNote?.localTimestamp != null) {
      _pickedDate = initialNote.localTimestamp;
    } else {
      _pickedDate = DateTime.now();
    }
    _dateEditingController.text = formatTime.fuzzyFormat(_pickedDate);
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
              onTap: () async {
                final initialTimeOfDay = TimeOfDay(
                    hour: _pickedDate.hour, minute: _pickedDate.minute);
                final timeOfDay = (await showTimePicker(
                        context: context, initialTime: initialTimeOfDay)) ??
                    initialTimeOfDay;
                setState(() {
                  _pickedDate = DateTime(_pickedDate.year, _pickedDate.month,
                      _pickedDate.day, timeOfDay.hour, timeOfDay.minute);
                  _dateEditingController.text = formatTime.fuzzyFormat(_pickedDate);
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
