import 'package:assignments/util/username_dialog_box.dart';
import 'package:assignments/widgets/my_chart.dart';
import 'package:assignments/widgets/tiles_layout.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/database.dart';
import '../constants/colors.dart';
//import '../util/todo_tile.dart';
//import '../util/todo_tile_shrinked.dart';
//import '../pages/task_detail_page.dart';
import '../pages/task_edit_page.dart';
import '../pages/view_all_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  int _selectedIndex = 0;

  bool showAllTiles = false;
  //bool _previousShowAllTiles = false; // now unused but kept for compatibility
  bool _showGridView = false;
  bool _showSearch = false;
  String _searchQuery = '';

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

  List filteredList({bool sortPinnedFirst = false}) {
    List tasks = _searchQuery.isEmpty
        ? db.toDoList
        : db.toDoList.where((task) {
            final title = task[0].toString().toLowerCase();
            final content = task[1].toString().toLowerCase();
            return title.contains(_searchQuery.toLowerCase()) ||
                content.contains(_searchQuery.toLowerCase());
          }).toList();
    if (sortPinnedFirst) {
      tasks.sort((a, b) {
        final aPinned = a.length > 4 && a[4] == true ? 1 : 0;
        final bPinned = b.length > 4 && b[4] == true ? 1 : 0;
        return bPinned.compareTo(aPinned);
      });
    }
    return tasks;
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
      db.toDoList[index][3] = value ?? false;
    });
    db.updateDataBase();
  }
  
  void createNewTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskEditPage(
          onSave: (newTask) {
            setState(() {
              db.toDoList.add(newTask);
            });
            db.updateDataBase();
          },
        ),
      ),
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  void editTask(int index) {
    final existingTask = db.toDoList[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskEditPage(
          initialTask: List<dynamic>.from(existingTask),
          onSave: (updatedTask) {
            setState(() {
              db.toDoList[index] = updatedTask;
            });
            db.updateDataBase();
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
          // Ensure the 5th element exists for pin state
          if (db.toDoList[index].length < 5) {
            db.toDoList[index].add(pin);
          } else {
            db.toDoList[index][4] = pin;
          }
        });
        db.updateDataBase();
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewAllPage(
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
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: createNewTask,
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 35,
        ),
      ),
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
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Edit Username',
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  'Edit Username',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              // const PopupMenuItem<String>( 
              //   value: 'Delete',
              //   // We'll apply the same padding here for a consistent look.
              //   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              //   child: Text(
              //     'Delete Username',
              //     style: TextStyle(color: Colors.white, fontSize: 16),
              //   ),
              // ),
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
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
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
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      if (_showSearch) _searchQuery = '';
                      _showSearch = !_showSearch;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.grid_view,
                    color: _showGridView ? Colors.green : Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _showGridView = !_showGridView;
                    });
                  },
                ),
              ],
              leading: const SizedBox.shrink(),
            ),
      body: ClipRect(
        child: Column(
          key: const ValueKey('home_view'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
            height: height * 0.42,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  lightGreen,
                  darkGreen,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: (AppBar().titleSpacing ?? 16.0) + 2.0,
                    top: AppBar().preferredSize.height + 20.0,
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
                  height: MediaQuery.of(context).size.height * 0.3,
                  child:
                      Center(child: Image.asset('assets/transparent_logo.png')),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetTween = Tween<Offset>(
                  begin: _selectedIndex == 0
                      ? const Offset(-1.0, 0.0)
                      : const Offset(1.0, 0.0),
                  end: Offset.zero,
                );
                return SlideTransition(
                  position: animation.drive(offsetTween),
                  child: child,
                );
              },
              child: Container(
                //key: ValueKey<int>(_selectedIndex),
                color: backgroundColor, // Ensures background remains black
                child: _selectedIndex == 0
                    ? buildTasksLayout()
                    : buildChartLayout(),
              ),
            ),
          ),
        ],
      ),),
      bottomNavigationBar: ClipRRect(
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
    );
  }
}
