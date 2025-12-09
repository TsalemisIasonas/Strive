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
  bool _pinned = false;
  final List<Map<String, dynamic>> _checklist = [];
  bool _isChecklistNote = false;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task != null ? (task[0] ?? '').toString() : '');
    _contentController = TextEditingController(text: task != null ? (task[1] ?? '').toString() : '');
    _selectedDateTime = task != null ? task[2] as DateTime? : null;
    _reminderDateTime = task != null && task.length > 5 ? task[5] as DateTime? : null;
    _pinned = task != null && task.length > 4 ? (task[4] as bool? ?? false) : false;

    if (task != null && task.length > 6 && task[6] is List) {
      for (final item in (task[6] as List)) {
        String text;
        bool done;

        if (item is Map<String, dynamic>) {
          text = item['text']?.toString() ?? '';
          done = item['done'] == true;
        } else if (item is List && item.length >= 2) {
          text = item[0]?.toString() ?? '';
          done = item[1] == true;
        } else {
          continue;
        }

        _checklist.add({'text': text, 'done': done});
      }
      // Existing task that already has a checklist is a checklist note
      if (_checklist.isNotEmpty) {
        _isChecklistNote = true;
      }
    }
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

    if (!_isChecklistNote && title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final existing = widget.initialTask;
    final completed = existing != null && existing.length > 3 ? (existing[3] as bool? ?? false) : false;

    final updatedTask = <dynamic>[
      title,
      _isChecklistNote ? '' : content,
      _selectedDateTime,
      completed,
      _pinned,
      _reminderDateTime,
      _isChecklistNote && _checklist.isNotEmpty ? _checklist : null,
    ];
    widget.onSave(updatedTask);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.initialTask != null ? 'Edit Task' : 'New Task',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (widget.initialTask != null)
            IconButton(
              icon: Icon(
                _pinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: Colors.white,
              ),
              tooltip: _pinned ? 'Unpin' : 'Pin',
              onPressed: () {
                setState(() {
                  _pinned = !_pinned;
                });
              },
            ),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isChecklistNote)
                      TextField(
                        controller: _contentController,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Write your task details here...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    if (_isChecklistNote)
                      _ChecklistEditor(
                        items: _checklist,
                        onChanged: (items) {
                          setState(() {
                            _checklist
                              ..clear()
                              ..addAll(items);
                          });
                        },
                      ),
                    const SizedBox(height: 8),
                  ],
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
      floatingActionButton: null,
    );
  }
}

class _ChecklistEditor extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  const _ChecklistEditor({
    required this.items,
    required this.onChanged,
  });

  @override
  State<_ChecklistEditor> createState() => _ChecklistEditorState();
}

class _ChecklistEditorState extends State<_ChecklistEditor> {
  void _updateItem(int index, Map<String, dynamic> newItem) {
    final List<Map<String, dynamic>> updated = List<Map<String, dynamic>>.from(widget.items);
    updated[index] = newItem;
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ...List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final controller = TextEditingController(text: item['text']?.toString() ?? '');

          return Row(
            children: [
              Checkbox(
                value: item['done'] == true,
                activeColor: Colors.green,
                onChanged: (value) {
                  _updateItem(index, {
                    'text': item['text']?.toString() ?? '',
                    'done': value ?? false,
                  });
                },
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Checklist item',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.done,
                  minLines: 1,
                  maxLines: 1,
                  onChanged: (value) {
                    _updateItem(index, {
                      'text': value,
                      'done': item['done'] == true,
                    });
                  },
                  onSubmitted: (_) {
                    if (index == widget.items.length - 1) {
                      final updated = List<Map<String, dynamic>>.from(widget.items)
                        ..add({'text': '', 'done': false});
                      widget.onChanged(updated);
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                onPressed: () {
                  final updated = List<Map<String, dynamic>>.from(widget.items)..removeAt(index);
                  widget.onChanged(updated);
                },
              ),
            ],
          );
        }),
      ],
    );
  }
}
