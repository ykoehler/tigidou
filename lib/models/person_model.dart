class Person {
  final String id;
  final String username; // Unique identifier for tagging (e.g. "father")
  final String displayName;
  final String userId;

  Person({
    required this.id,
    required this.username,
    required this.displayName,
    required this.userId,
  });

  factory Person.fromMap(Map<String, dynamic> data, String documentId) {
    return Person(
      id: documentId,
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'username': username, 'displayName': displayName, 'userId': userId};
  }
}
