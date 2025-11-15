import 'package:flutter/material.dart';
import 'package:assignments/constants/colors.dart';
import 'package:assignments/data/database.dart';
import 'package:assignments/util/todo_tile.dart';
import 'package:assignments/util/todo_tile_shrinked.dart';
import 'package:assignments/pages/task_detail_page.dart';

class ViewAllPage extends StatefulWidget {
  final ToDoDataBase db;
  final Function(bool?, int) onChanged;
  final Function(int) onDelete;
  final Function(int) onEdit;
  final Function(int, bool) onPin;

  const ViewAllPage({
    super.key,
    required this.db,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onPin,
  });

  @override
  State<ViewAllPage> createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  bool _showGridView = false;
  bool _showSearch = false;
  String _searchQuery = '';

  List filteredList({bool sortPinnedFirst = false}) {
    List tasks = _searchQuery.isEmpty
        ? widget.db.toDoList
        : widget.db.toDoList.where((task) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.of(context).pop();
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 35,
        ),
      ),
      appBar: AppBar(
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
                widget.db.toDoList.isNotEmpty
                    ? "My Tasks"
                    : "Add a new task",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
        backgroundColor: darkGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      ),
      body: Container(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: !_showGridView
              ? Builder(
                  builder: (context) {
                    final sortedTasks = filteredList(sortPinnedFirst: true);
                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0.0,
                        mainAxisSpacing: 4.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        final originalIndex =
                            widget.db.toDoList.indexOf(task);
                        final isPinned =
                            task.length > 4 && task[4] == true;
                        return ToDoTile(
                          taskTitle: task[0],
                          taskContent: task[1],
                          taskDateTime: task[2],
                          taskCompleted: task[3],
                          onChanged: (value) =>
                              widget.onChanged(value, originalIndex),
                          deleteFunction: () =>
                              widget.onDelete(originalIndex),
                          editFunction: () =>
                              widget.onEdit(originalIndex),
                          isPinned: isPinned,
                          outerPadding:
                              const EdgeInsets.only(left: 0, right: 0, top: 6),
                          onPin: () => widget.onPin(originalIndex, !isPinned),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => TaskDetailPage(
                                  task: task,
                                  onEdit: () =>
                                      widget.onEdit(originalIndex),
                                  onDelete: () =>
                                      widget.onDelete(originalIndex),
                                  onToggleComplete: (value) =>
                                      widget.onChanged(
                                          value, originalIndex),
                                ),
                                transitionsBuilder:
                                    (_, animation, __, child) {
                                  const begin = Offset(0.0, 0.1);
                                  const end = Offset.zero;
                                  final slide = Tween(begin: begin, end: end)
                                      .chain(CurveTween(
                                          curve: Curves.easeOut));
                                  final fade = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeIn);
                                  return SlideTransition(
                                    position:
                                        animation.drive(slide),
                                    child: FadeTransition(
                                        opacity: fade, child: child),
                                  );
                                },
                              ),
                            );
                          },
                          showPin: true,
                        );
                      },
                    );
                  },
                )
              : Builder(
                  builder: (context) {
                    final sortedTasks = filteredList(sortPinnedFirst: true);
                    return GridView.builder(
                      padding: const EdgeInsets.all(5.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                        childAspectRatio: 3.5,
                      ),
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        final originalIndex =
                            widget.db.toDoList.indexOf(task);
                        final isPinned =
                            task.length > 4 && task[4] == true;
                        return ToDoTileShrinked(
                          taskTitle: task[0],
                          taskDateTime: task[2],
                          taskCompleted: task[3],
                          onChanged: (value) =>
                              widget.onChanged(value, originalIndex),
                          deleteFunction: () =>
                              widget.onDelete(originalIndex),
                          editFunction: () =>
                              widget.onEdit(originalIndex),
                          isPinned: isPinned,
                          onPin: () => widget.onPin(originalIndex, !isPinned),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
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
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }
}
