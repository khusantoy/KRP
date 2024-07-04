import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:krp/services/todo_firebase_services.dart';

class TodoController with ChangeNotifier {
  final _todoFirebaseService = TodoFirebaseServices();

  Stream<QuerySnapshot> get list async* {
    yield* _todoFirebaseService.getQuote();
  }

  Future<void> updateTodoStatus(String id, bool isDone) async {
    await _todoFirebaseService.updateTodoStatus(id, isDone);
  }

  Future<void> addTodo(String title, DateTime time) async {
    await _todoFirebaseService.addTodo(title, time);
  }

  Future<void> updateTodo(String id, String title, DateTime time) async {
    await _todoFirebaseService.updateTodo(id, title, time);
  }

  Future<void> deleteTodo(String id) async {
    await _todoFirebaseService.deleteTodo(id);
  }
}
