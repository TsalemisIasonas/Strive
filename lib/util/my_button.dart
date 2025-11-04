import 'package:flutter/material.dart';

class DialogBox extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Function(String) onChangedTitle;
  final Function(String) onChangedContent;
  final Function(DateTime) onDateTimePicked;

  const DialogBox({
    super.key,
    required this.onSave,
    required this.onCancel,
    required this.onChangedTitle,
    required this.onChangedContent,
    required this.onDateTimePicked,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox>
    with SingleTickerProviderStateMixin {
  DateTime? selectedDateTime;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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
        initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
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

    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          content: SizedBox(
            height: height,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w300, letterSpacing: 1.2),
                        decoration: const InputDecoration(
                          hintText: "Title",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                        onChanged: widget.onChangedTitle,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Color.fromARGB(255, 74, 201, 140)),
                      onPressed: widget.onSave,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color.fromARGB(255, 224, 61, 61)),
                      onPressed: widget.onCancel,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Content input
                TextField(
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Content",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: widget.onChangedContent,
                ),

                const SizedBox(height: 20),

                // Date & Time Picker (Icons only)
                Center(
                  child: TextButton(
                    onPressed: _pickDateTime,
                    child: Column(
                      children: [
                        const Text("Pick Date & Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w200)),
                        const SizedBox(width: 15),
                        if (selectedDateTime != null)
                          Text(
                            "${selectedDateTime!.toLocal()}".split('.')[0],
                            style: const TextStyle(color: Colors.white),
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
    );
  }
}