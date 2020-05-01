class Note extends NotePartial {
  final int id;

  Note({this.id, String text, DateTime localTimestamp})
      : super(text: text, localTimestamp: localTimestamp);
}

class NotePartial {
  final String text;
  final DateTime localTimestamp;

  NotePartial({this.text, this.localTimestamp});
}
