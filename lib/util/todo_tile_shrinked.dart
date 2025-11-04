import 'package:assignments/constants/colors.dart';
import 'package:flutter/material.dart';

class ToDoTileShrinked extends StatelessWidget {
  final String taskTitle;
  final DateTime taskDateTime;
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final VoidCallback deleteFunction;
  final VoidCallback editFunction;
  final bool isPinned;
  final VoidCallback onPin;

  const ToDoTileShrinked(
      {super.key,
      required this.taskTitle,
      required this.taskDateTime,
      required this.taskCompleted,
      required this.onChanged,
      required this.deleteFunction,
      required this.editFunction,
      required this.isPinned,
      required this.onPin});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: lightGreen),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: tileBorderColor,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Checkbox(value: taskCompleted, onChanged: onChanged),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
                  child: Text(
                    taskTitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      decoration: taskCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: Colors.white,
                  size: 17,
                ),
                onPressed: onPin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
