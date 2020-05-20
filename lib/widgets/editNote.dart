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
  State<StatefulWidget> createState() => EditNoteState(
      saveValue: saveValue, formatTime: formatTime, initialNote: initialNote);
}

class EditNoteState extends State<EditNoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _noteEditingController = TextEditingController();
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
            DatePicker((dateTime) {
              setState(() {
                _pickedDate = dateTime;
              });
            }, _pickedDate),
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

class DatePicker extends StatelessWidget {
  final void Function(DateTime) _setDateTime;
  final DateTime _pickedDate;
  final DateTime _now;

  const DatePicker._(this._setDateTime, this._pickedDate, this._now, {Key key})
      : super(key: key);

  DatePicker(setDateTime, pickedDate, {Key key})
      : this._(setDateTime, pickedDate, DateTime.now(), key: key);

  List<bool> _getSelected() {
    final duration = _now.difference(_pickedDate).inMinutes;
    if (duration < 5) return [true, false, false, false, false, false];
    if (duration < 10) return [false, true, false, false, false, false];
    if (duration < 15) return [false, false, true, false, false, false];
    if (duration < 30) return [false, false, false, true, false, false];
    if (duration == 30) return [false, false, false, false, true, false];
    return [false, false, false, false, false, true];
  }

  @override
  Widget build(BuildContext context) => Center(
          child: ToggleButtons(
        children: [
          Text('now'),
          Text('5m'),
          Text('10m'),
          Text('15m'),
          Text('30m'),
          Icon(Icons.timer)
        ],
        isSelected: _getSelected(),
        onPressed: (int index) async {
          final getChosenTime = () async {
            switch (index) {
              case 0:
                return _now;
              case 1:
                return _now.subtract(Duration(minutes: 5));
              case 2:
                return _now.subtract(Duration(minutes: 10));
              case 3:
                return _now.subtract(Duration(minutes: 15));
              case 4:
                return _now.subtract(Duration(minutes: 30));
              default:
                final initialTimeOfDay = TimeOfDay(
                    hour: _pickedDate.hour, minute: _pickedDate.minute);
                final timeOfDay = (await showTimePicker(
                        context: context, initialTime: initialTimeOfDay)) ??
                    initialTimeOfDay;
                return DateTime(_pickedDate.year, _pickedDate.month,
                    _pickedDate.day, timeOfDay.hour, timeOfDay.minute);
            }
          };
          final chosenTime = await getChosenTime();
          _setDateTime(chosenTime);
        },
      ));
}
