import 'package:flutter/material.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();
  String? _expandedId;

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;
    setState(() {
      tasks.add({
        'id': DateTime.now().toString(),
        'title': _taskController.text,
        'completed': false,
        'subtasks': [],
      });
      _taskController.clear();
    });
  }

  void _addSubtask(String taskId, String title) {
    setState(() {
      final task = tasks.firstWhere((t) => t['id'] == taskId);
      task['subtasks'].add({'title': title, 'completed': false});
    });
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
                Expanded(child: TextField(controller: _taskController)),
                ElevatedButton(onPressed: _addTask, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isExpanded = _expandedId == task['id'];
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Checkbox(
                          value: task['completed'],
                          onChanged: (val) =>
                              setState(() => task['completed'] = val),
                        ),
                        title: Text(task['title']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onPressed: () => setState(
                                () => _expandedId = isExpanded
                                    ? null
                                    : task['id'],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  setState(() => tasks.removeAt(index)),
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded)
                        Column(
                          children: [
                            ...task['subtasks'].map<Widget>(
                              (subtask) => ListTile(
                                leading: Checkbox(
                                  value: subtask['completed'],
                                  onChanged: (val) => setState(
                                    () => subtask['completed'] = val,
                                  ),
                                ),
                                title: Text(subtask['title']),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Add Subtask'),
                                    content: TextField(
                                      controller: _subtaskController,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_subtaskController.text
                                              .trim()
                                              .isNotEmpty) {
                                            _addSubtask(
                                              task['id'],
                                              _subtaskController.text,
                                            );
                                            _subtaskController.clear();
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('+ Add Subtask'),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
