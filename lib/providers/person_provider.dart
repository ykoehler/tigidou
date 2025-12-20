import 'package:flutter/foundation.dart';
import '../models/person_model.dart';
import '../services/database_service.dart';

class PersonProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  Stream<List<Person>> get people => _databaseService.people;

  Future<void> addPerson(String username, String displayName) async {
    await _databaseService.addPerson(username, displayName);
  }

  Future<void> deletePerson(String id) async {
    await _databaseService.deletePerson(id);
  }
}
