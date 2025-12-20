import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';
import '../models/person_model.dart';

class DatabaseService {
  final CollectionReference _todosCollection =
      FirebaseFirestore.instance.collection('todos');

  final CollectionReference _peopleCollection =
      FirebaseFirestore.instance.collection('people');

  Stream<List<Todo>> get todos {
    return _todosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Todo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<Person>> get people {
    return _peopleCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Person.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<String> addTodo(String title, DateTime? dueDate) async {
    final docRef = await _todosCollection.add({
      'title': title,
      'isCompleted': false,
      'dueDate': dueDate?.millisecondsSinceEpoch,
    });
    return docRef.id;
  }

  Future<void> updateTodo(Todo todo) async {
    await _todosCollection.doc(todo.id).update(todo.toMap());
  }

  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }

  Future<String> addPerson(String username, String displayName) async {
    final docRef = await _peopleCollection.add({
      'username': username,
      'displayName': displayName,
    });
    return docRef.id;
  }

  Future<void> deletePerson(String id) async {
    await _peopleCollection.doc(id).delete();
  }
}
