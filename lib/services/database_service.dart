import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../models/person_model.dart';

class DatabaseService {
  FirebaseFirestore get _firestore {
    return FirebaseFirestore.instance;
  }

  FirebaseAuth get _auth {
    return FirebaseAuth.instance;
  }

  CollectionReference get _todosCollection => _firestore.collection('todos');
  CollectionReference get _peopleCollection => _firestore.collection('people');

  String? get _currentUserId => _auth.currentUser?.uid;

  void _logError(String operation, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('DatabaseService Error [$operation]: $error');
      print('Stack trace: $stackTrace');
    }
  }

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
    try {
      final uid = _currentUserId;
      if (uid == null) throw Exception('User not authenticated');

      if (kDebugMode) {
        print('DatabaseService: Adding todo - title: $title, userId: $uid');
      }

      final docRef = await _todosCollection.add({
        'title': title,
        'isCompleted': false,
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'userId': uid,
        'sharedWith': [],
      });

      if (kDebugMode) {
        print('DatabaseService: Todo added successfully with ID: ${docRef.id}');
      }

      return docRef.id;
    } catch (e, stackTrace) {
      _logError('addTodo', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      if (kDebugMode) {
        print('DatabaseService: Updating todo - id: ${todo.id}');
      }

      await _todosCollection.doc(todo.id).update(todo.toMap());

      if (kDebugMode) {
        print('DatabaseService: Todo updated successfully');
      }
    } catch (e, stackTrace) {
      _logError('updateTodo', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      if (kDebugMode) {
        print('DatabaseService: Deleting todo - id: $id');
      }

      await _todosCollection.doc(id).delete();

      if (kDebugMode) {
        print('DatabaseService: Todo deleted successfully');
      }
    } catch (e, stackTrace) {
      _logError('deleteTodo', e, stackTrace);
      rethrow;
    }
  }

  Future<String> addPerson(String username, String displayName) async {
    try {
      final uid = _currentUserId;
      if (uid == null) throw Exception('User not authenticated');

      if (kDebugMode) {
        print('DatabaseService: Adding person - username: $username, displayName: $displayName, userId: $uid');
      }

      final docRef = await _peopleCollection.add({
        'username': username,
        'displayName': displayName,
        'userId': uid,
      });

      if (kDebugMode) {
        print('DatabaseService: Person added successfully with ID: ${docRef.id}');
      }

      return docRef.id;
    } catch (e, stackTrace) {
      _logError('addPerson', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePerson(String id) async {
    try {
      if (kDebugMode) {
        print('DatabaseService: Deleting person - id: $id');
      }

      await _peopleCollection.doc(id).delete();

      if (kDebugMode) {
        print('DatabaseService: Person deleted successfully');
      }
    } catch (e, stackTrace) {
      _logError('deletePerson', e, stackTrace);
      rethrow;
    }
  }
}
