import 'package:assignments/util/username_dialog_box.dart';
import 'package:assignments/widgets/my_chart.dart';
import 'package:assignments/widgets/tiles_layout.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assignments/services/notification_service.dart';
import '../data/database.dart';
import '../constants/colors.dart';
import '../pages/task_edit_page.dart';
import '../pages/view_all_page.dart';
import 'package:assignments/util/route_transitions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  int _selectedIndex = 0;
  
  // State for the custom FAB expansion


  bool showAllTiles = false;
  bool _showGridView = false;
  bool _showSearch = false;

  final TextEditingController userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }

    if (_myBox.get("USERNAME") == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        editUserName();
      });
    }
  }

  void editUserName() {
    showDialog(
      context: context,
      builder: (context) {
        return UsernameDialogBox(
          db: db,
          userNameController: userNameController,
        );
      },
    );
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      final isCompleted = value ?? false;
      db.toDoList[index][3] = isCompleted;
      
      // Auto-unpin if the task is marked as completed
      if (isCompleted && db.toDoList[index].length > 4) {
        db.toDoList[index][4] = false;
      }
    });
    db.updateDataBase();
  }

  void _openTaskEditor() {
    Navigator.push(
      context,
      createSmoothTransitionRoute(
        TaskEditPage(
          initialTask: null,

          onSave: (newTask) {
            setState(() {
              db.toDoList.add(newTask);
            });
            db.updateDataBase();

            final idx = db.toDoList.length - 1;
            final reminders =
                newTask.length > 5 ? (newTask[5] as List<DateTime>?) ?? [] : <DateTime>[];

            NotificationService().scheduleReminder(
              index: idx,
              title: (newTask[0] ?? '').toString(),
              body: (newTask[1] ?? '').toString(),
              scheduledTimes: reminders,
            );
          },
        ),
      ),
    );
  }

  void createNewTask() {
    _openTaskEditor();
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();

    NotificationService().cancelReminder(index);
  }

  Future<void> editTask(int index) async {
    final existingTask = db.toDoList[index];
    await Navigator.push(
      context,
      createSmoothTransitionRoute(
        TaskEditPage(
          initialTask: List<dynamic>.from(existingTask),
          onSave: (updatedTask) {
            setState(() {
              existingTask.clear();
              existingTask.addAll(updatedTask);
              db.toDoList[index] = existingTask;
            });
            db.updateDataBase();

            final reminders =
                updatedTask.length > 5 ? (updatedTask[5] as List<DateTime>?) ?? [] : <DateTime>[];

            NotificationService().scheduleReminder(
              index: index,
              title: (updatedTask[0] ?? '').toString(),
              body: (updatedTask[1] ?? '').toString(),
              scheduledTimes: reminders,
            );
          },
        ),
      ),
    );
  }

  Widget buildTasksLayout() {
    return TilesLayout(
      db: db,
      onChanged: checkBoxChanged,
      onDelete: deleteTask,
      onEdit: editTask,
      onPin: (int index, bool pin) {
        setState(() {
          if (db.toDoList[index].length < 5) {
            db.toDoList[index].add(pin);
          } else {
            db.toDoList[index][4] = pin;
          }
        });
        db.updateDataBase();
      },
      onTap: () async {
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ViewAllPage(
              db: db,
              onChanged: checkBoxChanged,
              onDelete: deleteTask,
              onEdit: editTask,
              onPin: (index, pin) {
                setState(() {
                  if (db.toDoList[index].length < 5) {
                    db.toDoList[index].add(pin);
                  } else {
                    db.toDoList[index][4] = pin;
                  }
                });
                db.updateDataBase();
              },
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.scaled,
                fillColor: Colors.transparent,
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  Widget buildChartLayout() {
    return MyChart(db: db);
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: !showAllTiles,
      backgroundColor: backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ===============================================
      // MAIN TOGGLE FAB (Fixed in Notch)
      // ===============================================
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        onPressed: _openTaskEditor,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 35,
        ),
      ),

      // ===============================================
      // APP BAR
      // ===============================================
      appBar: !showAllTiles
          ? AppBar(
              title: Text(
                db.userName != null
                    ? "Hi, ${db.userName.toString()[0].toUpperCase() + db.userName.toString().substring(1)}"
                    : "Welcome Back",
                style: TextStyle(
                  color: textColor,
                  letterSpacing: 2,
                  fontSize: 35,
                  fontWeight: FontWeight.w300,
                ),
              ),
              backgroundColor: Colors.transparent,
              actions: [
                PopupMenuButton<String>(
                  color: Colors.black,
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'Edit Username') {
                      editUserName();
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Edit Username',
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(
                        'Edit Username',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : AppBar(
              title: _showSearch
                  ? TextField(
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search tasks...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (value) {
                      },
                    )
                  : Text(
                      db.toDoList.isNotEmpty ? "My Tasks" : "Add a new task",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
              backgroundColor: darkGreen,
              actions: [
                IconButton(
                  icon: Icon(
                    _showSearch ? Icons.close : Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.grid_view,
                    color: _showGridView ? Colors.green : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _showGridView = !_showGridView;
                    });
                  },
                ),
              ],
              leading: const SizedBox.shrink(),
            ),

      // ===============================================
      // BODY (STACK)
      // ===============================================
      body: Stack(
        children: [
          // LAYER 1: The Main Content
          Positioned.fill(
            child: ClipRect(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP HEADER / GRAPHIC
                  Container(
                    height: height * 0.42,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [lightGreen, darkGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: (AppBar().titleSpacing ?? 16.0) + 8.0,
                            top: AppBar().preferredSize.height + 28.0,
                          ),
                          child: Text(
                            db.toDoList.isNotEmpty
                                ? "Completed: ${db.toDoList.where((task) => task.length > 3 && task[3] == true).length} "
                                    "out of ${db.toDoList.length} tasks"
                                : "You haven't set any tasks",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.25,
                          child: Center(
                            child: Image.asset('assets/transparent_logo.png'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BODY LIST/CHART
                  Expanded(
                    child: Container(
                      color: backgroundColor,
                      child: PageTransitionSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation, secondaryAnimation) {
                          return FadeThroughTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            fillColor: Colors.transparent,
                            child: child,
                          );
                        },
                        child: _selectedIndex == 0
                            ? KeyedSubtree(
                                key: const ValueKey('tasksLayout'),
                                child: buildTasksLayout(),
                              )
                            : KeyedSubtree(
                                key: const ValueKey('chartLayout'),
                                child: buildChartLayout(),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


        ],
      ),

      // ===============================================
      // BOTTOM NAV BAR
      // ===============================================
      bottomNavigationBar: SafeArea(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomAppBar(
            padding: const EdgeInsets.only(left: 40, right: 40),
            height: 75,
            shape: const CircularNotchedRectangle(),
            color: navbarColor,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  icon: Icon(
                    Icons.home,
                    size: 35,
                    color: _selectedIndex == 0 ? Colors.green : navbarIconColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  icon: Icon(
                    Icons.bar_chart,
                    size: 35,
                    color: _selectedIndex == 1 ? Colors.green : navbarIconColor,
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