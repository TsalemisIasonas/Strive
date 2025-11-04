import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List<List<dynamic>> toDoList = [];
  String? userName;
  final _myBox = Hive.box('mybox');

  void createInitialData() {
    toDoList = [
      ["Make Tutorial", "Learn how to make a to-do app", null, false],
      ["Do Exercise", "30 min run", null, false],
      ["Read Book", "Finish 10 pages of your novel", null, false],
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
      if (task is List && task.length == 4) {
        return [
          task[0],
          task[1],
          task[2], // can be null
          task[3],
        ];
      } else if (task is List) {
        final fixed = List<dynamic>.filled(4, null);
        for (int i = 0; i < task.length && i < 4; i++) {
          fixed[i] = task[i];
        }
        return fixed;
      } else {
        return ["", "", null, false];
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
