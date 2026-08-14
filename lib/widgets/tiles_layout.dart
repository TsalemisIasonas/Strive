import '../data/database.dart';
import '../util/todo_tile.dart';
import '../util/todo_tile_shrinked.dart';
import 'package:flutter/material.dart';
class TilesLayout extends StatefulWidget {
  final ToDoDataBase db;
  final Function(bool?, int) onChanged;
  final Function(int) onDelete;
  final Function(int) onEdit;
  final Function(int, bool) onPin;
  final Future<void> Function() onTap;

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
  final bool _showGridView = false;
  final bool _showSearch = false;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  List<List<dynamic>> _getTop4Tasks() {
    final filteredList = _searchQuery.isEmpty
        ? widget.db.toDoList
        : widget.db.toDoList.where((task) {
            final title = task[0].toString().toLowerCase();
            final content = task[1].toString().toLowerCase();
            return title.contains(_searchQuery.toLowerCase()) ||
                content.contains(_searchQuery.toLowerCase());
          }).toList();

    // Get all pinned tasks
    final pinnedTasks = filteredList
        .where((task) => task.length > 4 && task[4] == true)
        .toList()
        .reversed
        .toList();

    // Get remaining unpinned tasks, reversed so the most recently added are first
    final unpinnedTasks = filteredList
        .where((task) => !(task.length > 4 && task[4] == true))
        .toList()
        .reversed
        .toList();

    // Push completed unpinned tasks to the bottom
    unpinnedTasks.sort((a, b) {
      final aCompleted = a.length > 3 && a[3] == true ? 1 : 0;
      final bCompleted = b.length > 3 && b[3] == true ? 1 : 0;
      return aCompleted.compareTo(bCompleted);
    });

    // Combine and take up to 4 tasks
    final combined = [...pinnedTasks, ...unpinnedTasks];
    return combined.take(4).toList();
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
                        ? "Upcoming tasks"
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
                onPressed: () async {
                  await widget.onTap();
                  if (mounted) {
                    _scrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
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
                          showPin: true,
                          onTap: () async {
                            await widget.onEdit(originalIndex);
                            if (mounted) {
                              setState(() {});
                              _scrollController.animateTo(
                                0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
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
