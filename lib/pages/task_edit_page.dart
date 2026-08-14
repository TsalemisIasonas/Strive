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

class BlockItem {
  String type; // 'text' or 'checklist'
  TextEditingController controller;
  bool isDone;
  FocusNode focusNode;

  BlockItem({
    required this.type,
    String content = '',
    this.isDone = false,
  })  : controller = TextEditingController(text: content),
        focusNode = FocusNode();

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class _TaskEditPageState extends State<TaskEditPage> {
  late TextEditingController _titleController;
  DateTime? _selectedDateTime;
  List<DateTime> _reminders = [];
  bool _showReminders = false;
  bool _pinned = false;
  
  final List<BlockItem> _blocks = [];

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task != null ? (task[0] ?? '').toString() : '');
    _selectedDateTime = task != null ? task[2] as DateTime? : null;
    
    final taskReminders = task != null && task.length > 5 ? task[5] : null;
    if (taskReminders is List) {
      _reminders = taskReminders.cast<DateTime>().toList();
    } else if (taskReminders is DateTime) {
      _reminders = [taskReminders];
    }
    
    _pinned = task != null && task.length > 4 ? (task[4] as bool? ?? false) : false;

    if (task != null && task.length > 6 && task[6] is List && (task[6] as List).isNotEmpty) {
      for (final item in (task[6] as List)) {
        if (item is Map) {
          if (item.containsKey('type')) {
            // Modern block format
            _blocks.add(BlockItem(
              type: item['type']?.toString() ?? 'text',
              content: item['content']?.toString() ?? item['text']?.toString() ?? '',
              isDone: item['done'] == true,
            ));
          } else {
            // Legacy checklist format
            _blocks.add(BlockItem(
              type: 'checklist',
              content: item['text']?.toString() ?? '',
              isDone: item['done'] == true,
            ));
          }
        } else if (item is List && item.length >= 2) {
          _blocks.add(BlockItem(
            type: 'checklist',
            content: item[0]?.toString() ?? '',
            isDone: item[1] == true,
          ));
        }
      }
    }

    // If no blocks were added (legacy plain text note), convert text into a block
    if (_blocks.isEmpty && task != null && task.length > 1) {
      final content = (task[1] ?? '').toString();
      if (content.isNotEmpty) {
        _blocks.add(BlockItem(type: 'text', content: content));
      }
    }

