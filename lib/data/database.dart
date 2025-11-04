import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List toDoList = [];
  String? userName;

  // reference our box
  final _myBox = Hive.box('mybox');

  // run this method if this is the 1st time ever opening this app
  void createInitialData() {
    toDoList = [
      ["Make Tutorial", "Learn how to make a to-do app", DateTime.now(), false],
      ["Do Exercise", "30 min run", DateTime.now(), false],
      ["Read Book", "Finish 10 pages of your novel", DateTime.now(), false],
    ];
  }

  // load the data from database
  void loadData() {
    final rawList = _myBox.get("TODOLIST");

    // Convert older 2-element tasks into the new format
    toDoList = rawList.map((task) {
      if (task is List && task.length == 2) {
        return [
          task[0],               // title
          "",                    // content (default empty)
          DateTime.now(),        // datetime (default now)
          task[1],               // completed
        ];
      } else {
        return task; // already in new format
      }
    }).toList();

    //final userName = _myBox.get('USERNAME');
  }

  // update the database
  void updateDataBase() {
    _myBox.put("TODOLIST", toDoList);
  }

  void storeName(){
    _myBox.put("USERNAME", userName);
  }
}