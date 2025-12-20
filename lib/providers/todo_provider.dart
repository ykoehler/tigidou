import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/tool_parser.dart';

class TodoProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  TodoProvider() {
    _notificationService.initialize();
  }

  Stream<List<Todo>> get todos => _databaseService.todos;

  Future<void> addTodo(String title, DateTime? dueDate) async {
    // Parse the title for natural language dates using ToolParser
    final parsedResult = ToolParser.parse(title);
    final finalDueDate = parsedResult.derivedDate ?? dueDate;

    // We keep the title as is, as requested by the user ("preserve the format")
    // But we use the parsed date for scheduling.

    final id = await _databaseService.addTodo(title, finalDueDate);
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
    );
    await updateTodo(updatedTodo);
  }

  Future<void> deleteTodo(String id) async {
    await _databaseService.deleteTodo(id);
    await _notificationService.cancelNotification(id.hashCode);
  }
}