    // Default to at least one text block if completely empty
    if (_blocks.isEmpty) {
      _blocks.add(BlockItem(type: 'text'));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var block in _blocks) {
      block.dispose();
    }
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

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              tertiary: Colors.green,
              onTertiary: Colors.white,
              tertiaryContainer: Colors.green,
              onTertiaryContainer: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (time == null) {
      setState(() {
        _selectedDateTime = DateTime(date.year, date.month, date.day);
        _showReminders = true;
      });
    } else {
      setState(() {
        _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        _showReminders = true;
      });
    }
  }

  Future<void> _pickReminder() async {
    final ctx = context;
    final now = DateTime.now();
    final base = now;

    final date = await showDatePicker(
      context: ctx,
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
    if (!ctx.mounted) return;

    final time = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.fromDateTime(base),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              tertiary: Colors.green,
              onTertiary: Colors.white,
              tertiaryContainer: Colors.green,
              onTertiaryContainer: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    setState(() {
      if (time != null) {
        _reminders.add(DateTime(date.year, date.month, date.day, time.hour, time.minute));
        _showReminders = true;
      }
    });
  }

  void _save() {
    final title = _titleController.text.trim();

    // Generate plain-text preview and structured blocks
    final List<String> textPreviews = [];
    final List<Map<String, dynamic>> serializedBlocks = [];

    for (var block in _blocks) {
      final content = block.controller.text.trim();
      if (content.isNotEmpty || _blocks.length == 1) { // allow saving empty single block
        if (block.type == 'text' && content.isNotEmpty) {
          textPreviews.add(content);
        } else if (block.type == 'checklist' && content.isNotEmpty) {
          textPreviews.add('${block.isDone ? '✓' : '•'} $content');
        }
        
        serializedBlocks.add({
          'type': block.type,
          'content': block.controller.text, // keep raw text (not trimmed for internal format)
          'done': block.isDone,
        });
      }
    }

    final combinedPreview = textPreviews.join('\n');

    if (title.isEmpty && combinedPreview.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final existing = widget.initialTask;
    final completed = existing != null && existing.length > 3 ? (existing[3] as bool? ?? false) : false;

    final updatedTask = <dynamic>[
      title,
      combinedPreview,
      _selectedDateTime,
      completed,
      _pinned,
      _reminders,
      serializedBlocks, // save structured blocks in index 6
    ];
    widget.onSave(updatedTask);
    Navigator.of(context).pop();
  }

  void _addBlock(String type) {
    setState(() {
      // If the editor only has one block, and it's an empty text block, remove it.
      if (_blocks.length == 1 && _blocks[0].type == 'text' && _blocks[0].controller.text.trim().isEmpty) {
        _blocks[0].dispose();
        _blocks.clear();
      }
      _blocks.add(BlockItem(type: type));
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted && _blocks.isNotEmpty) {
        _blocks.last.focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white, size: 22),
              tooltip: 'Set Due Date',
              onPressed: _pickDateTime,
            ),
            IconButton(
              icon: const Icon(Icons.notifications_active, color: Colors.white, size: 22),
              tooltip: 'Set Reminder',
              onPressed: _pickReminder,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notes),
            tooltip: 'Add Text',
            onPressed: () => _addBlock('text'),
          ),
          IconButton(
            icon: const Icon(Icons.check_box_outlined),
            tooltip: 'Add Checklist',
            onPressed: () => _addBlock('checklist'),
          ),
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
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 20.0,
          bottom: MediaQuery.of(context).padding.bottom + 
                  MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/transparent_logo.png',
                color: const Color.fromARGB(137, 117, 114, 114),
              ),
            ),
            ListView(
              children: [
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
            if (_selectedDateTime != null || _reminders.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showReminders = !_showReminders;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            _showReminders ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_reminders.length + (_selectedDateTime != null ? 1 : 0)} date(s) & reminder(s)',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showReminders)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          if (_selectedDateTime != null)
                            InputChip(
                              backgroundColor: darkGreen.withValues(alpha: 0.5),
                              labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                              side: BorderSide.none,
                              avatar: const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                              label: Text('${_selectedDateTime!.day.toString().padLeft(2, '0')}/${_selectedDateTime!.month.toString().padLeft(2, '0')}/${_selectedDateTime!.year}'),
                              onPressed: _pickDateTime,
                              onDeleted: () => setState(() => _selectedDateTime = null),
                              deleteIconColor: Colors.white70,
                            ),
                          ..._reminders.map((reminder) => InputChip(
                                backgroundColor: darkGreen.withValues(alpha: 0.5),
                                labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                side: BorderSide.none,
                                avatar: const Icon(Icons.notifications_active, color: Colors.white, size: 14),
                                label: Text('${reminder.day.toString().padLeft(2, '0')}/${reminder.month.toString().padLeft(2, '0')}/${reminder.year} ${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}'),
                                onDeleted: () {
                                  setState(() {
                                    _reminders.remove(reminder);
                                  });
                                },
                                deleteIconColor: Colors.white70,
                              )),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _blocks.length,
                      itemBuilder: (context, index) {
                        final block = _blocks[index];
                        if (block.type == 'text') {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: block.controller,
                                  focusNode: block.focusNode,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: index == 0 ? 'Write your task details here...' : 'Text block',
                                    hintStyle: const TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    // Auto-spawn text block on triple enter (optional, skipping for now)
                                  },
                                ),
                              ),
                              if (_blocks.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _blocks.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          );
                        } else if (block.type == 'checklist') {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: block.isDone,
                                activeColor: Colors.green,
                                onChanged: (value) {
                                  setState(() {
                                    block.isDone = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  controller: block.controller,
                                  focusNode: block.focusNode,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: TextStyle(
                                    color: block.isDone ? Colors.white54 : Colors.white, 
                                    fontSize: 16,
                                    decoration: block.isDone ? TextDecoration.lineThrough : null,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Checklist item',
                                    hintStyle: TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                  ),
                                  maxLines: null,
                                  onChanged: (val) {
                                    // If user presses Enter, auto-spawn new checklist item
                                    if (val.endsWith('\n')) {
                                      block.controller.text = val.substring(0, val.length - 1);
                                      setState(() {
                                        _blocks.insert(index + 1, BlockItem(type: 'checklist'));
                                      });
                                      Future.delayed(const Duration(milliseconds: 50), () {
                                        if (mounted && _blocks.length > index + 1) {
                                          _blocks[index + 1].focusNode.requestFocus();
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _blocks.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
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

