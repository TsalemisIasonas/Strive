import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List<List<dynamic>> toDoList = [];
  String? userName;
  final _myBox = Hive.box('mybox');

  void createInitialData() {
    toDoList = [
      ["Make Tutorial", "Learn how to make a to-do app", null, false, false, null],
      ["Do Exercise", "30 min run", null, false, false, null],
      ["Read Book", "Finish 10 pages of your novel", null, false, false, null],
    ];
    updateDataBase();
  }

  void loadData() {
    final rawList = _myBox.get("TODOLIST");

    if (rawList == null) {
      toDoList = [];
      return;
    }

    toDoList = rawList.map<List<dynamic>>((task) {
      if (task is List) {
        // Normalize to:
        // [title, content, dueDate, completed, pinned, reminderDateTime, optionalChecklist]
        // We keep index 6 (checklist) as-is if present, otherwise null.
        final fixed = List<dynamic>.filled(7, null);
        for (int i = 0; i < task.length && i < 7; i++) {
          fixed[i] = task[i];
        }

        // Ensure completed defaults to false
        fixed[3] = fixed[3] ?? false;
        // Ensure pinned defaults to false
        fixed[4] = fixed[4] ?? false;

        return fixed;
      } else {
        return ["", "", null, false, false, null, null];
      }
    }).toList();
  }

  void updateDataBase() {
    _myBox.put("TODOLIST", toDoList);
  }

  void storeName() {
    _myBox.put("USERNAME", userName);
  }
}
