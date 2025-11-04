import 'package:assignments/constants/colors.dart';
import 'package:flutter/material.dart';


class TaskDetailPage extends StatelessWidget {
  final List task; // or use a proper model class if you have one

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final title = task[0];
    final content = task[1];
    final dateTime = task[2];
    final completed = task[3];

    return Scaffold(
      appBar: AppBar(title: Text(title, style: TextStyle(color: Colors.white),), backgroundColor: darkGreen,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text(
              'Due: '
              '${dateTime.day.toString().padLeft(2, '0')}/'
              '${dateTime.month.toString().padLeft(2, '0')}/'
              '${dateTime.year}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text('Completed: ${completed ? "Yes" : "No"}'),
          ],
        ),
      ),
    );
  }
}
