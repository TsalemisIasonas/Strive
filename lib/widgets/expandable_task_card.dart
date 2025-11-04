import 'package:flutter/material.dart';

class ExpandableTaskCard extends StatefulWidget {
  final String taskTitle;
  final String taskContent;
  final DateTime taskDateTime;
  final bool taskCompleted;
  final bool isPinned;
  final Color tileBackgroundColor;
  final Color tileHeaderColor;
  final Color tileBorderColor;
  final Color textColor;
  final VoidCallback onPin;
  final VoidCallback deleteFunction;
  final VoidCallback editFunction;
  final Function(bool?)? onChanged;

  const ExpandableTaskCard({
    super.key,
    required this.taskTitle,
    required this.taskContent,
    required this.taskDateTime,
    required this.taskCompleted,
    required this.isPinned,
    required this.tileBackgroundColor,
    required this.tileHeaderColor,
    required this.tileBorderColor,
    required this.textColor,
    required this.onPin,
    required this.deleteFunction,
    required this.editFunction,
    required this.onChanged,
  });

  @override
  State<ExpandableTaskCard> createState() => _ExpandableTaskCardState();
}

class _ExpandableTaskCardState extends State<ExpandableTaskCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Dark overlay when expanded
        if (_isExpanded)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = false),
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: Colors.black54,
            ),
          ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: _isExpanded ? 5 : 20,
          right: _isExpanded ? 5 : 20,
          top: _isExpanded ? (screenSize.height - 400) / 2 : 0,
          height: _isExpanded ? 400 : 250,
          child: GestureDetector(
            onTap: () => setState(() => _isExpanded = true),
            child: Card(
              shadowColor: Colors.black54,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: widget.tileBorderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.tileBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.tileBorderColor),
                  ),
                  child: Stack(
                    children: [
                      // Scrollable content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 65, 16, 70),
                        child: Center(
                          child: Text(
                            widget.taskContent.isNotEmpty
                                ? widget.taskContent[0].toUpperCase() +
                                    widget.taskContent.substring(1)
                                : 'No content to show',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.taskCompleted
                                  ? Colors.green
                                  : widget.textColor,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Header
                      Container(
                        height: 65,
                        padding: const EdgeInsets.all(5),
                        color: widget.tileHeaderColor,
                        child: Row(
                          children: [
                            Checkbox(
                              value: widget.taskCompleted,
                              onChanged: widget.onChanged,
                              activeColor: Colors.white,
                              checkColor: Colors.black,
                            ),
                            Expanded(
                              child: Text(
                                widget.taskTitle[0].toUpperCase() +
                                    widget.taskTitle.substring(1),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  decoration: widget.taskCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                widget.isPinned
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                color: Colors.white,
                              ),
                              onPressed: widget.onPin,
                            ),
                          ],
                        ),
                      ),

                      // Bottom bar
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          color: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Due Date: "
                                "${widget.taskDateTime.day.toString().padLeft(2, '0')}/"
                                "${widget.taskDateTime.month.toString().padLeft(2, '0')}/"
                                "${widget.taskDateTime.year}",
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
                                    onPressed: widget.deleteFunction,
                                    icon: const Icon(Icons.delete,
                                        color: Colors.white, size: 25),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: widget.editFunction,
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white, size: 25),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
