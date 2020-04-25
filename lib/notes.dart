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
