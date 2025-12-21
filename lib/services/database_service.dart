import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';
import '../models/person_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _todosCollection => _firestore.collection('todos');
  CollectionReference get _peopleCollection => _firestore.collection('people');

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

  Stream<List<Person>> get people {
    final uid = _currentUserId;
    if (uid == null) return Stream.value([]);

    return _peopleCollection.where('userId', isEqualTo: uid).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Person.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<String> addTodo(String title, DateTime? dueDate) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    final docRef = await _todosCollection.add({
      'title': title,
      'isCompleted': false,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'userId': uid,
      'sharedWith': [],
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
    final uid = _currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    final docRef = await _peopleCollection.add({
      'username': username,
      'displayName': displayName,
      'userId': uid,
    });
    return docRef.id;
  }

  Future<void> deletePerson(String id) async {
    await _peopleCollection.doc(id).delete();
  }
}
