import 'package:assignments/constants/colors.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatefulWidget {
  final List task; // task structure: [title, content, dateTime, completed, (optional) pinned]
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggleComplete;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _completed = widget.task[3] as bool? ?? false;
  }

  void _toggleCompleted() {
    final newValue = !_completed;
    setState(() {
      _completed = newValue;
    });
    widget.onToggleComplete(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.task[0];
    final content = widget.task[1];
    final dateTime = widget.task[2];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Edit Task',
            icon: const Icon(Icons.edit),
            onPressed: widget.onEdit,
          ),
          IconButton(
            tooltip: 'Delete Task',
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Colors.red.shade900,
                  title: const Text(
                    'Delete Task',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Are you sure you want to delete this task?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white70)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.onDelete();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/transparent_logo.png',
                color: const Color.fromARGB(137, 117, 114, 114),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          dateTime == null
                              ? 'Due: No due date set'
                              : 'Due: '
                                  '${dateTime!.day.toString().padLeft(2, '0')}/'
                                  '${dateTime!.month.toString().padLeft(2, '0')}/'
                                  '${dateTime!.year}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status: ${_completed ? "Completed" : "Pending"}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: _completed
                              ? Colors.greenAccent
                              : Colors.white,
                          backgroundColor: Colors.white10,
                        ),
                        onPressed: _toggleCompleted,
                        icon: Icon(
                          _completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                        ),
                        label: Text(
                            _completed ? 'Completed' : 'Mark as completed'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
