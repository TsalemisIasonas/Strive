import 'package:flutter/material.dart';
import '../constants/colors.dart';

class DialogBox extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Function(String) onChangedTitle;
  final Function(String) onChangedContent;
  final Function(DateTime?) onDateTimePicked;
  final String? initialTitle;
  final String? initialContent;
  final DateTime? initialDateTime;

  const DialogBox({
    super.key,
    required this.onSave,
    required this.onCancel,
    required this.onChangedTitle,
    required this.onChangedContent,
    required this.onDateTimePicked,
    this.initialTitle,
    this.initialContent,
    this.initialDateTime,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox>
    with SingleTickerProviderStateMixin {
  DateTime? selectedDateTime;
  late TextEditingController titleController;
  late TextEditingController contentController;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle ?? '');
    contentController =
        TextEditingController(text: widget.initialContent ?? '');
    selectedDateTime = widget.initialDateTime;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: selectedDateTime != null
            ? TimeOfDay.fromDateTime(selectedDateTime!)
            : TimeOfDay.now(),
      );

      if (time != null) {
        final combined = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {
          selectedDateTime = combined;
        });
        widget.onDateTimePicked(combined);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.5;
    final width = MediaQuery.of(context).size.width * 0.8;

    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: AlertDialog(
          scrollable: true,
          backgroundColor: Colors.grey[900],
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          content: SizedBox(
            height: height,
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: TextField(
                          controller: titleController,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.2),
                          decoration: const InputDecoration(
                            hintText: "Title",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          onChanged: widget.onChangedTitle,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check,
                          color: Color.fromARGB(255, 74, 201, 140)),
                      onPressed: () {
                        widget.onChangedTitle(titleController.text);
                        widget.onChangedContent(contentController.text);
                        widget.onDateTimePicked(selectedDateTime);
                        widget.onSave();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Color.fromARGB(255, 224, 61, 61)),
                      onPressed: () {
                        titleController.clear();
                        contentController.clear();
                        widget.onDateTimePicked(null);
                        widget.onCancel();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: TextField(
                    controller: contentController,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Content",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onChanged: widget.onChangedContent,
                  ),
                ),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: _pickDateTime,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Pick Time & Date",
                        style: TextStyle(
                            color: lightGreen,
                            fontWeight: FontWeight.w200,
                            fontSize: 20),
                      ),
                      const SizedBox(height: 5),
                      if (selectedDateTime != null)
                        Text(
                          "Time and Date Selected",
                          style: TextStyle(color: darkGreen),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
