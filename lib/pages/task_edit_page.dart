import 'package:assignments/constants/colors.dart';
import 'package:flutter/material.dart';

class TaskEditPage extends StatefulWidget {
  final List<dynamic>? initialTask; // [title, content, dateTime, completed, (optional) pinned]
  final ValueChanged<List<dynamic>> onSave;

  const TaskEditPage({
    super.key,
    this.initialTask,
    required this.onSave,
  });

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime? _selectedDateTime;
  DateTime? _reminderDateTime;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task != null ? (task[0] ?? '').toString() : '');
    _contentController = TextEditingController(text: task != null ? (task[1] ?? '').toString() : '');
    _selectedDateTime = task != null ? task[2] as DateTime? : null;
    _reminderDateTime = task != null && task.length > 5 ? task[5] as DateTime? : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDateTime ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) {
      setState(() {
        _selectedDateTime = DateTime(date.year, date.month, date.day);
      });
    } else {
      setState(() {
        _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      });
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final existing = widget.initialTask;
    final completed = existing != null && existing.length > 3 ? (existing[3] as bool? ?? false) : false;
    final pinned = existing != null && existing.length > 4 ? (existing[4] as bool? ?? false) : false;

    final updatedTask = <dynamic>[
      title,
      content,
      _selectedDateTime,
      completed,
      pinned,
      _reminderDateTime,
    ];
    widget.onSave(updatedTask);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTask != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your task details here...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due date',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDateTime == null
                          ? 'No due date'
                          : '${_selectedDateTime!.day.toString().padLeft(2, '0')}/'
                            '${_selectedDateTime!.month.toString().padLeft(2, '0')}/'
                            '${_selectedDateTime!.year}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: const Text('Pick date', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reminder',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _reminderDateTime == null
                          ? 'No reminder set'
                          : '${_reminderDateTime!.day.toString().padLeft(2, '0')}/'
                            '${_reminderDateTime!.month.toString().padLeft(2, '0')}/'
                            '${_reminderDateTime!.year} '
                            '${_reminderDateTime!.hour.toString().padLeft(2, '0')}:'
                            '${_reminderDateTime!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final base = _reminderDateTime ?? _selectedDateTime ?? now;

                    final date = await showDatePicker(
                      context: context,
                      initialDate: base,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 5),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.green,
                              onPrimary: Colors.white,
                              surface: Colors.black,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (date == null) return;

                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(base),
                    );

                    setState(() {
                      if (time == null) {
                        _reminderDateTime = DateTime(date.year, date.month, date.day);
                      } else {
                        _reminderDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      }
                    });
                  },
                  icon: const Icon(Icons.notifications_active, color: Colors.white),
                  label: const Text('Set reminder', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
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
