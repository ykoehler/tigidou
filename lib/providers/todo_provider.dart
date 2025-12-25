import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/tool_parser.dart';

class TodoProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<Todo> _allTodos = [];
  List<Todo> get allTodos => _allTodos;

  TodoProvider() {
    _notificationService.initialize();
    _databaseService.todos.listen((todos) {
      _allTodos = todos;
      notifyListeners();
    });
  }

  Stream<List<Todo>> get todos => _databaseService.todos;

  List<String> get availableTags {
    final Map<String, int> tagCounts = {};
    for (final todo in _allTodos) {
      for (final tag in todo.tags) {
        // Skip 'person' tag as it's a meta-tag for characters
        if (tag == 'person') continue;
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    final sortedTags = tagCounts.keys.toList()
      ..sort((a, b) => tagCounts[b]!.compareTo(tagCounts[a]!));
    return sortedTags;
  }

  List<Todo> get availablePeople {
    return _allTodos.where((todo) => todo.tags.contains('person')).toList();
  }

  Future<void> addTodo(String title, DateTime? dueDate) async {
    // Parse the title for natural language dates and tags using ToolParser
    final parsedResult = ToolParser.parse(title);
    final finalDueDate = parsedResult.derivedDate ?? dueDate;
    final tags = parsedResult.hashtags;

    // We keep the title as is, as requested by the user ("preserve the format")
    final id = await _databaseService.addTodo(title, finalDueDate, tags);
    if (finalDueDate != null) {
      await _notificationService.scheduleNotification(
        id.hashCode,
        title,
        finalDueDate,
      );
    }
  }

  Future<void> updateTodo(Todo todo) async {
    await _databaseService.updateTodo(todo);

    // Cancel existing notification
    await _notificationService.cancelNotification(todo.id.hashCode);

    // Schedule new notification if needed
    if (!todo.isCompleted && todo.dueDate != null) {
      await _notificationService.scheduleNotification(
        todo.id.hashCode,
        todo.title,
        todo.dueDate!,
      );
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    final updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      isCompleted: !todo.isCompleted,
      dueDate: todo.dueDate,
      userId: todo.userId,
      sharedWith: todo.sharedWith,
    );
    await updateTodo(updatedTodo);
  }

  Future<void> deleteTodo(String id) async {
    await _databaseService.deleteTodo(id);
    await _notificationService.cancelNotification(id.hashCode);
  }
}
