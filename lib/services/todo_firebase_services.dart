import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krp/services/local_notifications_services.dart';

class TodoFirebaseServices {
  final _todoCollection = FirebaseFirestore.instance.collection("todos");

  Stream<QuerySnapshot> getQuote() async* {
    yield* _todoCollection.snapshots();
  }

  Future<void> updateTodoStatus(String id, bool isDone) async {
    await _todoCollection.doc(id).update({'isDone': isDone});
  }

  Future<void> addTodo(String title, DateTime time) async {
    DocumentReference docRef = await _todoCollection.add({
      'title': title,
      'time': Timestamp.fromDate(time),
      'isDone': false,
    });

    // Schedule a notification for the todo
    await LocalNotificationsService.scheduleTodoNotification(
      docRef.id,
      title,
      time,
    );
  }

  Future<void> updateTodo(String id, String title, DateTime time) async {
    await _todoCollection.doc(id).update({
      'title': title,
      'time': Timestamp.fromDate(time),
    });

    // Reschedule the notification for the updated todo
    await LocalNotificationsService.scheduleTodoNotification(
      id,
      title,
      time,
    );
  }

  Future<void> deleteTodo(String id) async {
    await _todoCollection.doc(id).delete();

    // Cancel the notification for the deleted todo
    await LocalNotificationsService.cancelTodoNotification(id);
  }
}
