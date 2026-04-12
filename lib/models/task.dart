class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final List<Map<String, dynamic>> subtasks;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.subtasks = const [],
    required this.createdAt,
  });

  // Convert Task to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'subtasks': subtasks,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Task from Firestore document
  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      subtasks: List<Map<String, dynamic>>.from(data['subtasks'] ?? []),
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper method to create a copy with updated fields
  Task copyWith({
    String? title,
    bool? isCompleted,
    List<Map<String, dynamic>>? subtasks,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt,
    );
  }
}
