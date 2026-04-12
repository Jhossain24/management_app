import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection('tasks');

  // real-time updates for streams
  Stream<List<Task>> streamTasks() {
    return _tasksCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    await _tasksCollection.add({
      'title': title.trim(),
      'isCompleted': false,
      'subtasks': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> toggleTask(Task task) async {
    await _tasksCollection.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  // dlete a task
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Future<void> addSubtask(Task task, String subtaskTitle) async {
    if (subtaskTitle.trim().isEmpty) return;

    final List<Map<String, dynamic>> updatedSubtasks = List.from(task.subtasks);
    updatedSubtasks.add({
      'title': subtaskTitle.trim(),
      'isCompleted': false,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    await _tasksCollection.doc(task.id).update({'subtasks': updatedSubtasks});
  }

  // toggle subtask completion
  Future<void> toggleSubtask(Task task, int subtaskIndex) async {
    final List<Map<String, dynamic>> updatedSubtasks = List.from(task.subtasks);
    updatedSubtasks[subtaskIndex]['isCompleted'] =
        !(updatedSubtasks[subtaskIndex]['isCompleted'] as bool);

    await _tasksCollection.doc(task.id).update({'subtasks': updatedSubtasks});
  }

  Future<void> deleteSubtask(Task task, int subtaskIndex) async {
    final List<Map<String, dynamic>> updatedSubtasks = List.from(task.subtasks);
    updatedSubtasks.removeAt(subtaskIndex);

    await _tasksCollection.doc(task.id).update({'subtasks': updatedSubtasks});
  }
}
