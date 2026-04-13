import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();
  String? _expandedTaskId;

  @override
  void dispose() {
    _taskController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;
    _taskService.addTask(_taskController.text);
    _taskController.clear();
  }

  void _showAddSubtaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: _subtaskController,
          decoration: const InputDecoration(hintText: 'Subtask name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_subtaskController.text.trim().isNotEmpty) {
                _taskService.addSubtask(task, _subtaskController.text);
                _subtaskController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'New task...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTask, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.streamTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks yet'));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isExpanded = _expandedTaskId == task.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) => _taskService.toggleTask(task),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                  onPressed: () => setState(() {
                                    _expandedTaskId = isExpanded
                                        ? null
                                        : task.id;
                                  }),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      _taskService.deleteTask(task.id),
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ...task.subtasks.map(
                                    (subtask) => ListTile(
                                      dense: true,
                                      leading: Checkbox(
                                        value: subtask['isCompleted'],
                                        onChanged: (_) =>
                                            _taskService.toggleSubtask(
                                              task,
                                              task.subtasks.indexOf(subtask),
                                            ),
                                      ),
                                      title: Text(subtask['title']),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.close, size: 18),
                                        onPressed: () =>
                                            _taskService.deleteSubtask(
                                              task,
                                              task.subtasks.indexOf(subtask),
                                            ),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _showAddSubtaskDialog(task),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Subtask'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
