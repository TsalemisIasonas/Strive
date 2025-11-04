import 'package:assignments/data/database.dart';
import 'package:flutter/material.dart';

class UsernameDialogBox extends StatelessWidget {
  final ToDoDataBase db;
  final TextEditingController userNameController;

  const UsernameDialogBox(
      {super.key, required this.db, required this.userNameController});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.95),
      content: SizedBox(
        width: 200,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userNameController,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2),
              decoration: const InputDecoration(
                hintText: "Enter your Name",
              ),
            ),
            const SizedBox(height: 80),
            TextButton(
              child: const Text("Save", style: TextStyle(fontSize: 20),),
              onPressed: () {
                db.userName = userNameController.text;
                db.storeName();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
