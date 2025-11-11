import 'package:assignments/constants/colors.dart';
import 'package:flutter/material.dart';

class ToDoTile extends StatelessWidget {
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

  const ToDoTile({
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
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shadowColor: shadowColor,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color.fromARGB(255, 108, 107, 107)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              width: 300,
              decoration: BoxDecoration(
                color: tileBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: tileBorderColor,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 65,
                    padding: const EdgeInsets.all(5),
                    color: tileHeaderColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: taskCompleted,
                          onChanged: onChanged,
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                        ),
                        Expanded(
                          child: Text(
                            taskTitle.isNotEmpty
                                ? taskTitle[0].toUpperCase() +
                                    taskTitle.substring(1)
                                : '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              decoration: taskCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                        if (showPin)
                          IconButton(
                            icon: Icon(
                              isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                              color: Colors.white,
                            ),
                            tooltip: isPinned ? 'Unpin' : 'Pin',
                            onPressed: onPin,
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    child: Flexible(
                      child: Text(
                        taskContent.isNotEmpty
                            ? taskContent[0].toUpperCase() +
                                taskContent.substring(1)
                            : '',
                        maxLines: 5,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: taskCompleted ? lightGreen : textColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    taskDateTime == null
                        ? ""
                        : "Due Date: "
                            "${taskDateTime!.day.toString().padLeft(2, '0')}/"
                            "${taskDateTime!.month.toString().padLeft(2, '0')}/"
                            "${taskDateTime!.year}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: deleteFunction,
                        icon: const Icon(Icons.delete,
                            color: Colors.white, size: 25),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: editFunction,
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 25),
                      ),
                    ],
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
