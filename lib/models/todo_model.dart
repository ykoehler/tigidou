class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final String? group;
  final String userId;
  final List<String> sharedWith;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.dueDate,
    this.group,
    required this.userId,
    this.sharedWith = const [],
  });

  factory Todo.fromMap(Map<String, dynamic> map, String id) {
    return Todo(
      id: id,
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      group: map['group'],
      userId: map['userId'] ?? '',
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'group': group,
      'userId': userId,
      'sharedWith': sharedWith,
    };
  }
}
