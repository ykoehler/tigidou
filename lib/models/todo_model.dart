class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final String? group;
  final String userId;
  final List<String> sharedWith;
  final List<String> tags;
  final String? recordType;
  final double? quantity;
  final double? price;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.dueDate,
    this.group,
    required this.userId,
    this.sharedWith = const [],
    this.tags = const [],
    this.recordType,
    this.quantity,
    this.price,
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
      tags: List<String>.from(map['tags'] ?? []),
      recordType: map['recordType'],
      quantity: (map['quantity'] as num?)?.toDouble(),
      price: (map['price'] as num?)?.toDouble(),
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
      'tags': tags,
      'recordType': recordType,
      'quantity': quantity,
      'price': price,
    };
  }
}
