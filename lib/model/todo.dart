import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String id;
  String title;
  Timestamp time;
  bool isDone;

  Todo({
    required this.id,
    required this.title,
    required this.time,
    required this.isDone,
  });

  factory Todo.fromQuerySnapshot(QueryDocumentSnapshot query) {
    return Todo(
      id: query.id,
      title: query['title'],
      time: query['time'],
      isDone: query['isDone'],
    );
  }
}
