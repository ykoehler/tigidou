import 'package:flutter_test/flutter_test.dart';
import 'package:tigidou/models/todo_model.dart';
import 'package:tigidou/models/person_model.dart';

void main() {
  group('Data Persistence Tests', () {
    test('Todo model serialization and deserialization', () {
      // Create a todo with all fields
      final now = DateTime.now();
      final todoData = {
        'title': 'Test Todo',
        'isCompleted': false,
        'dueDate': now.millisecondsSinceEpoch,
        'group': 'work',
        'userId': 'user123',
        'sharedWith': ['user456', 'user789'],
      };

      // Test fromMap creates correct object
      final todo = Todo.fromMap(todoData, 'todo123');
      expect(todo.id, 'todo123');
      expect(todo.title, 'Test Todo');
      expect(todo.isCompleted, false);
      expect(todo.dueDate?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(todo.group, 'work');
      expect(todo.userId, 'user123');
      expect(todo.sharedWith, ['user456', 'user789']);

      // Test toMap produces correct data
      final serialized = todo.toMap();
      expect(serialized['title'], 'Test Todo');
      expect(serialized['isCompleted'], false);
      expect(serialized['dueDate'], now.millisecondsSinceEpoch);
      expect(serialized['group'], 'work');
      expect(serialized['userId'], 'user123');
      expect(serialized['sharedWith'], ['user456', 'user789']);

      // Test round-trip (serialize and deserialize)
      final roundTrip = Todo.fromMap(serialized, 'todo123');
      expect(roundTrip.id, todo.id);
      expect(roundTrip.title, todo.title);
      expect(roundTrip.isCompleted, todo.isCompleted);
      expect(roundTrip.dueDate?.millisecondsSinceEpoch, todo.dueDate?.millisecondsSinceEpoch);
      expect(roundTrip.group, todo.group);
      expect(roundTrip.userId, todo.userId);
      expect(roundTrip.sharedWith, todo.sharedWith);
    });

    test('Todo model with minimal fields', () {
      // Test todo without optional fields
      final todoData = {
        'title': 'Minimal Todo',
        'isCompleted': true,
        'userId': 'user123',
      };

      final todo = Todo.fromMap(todoData, 'todo456');
      expect(todo.id, 'todo456');
      expect(todo.title, 'Minimal Todo');
      expect(todo.isCompleted, true);
      expect(todo.dueDate, null);
      expect(todo.group, null);
      expect(todo.userId, 'user123');
      expect(todo.sharedWith, []);

      // Verify serialization handles nulls correctly
      final serialized = todo.toMap();
      expect(serialized['title'], 'Minimal Todo');
      expect(serialized['isCompleted'], true);
      expect(serialized['dueDate'], null);
      expect(serialized['group'], null);
      expect(serialized['userId'], 'user123');
      expect(serialized['sharedWith'], []);
    });

    test('Person model serialization and deserialization', () {
      // Create a person with all fields
      final personData = {
        'username': 'johndoe',
        'displayName': 'John Doe',
        'userId': 'user123',
      };

      // Test fromMap creates correct object
      final person = Person.fromMap(personData, 'person123');
      expect(person.id, 'person123');
      expect(person.username, 'johndoe');
      expect(person.displayName, 'John Doe');
      expect(person.userId, 'user123');

      // Test toMap produces correct data
      final serialized = person.toMap();
      expect(serialized['username'], 'johndoe');
      expect(serialized['displayName'], 'John Doe');
      expect(serialized['userId'], 'user123');

      // Test round-trip
      final roundTrip = Person.fromMap(serialized, 'person123');
      expect(roundTrip.id, person.id);
      expect(roundTrip.username, person.username);
      expect(roundTrip.displayName, person.displayName);
      expect(roundTrip.userId, person.userId);
    });

    test('Person model with missing fields defaults to empty strings', () {
      // Test person with missing optional data
      final personData = <String, dynamic>{};

      final person = Person.fromMap(personData, 'person456');
      expect(person.id, 'person456');
      expect(person.username, '');
      expect(person.displayName, '');
      expect(person.userId, '');
    });

    test('Todo model handles date persistence correctly', () {
      // Test date conversion
      final testDate = DateTime(2025, 12, 25, 15, 30);
      final millis = testDate.millisecondsSinceEpoch;

      final todoData = {
        'title': 'Christmas Todo',
        'isCompleted': false,
        'dueDate': millis,
        'userId': 'user123',
      };

      final todo = Todo.fromMap(todoData, 'todo789');
      expect(todo.dueDate, isNotNull);
      expect(todo.dueDate?.year, 2025);
      expect(todo.dueDate?.month, 12);
      expect(todo.dueDate?.day, 25);
      expect(todo.dueDate?.hour, 15);
      expect(todo.dueDate?.minute, 30);

      // Verify serialization maintains date
      final serialized = todo.toMap();
      expect(serialized['dueDate'], millis);
    });
  });
}
