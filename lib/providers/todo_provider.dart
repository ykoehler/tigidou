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

  /// Returns a map of todos grouped by their primary category.
  /// Priority: recordType (if exists), then the first tag, then "Uncategorized".
  Map<String, List<Todo>> get groupedTodos {
    final Map<String, List<Todo>> groups = {};
    for (var todo in _allTodos) {
      String group = 'Uncategorized';
      if (todo.recordType != null) {
        group = todo.recordType!;
      } else if (todo.tags.isNotEmpty) {
        // Find first tag that isn't 'person'
        group = todo.tags.firstWhere(
          (t) => t != 'person',
          orElse: () => 'Uncategorized',
        );
      }

      if (!groups.containsKey(group)) {
        groups[group] = [];
      }
      groups[group]!.add(todo);
    }
    return groups;
  }

  /// Returns a list of unique categories (tags and types) that have at least one record.
  List<String> get activeCategories {
    final Set<String> categories = {};
    for (var todo in _allTodos) {
      if (todo.recordType != null && todo.recordType != 'template') {
        categories.add(todo.recordType!);
      }
      for (var tag in todo.tags) {
        if (tag != 'person') {
          categories.add(tag);
        }
      }
    }
    return categories.toList()..sort();
  }

  /// Returns a list of unique record types (e.g., store, person) that have at least one record.
  List<String> get activeTypes {
    final Set<String> types = {};
    for (var todo in _allTodos) {
      if (todo.recordType != null && todo.recordType != 'template') {
        types.add(todo.recordType!);
      }
    }
    return types.toList()..sort();
  }

  /// Returns a list of unique hashtags (excluding 'person') that have at least one record.
  List<String> get activeTags {
    final Set<String> tags = {};
    for (var todo in _allTodos) {
      for (var tag in todo.tags) {
        if (tag != 'person') {
          tags.add(tag);
        }
      }
    }
    return tags.toList()..sort();
  }

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

    final id = await _databaseService.addTodo(
      title,
      finalDueDate,
      tags,
      recordType: parsedResult.recordType,
      quantity: parsedResult.quantity,
      price: parsedResult.price,
    );
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
