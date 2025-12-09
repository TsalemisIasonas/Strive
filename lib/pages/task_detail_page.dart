import 'package:assignments/constants/colors.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatefulWidget {
  final List task; // task structure: [title, content, dateTime, completed, (optional) pinned]
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggleComplete;
  final ValueChanged<bool>? onTogglePin;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
    this.onTogglePin,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  bool _completed = false;
  bool _pinned = false;

  @override
  void initState() {
    super.initState();
    _completed = widget.task[3] as bool? ?? false;
    _pinned = widget.task.length > 4 ? (widget.task[4] as bool? ?? false) : false;
  }

  void _toggleCompleted() {
    final newValue = !_completed;
    setState(() {
      _completed = newValue;
    });
    widget.onToggleComplete(newValue);
  }

  void _togglePinned() {
    setState(() {
      _pinned = !_pinned;
    });
    // Update the underlying task structure so callers that read task[4]
    // see the latest pinned value.
    if (widget.task.length < 5) {
      widget.task.add(_pinned);
    } else {
      widget.task[4] = _pinned;
    }

    widget.onTogglePin?.call(_pinned);
  }

  @override
  Widget build(BuildContext context) {
    final rawTitle = widget.task[0]?.toString() ?? '';
    final title = rawTitle.isNotEmpty
      ? rawTitle[0].toUpperCase() + rawTitle.substring(1)
      : '';
    final content = widget.task[1];
    final dateTime = widget.task[2];
    final List<dynamic> checklist =
        widget.task.length > 6 && widget.task[6] is List
            ? (widget.task[6] as List)
            : const [];

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
            tooltip: _pinned ? 'Unpin Task' : 'Pin Task',
            icon: Icon(
              _pinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            onPressed: _togglePinned,
          ),
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
                        if (checklist.isNotEmpty) ...[
                          const Text(
                            'Checklist',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...checklist.map((rawItem) {
                            String text = '';
                            bool done = false;
                            if (rawItem is Map) {
                              text = rawItem['text']?.toString() ?? '';
                              done = rawItem['done'] == true;
                            } else if (rawItem is List && rawItem.length >= 2) {
                              text = rawItem[0]?.toString() ?? '';
                              done = rawItem[1] == true;
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Icon(
                                    done
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: done
                                        ? Colors.greenAccent
                                        : Colors.white70,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
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
