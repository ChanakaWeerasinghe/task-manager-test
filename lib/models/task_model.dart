class Task {
  int id;
  String title;
  String description;
  DateTime date;
  DateTime date_created;
  String priority;
  int status; // 0 - Incomplete, 1 - Complete

  Task({this.title, this.date,this.date_created, this.priority, this.status, this.description});

  Task.withId({this.id, this.title, this.date,this.date_created, this.priority, this.status, this.description});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date.toIso8601String();
    map['date_created'] = date_created.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    map['description'] = description;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      date_created: DateTime.parse(map['date_created']),
      priority: map['priority'],
      status: map['status'],
      description: map['description'],
    );
  }
}
