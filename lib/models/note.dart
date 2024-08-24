class Note {
  int id;
  String title;
  String description;
  String date;
  int priority;

  Note({
    this.id = 0, // Default value for new notes
    this.title = '',
    this.description = '',
    this.date = '',
    this.priority = 2, // Default priority
  });

  // Convert a note object into map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (id != 0) {
      map['id'] = id;
    }
    map['title'] = title;
    map['description'] = description;
    map['date'] = date;
    map['priority'] = priority;
    return map;
  }

  // Extract a Note object from a Map object
  Note.fromMapObject(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        description = map['description'],
        date = map['date'],
        priority = map['priority'];
}
