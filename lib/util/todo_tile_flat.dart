import 'package:assignments/constants/colors.dart';
import 'package:flutter/material.dart';

class ToDoTileFlat extends StatelessWidget {
  final String taskTitle;
  final String taskContent;
  final DateTime? taskDateTime;
  final bool taskCompleted;
  final bool isPinned;
  final Function(bool?)? onChanged;
  final VoidCallback deleteFunction;
  final VoidCallback editFunction;
  final VoidCallback onPin;
  final VoidCallback onTap;
  final bool showPin;
  final EdgeInsetsGeometry outerPadding;

  const ToDoTileFlat({
    super.key,
    required this.taskTitle,
    required this.taskContent,
    required this.taskDateTime,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    required this.editFunction,
    required this.isPinned,
    required this.onPin,
    required this.onTap,
    this.showPin = true,
    this.outerPadding = const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: outerPadding,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: tileBorderColor.withValues(alpha: 0.3)),
          ),
          color: tileBackgroundColor,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main content area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: taskCompleted,
                                  onChanged: onChanged,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  taskTitle.isNotEmpty
                                      ? taskTitle[0].toUpperCase() +
                                          taskTitle.substring(1)
                                      : '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: lightGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    decoration: taskCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.only(left: 36.0),
                          child: RichText(
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: (() {
                                if (taskContent.isEmpty) return const <TextSpan>[];
                                String text = taskContent[0].toUpperCase() + taskContent.substring(1);
                                final lines = text.split('\n');
                                final spans = <TextSpan>[];
                                bool wasChecklist = lines.isNotEmpty && (lines[0].startsWith('✓') || lines[0].startsWith('•'));

                                for (int i = 0; i < lines.length; i++) {
                                  final line = lines[i];
                                  bool isChecklist = line.startsWith('✓') || line.startsWith('•');

                                  if (i > 0) {
                                    if (isChecklist != wasChecklist) {
                                      spans.add(const TextSpan(text: '\n\n', style: TextStyle(fontSize: 6)));
                                    } else {
                                      spans.add(const TextSpan(text: '\n'));
                                    }
                                  }
                                  wasChecklist = isChecklist;

                                  if (line.startsWith('✓')) {
                                    spans.add(TextSpan(
                                      text: line,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ));
                                  } else {
                                    spans.add(TextSpan(
                                      text: line,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: taskCompleted ? lightGreen : textColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ));
                                  }
                                }
                                return spans;
                              })(),
                            ),
                            ),
                          ),
                          if (taskDateTime != null) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 36.0),
                              child: Text(
                                "Due: "
                                "${taskDateTime!.day.toString().padLeft(2, '0')}/"
                                "${taskDateTime!.month.toString().padLeft(2, '0')}/"
                                "${taskDateTime!.year}",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Green sidebar with icons
                  Container(
                    width: 48,
                    decoration: BoxDecoration(
                      color: darkGreen,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showPin)
                          IconButton(
                            icon: Icon(
                              isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: isPinned ? 'Unpin' : 'Pin',
                            onPressed: onPin,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                          onPressed: editFunction,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.white, size: 20),
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
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(),
                                    child: const Text('Cancel',
                                        style: TextStyle(
                                            color: Colors.white70)),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      deleteFunction();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
