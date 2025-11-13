import '../data/database.dart';
import '../util/todo_tile.dart';
import '../util/todo_tile_shrinked.dart';
import 'package:flutter/material.dart';
import '../pages/task_detail_page.dart';

class TilesLayout extends StatefulWidget {
  final ToDoDataBase db;
  final Function(bool?, int) onChanged;
  final Function(int) onDelete;
  final Function(int) onEdit;
  final Function(int, bool) onPin;
  final VoidCallback onTap;

  const TilesLayout({
    super.key,
    required this.db,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onPin,
    required this.onTap,
  });

  @override
  State<TilesLayout> createState() => _TilesLayoutState();
}

class _TilesLayoutState extends State<TilesLayout> {
  bool _showGridView = false;
  bool _showSearch = false;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  List<List<dynamic>> _getTop4Tasks() {
    final now = DateTime.now();
    final filteredList = _searchQuery.isEmpty
        ? widget.db.toDoList
        : widget.db.toDoList.where((task) {
            final title = task[0].toString().toLowerCase();
            final content = task[1].toString().toLowerCase();
            return title.contains(_searchQuery.toLowerCase()) ||
                content.contains(_searchQuery.toLowerCase());
          }).toList();

    // Separate tasks with a due date in the future (or immediate)
    final dueTasks = filteredList
        .where((task) =>
            task[2] != null && (task[2] as DateTime).isAfter(now))
        .toList();

    // Sort due tasks by soonest date
    dueTasks.sort((a, b) {
      final aDate = a[2] as DateTime?;
      final bDate = b[2] as DateTime?;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    // Take up to 4 from due tasks
    final topDue = dueTasks.take(4).toList();

    // If less than 4, add tasks without due date or remaining tasks
    if (topDue.length < 4) {
      final remaining = filteredList
          .where((task) => !topDue.contains(task))
          .take(4 - topDue.length);
      topDue.addAll(remaining);
    }

    return topDue;
  }

  @override
  Widget build(BuildContext context) {
    final topTasks = _getTop4Tasks();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppBar().titleSpacing ?? 16.0, vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: _showSearch
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
              ),
              IconButton(
                icon: const Icon(Icons.list, color: Colors.white),
                onPressed: widget.onTap,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: !_showGridView
              ? ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: topTasks.length,
                  itemBuilder: (context, index) {
                    final originalIndex =
                        widget.db.toDoList.indexOf(topTasks[index]);
                    final isPinned = topTasks[index].length > 4 &&
                        topTasks[index][4] == true;
                    return SizedBox(
                      width: 300,
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ToDoTile(
                          taskTitle: topTasks[index][0],
                          taskContent: topTasks[index][1],
                          taskDateTime: topTasks[index][2],
                          taskCompleted: topTasks[index][3],
                          onChanged: (value) =>
                              widget.onChanged(value, originalIndex),
                          deleteFunction: () =>
                              widget.onDelete(originalIndex),
                          editFunction: () => widget.onEdit(originalIndex),
                          isPinned: isPinned,
                          onPin: () {
                            widget.onPin(originalIndex, !isPinned);
                            setState(() {});
                            _scrollController.animateTo(
                              0.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          showPin: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    TaskDetailPage(task: topTasks[index]),
                                transitionsBuilder: (_, animation, __, child) {
                                  const begin = Offset(0.0, 0.1);
                                  const end = Offset.zero;
                                  final slide = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: Curves.easeOut));
                                  final fade = CurvedAnimation(
                                      parent: animation, curve: Curves.easeIn);
                                  return SlideTransition(
                                    position: animation.drive(slide),
                                    child: FadeTransition(
                                        opacity: fade, child: child),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                )
              : GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: topTasks.length,
                  itemBuilder: (context, index) {
                    final originalIndex =
                        widget.db.toDoList.indexOf(topTasks[index]);
                    final isPinned = topTasks[index].length > 4 &&
                        topTasks[index][4] == true;
                    return ToDoTileShrinked(
                      taskTitle: topTasks[index][0],
                      taskDateTime: topTasks[index][2],
                      taskCompleted: topTasks[index][3],
                      onChanged: (value) =>
                          widget.onChanged(value, originalIndex),
                      deleteFunction: () => widget.onDelete(originalIndex),
                      editFunction: () => widget.onEdit(originalIndex),
                      isPinned: isPinned,
                      onPin: () {
                        widget.onPin(originalIndex, !isPinned);
                        setState(() {});
                        _scrollController.animateTo(
                          0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
