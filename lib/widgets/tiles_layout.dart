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

  const TilesLayout({
    super.key,
    required this.db,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onPin,
  });

  @override
  State<TilesLayout> createState() => _TilesLayoutState();
}

class _TilesLayoutState extends State<TilesLayout> {
  bool _showGridView = false;
  bool _showSearch = false;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final filteredList = _searchQuery.isEmpty
        ? widget.db.toDoList
        : widget.db.toDoList.where((task) {
            final title = task[0].toString().toLowerCase();
            final content = task[1].toString().toLowerCase();
            return title.contains(_searchQuery.toLowerCase()) ||
                content.contains(_searchQuery.toLowerCase());
          }).toList();

    filteredList.sort((a, b) {
      final aPinned = a.length > 4 && a[4] == true;
      final bPinned = b.length > 4 && b[4] == true;
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0;
    });

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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: !_showGridView
              ? Padding(
                  padding: const EdgeInsets.only(top: 0.0, bottom: 25.0),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final originalIndex =
                          widget.db.toDoList.indexOf(filteredList[index]);
                      final isPinned = filteredList[index].length > 4 &&
                          filteredList[index][4] == true;
                      return SizedBox(
                        width: 300, // card width
                        height: 200, // collapsed card height
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ToDoTile(
                              taskTitle: filteredList[index][0],
                              taskContent: filteredList[index][1],
                              taskDateTime: filteredList[index][2],
                              taskCompleted: filteredList[index][3],
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => TaskDetailPage(
                                        task: filteredList[index]),
                                    transitionsBuilder:
                                        (_, animation, __, child) {
                                      const begin = Offset(0.0, 0.1);
                                      const end = Offset.zero;
                                      final slide =
                                          Tween(begin: begin, end: end).chain(
                                              CurveTween(
                                                  curve: Curves.easeOut));
                                      final fade = CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeIn);

                                      return SlideTransition(
                                        position: animation.drive(slide),
                                        child: FadeTransition(
                                            opacity: fade, child: child),
                                      );
                                    },
                                  ),
                                );
                              }),
                        ),
                      );
                    },
                  ),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: GridView.builder(
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
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final originalIndex =
                          widget.db.toDoList.indexOf(filteredList[index]);
                      final isPinned = filteredList[index].length > 4 &&
                          filteredList[index][4] == true;
                      return ToDoTileShrinked(
                        taskTitle: filteredList[index][0],
                        taskDateTime: filteredList[index][2],
                        taskCompleted: filteredList[index][3],
                        onChanged: (value) =>
                            widget.onChanged(value, originalIndex),
                        deleteFunction: () => widget.onDelete(originalIndex),
                        editFunction: () => widget.onEdit(originalIndex),
                        isPinned: isPinned,
                        onPin: () {
                          widget.onPin(originalIndex, !isPinned);
                          setState(() {});
                          // Scroll to start after pin/unpin
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
        ),
      ],
    );
  }
}


// ListView.builder(
//                   controller: _scrollController,
//                   scrollDirection: Axis.horizontal,
//                   itemCount: filteredList.length,
//                   itemBuilder: (context, index) {
//                     final originalIndex =
//                         widget.db.toDoList.indexOf(filteredList[index]);
//                     final isPinned = filteredList[index].length > 4 &&
//                         filteredList[index][4] == true;
//                     return SizedBox(
//                       width: 300, // card width
//                       height: 250, // collapsed card height
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ToDoTile(
//                           index: originalIndex, // needed for Hero tag
//                           taskTitle: filteredList[index][0],
//                           taskContent: filteredList[index][1],
//                           taskDateTime: filteredList[index][2],
//                           taskCompleted: filteredList[index][3],
//                           onChanged: (value) =>
//                               widget.onChanged(value, originalIndex),
//                           deleteFunction: () => widget.onDelete(originalIndex),
//                           editFunction: () => widget.onEdit(originalIndex),
//                           isPinned: isPinned,
//                           onPin: () {
//                             widget.onPin(originalIndex, !isPinned);
//                             setState(() {});
//                             _scrollController.animateTo(
//                               0.0,
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeOut,
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 )