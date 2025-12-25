import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';

class DatabaseService {
  FirebaseFirestore get _firestore {
    return FirebaseFirestore.instance;
  }

  FirebaseAuth get _auth {
    return FirebaseAuth.instance;
  }

  CollectionReference get _todosCollection => _firestore.collection('todos');

  String? get _currentUserId => _auth.currentUser?.uid;

  Stream<List<Todo>> get todos {
    final uid = _currentUserId;
    if (uid == null) return Stream.value([]);

    // Get todos owned by user OR shared with user
    return _todosCollection
        .where(
          Filter.or(
            Filter('userId', isEqualTo: uid),
            Filter('sharedWith', arrayContains: uid),
          ),
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Todo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  Future<String> addTodo(
    String title,
    DateTime? dueDate,
    List<String> tags,
  ) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    final docRef = await _todosCollection.add({
      'title': title,
      'isCompleted': false,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'userId': uid,
      'sharedWith': [],
      'tags': tags,
    });
    return docRef.id;
  }

  Future<void> updateTodo(Todo todo) async {
    await _todosCollection.doc(todo.id).update(todo.toMap());
  }

  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }
}
