import 'package:flutter/material.dart';
import 'package:assignments/constants/colors.dart';
import 'package:assignments/data/database.dart';

import 'package:assignments/util/todo_tile_flat.dart';
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

  bool _showSearch = false;
  String _searchQuery = '';
  bool _sortNewestFirst = true;

  List filteredList({bool sortPinnedFirst = false}) {
    List tasks = _searchQuery.isEmpty
        ? widget.db.toDoList.toList()
        : widget.db.toDoList.where((task) {
            final title = task[0].toString().toLowerCase();
            final content = task[1].toString().toLowerCase();
            return title.contains(_searchQuery.toLowerCase()) ||
                content.contains(_searchQuery.toLowerCase());
          }).toList();
    if (_sortNewestFirst) {
      tasks = tasks.reversed.toList();
    }
    if (sortPinnedFirst) {
      tasks.sort((a, b) {
        // Pinned tasks come first
        final aPinned = a.length > 4 && a[4] == true ? 1 : 0;
        final bPinned = b.length > 4 && b[4] == true ? 1 : 0;
        if (aPinned != bPinned) {
          return bPinned.compareTo(aPinned);
        }
        // Completed tasks go to the bottom
        final aCompleted = a.length > 3 && a[3] == true ? 1 : 0;
        final bCompleted = b.length > 3 && b[3] == true ? 1 : 0;
        return aCompleted.compareTo(bCompleted);
      });
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
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
          const SizedBox(width: 16),
          PopupMenuButton<bool>(
            color: Colors.black,
            onSelected: (value) {
              setState(() {
                _sortNewestFirst = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
              const PopupMenuItem<bool>(
                value: true,
                child: Text('Newest First', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<bool>(
                value: false,
                child: Text('Oldest First', style: TextStyle(color: Colors.white)),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'Sort',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
            child: Builder(
              builder: (context) {
                final sortedTasks = filteredList(sortPinnedFirst: true);
                return ReorderableListView.builder(
                  padding: const EdgeInsets.only(top: 15, bottom: 40),
                  itemCount: sortedTasks.length,
                  proxyDecorator: (Widget child, int index, Animation<double> animation) {
                    return Material(
                      type: MaterialType.transparency,
                      elevation: 0,
                      child: Stack(
                        children: [
                          child,
                          Positioned(
                            left: 10,
                            right: 10,
                            top: 10,
                            bottom: 0,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.greenAccent, width: 2.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      
                      final task = sortedTasks[oldIndex];
                      final originalOldIndex = widget.db.toDoList.indexOf(task);
                      
                      // Calculate the insertion point by manipulating the underlying db.toDoList 
                      // based on relative positions in sortedTasks.
                      final item = widget.db.toDoList.removeAt(originalOldIndex);
                      
                      // Re-build sortedTasks without the removed item to find the correct insertion point
                      final updatedSorted = List.from(sortedTasks)..removeAt(oldIndex);
                      
                      // Auto pin/unpin based on drop location
                      bool newPinStatus = false;
                      if (newIndex >= updatedSorted.length) {
                        if (updatedSorted.isNotEmpty) {
                          final lastTask = updatedSorted.last;
                          newPinStatus = lastTask.length > 4 && lastTask[4] == true;
                        }
                      } else {
                        final anchorTask = updatedSorted[newIndex];
                        newPinStatus = anchorTask.length > 4 && anchorTask[4] == true;
                      }
                      
                      while (item.length <= 4) {
                        item.add(false);
                      }
                      item[4] = newPinStatus;
                      if (newIndex >= updatedSorted.length) {
                        // Drop at end
                        if (_sortNewestFirst) {
                          widget.db.toDoList.insert(0, item);
                        } else {
                          widget.db.toDoList.add(item);
                        }
                      } else {
                        final anchorTask = updatedSorted[newIndex];
                        final anchorOriginalIndex = widget.db.toDoList.indexOf(anchorTask);
                        if (_sortNewestFirst) {
                           widget.db.toDoList.insert(anchorOriginalIndex + 1, item);
                        } else {
                           widget.db.toDoList.insert(anchorOriginalIndex, item);
                        }
                      }
                      
                      widget.db.updateDataBase();
                    });
                  },
                  itemBuilder: (context, index) {
                    final task = sortedTasks[index];
                    final originalIndex = widget.db.toDoList.indexOf(task);
                    final isPinned = task.length > 4 && task[4] == true;

                    return ToDoTileFlat(
                      key: ValueKey(task),
                      taskTitle: task[0],
                      taskContent: task[1],
                      taskDateTime: task[2],
                      taskCompleted: task[3],
                      onChanged: (value) {
                        widget.onChanged(value, originalIndex);
                        setState(() {});
                      },
                      deleteFunction: () {
                        widget.onDelete(originalIndex);
                        setState(() {});
                      },
                      editFunction: () async {
                        await widget.onEdit(originalIndex);
                        setState(() {});
                      },
                      isPinned: isPinned,
                      onPin: () {
                        widget.onPin(originalIndex, !isPinned);
                        setState(() {});
                      },
                      onTap: () async {
                        await widget.onEdit(originalIndex);
                        setState(() {});
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
