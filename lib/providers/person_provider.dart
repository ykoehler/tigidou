import 'package:flutter/foundation.dart';
import '../models/person_model.dart';
import '../services/database_service.dart';

class PersonProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  Stream<List<Person>> get people => _databaseService.people;

  Future<void> addPerson(String username, String displayName) async {
    try {
      await _databaseService.addPerson(username, displayName);
    } catch (e) {
      if (kDebugMode) {
        print('PersonProvider: Error adding person: $e');
      }
      rethrow;
    }
  }

  Future<void> deletePerson(String id) async {
    try {
      await _databaseService.deletePerson(id);
    } catch (e) {
      if (kDebugMode) {
        print('PersonProvider: Error deleting person: $e');
      }
      rethrow;
    }
  }
}
