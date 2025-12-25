import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../utils/tool_parser.dart';
import 'package:tigidou/l10n/app_localizations.dart';

class TodoListItem extends StatefulWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool initiallyExpanded;

  const TodoListItem({
    super.key,
    required this.todo,
    this.onTap,
    this.readOnly = false,
    this.initiallyExpanded = false,
  });

  @override
  State<TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends State<TodoListItem> {
  late bool _isExpanded;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final parsedResult = ToolParser.parse(widget.todo.title);
    final tags = parsedResult.tags;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              widget.onTap?.call();
            },
            leading: Checkbox(
              value: widget.todo.isCompleted,
              onChanged: widget.readOnly
                  ? null
                  : (bool? value) {
                      Provider.of<TodoProvider>(
                        context,
                        listen: false,
                      ).toggleTodoStatus(widget.todo);
                    },
            ),
            title: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                  decoration: widget.todo.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
                children: _buildTextSpans(widget.todo.title, tags),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.todo.dueDate != null || _isHovered)
                  IconButton(
                    icon: Icon(_isExpanded ? Icons.remove : Icons.add),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                if (!widget.readOnly)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Provider.of<TodoProvider>(
                        context,
                        listen: false,
                      ).deleteTodo(widget.todo.id);
                    },
                  ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  if (widget.todo.dueDate != null) ...[
                    Text(
                      AppLocalizations.of(context)!.due(
                        DateFormat(
                          'MMM d, y h:mm a',
                        ).format(widget.todo.dueDate!),
                      ),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      AppLocalizations.of(context)!.reminder,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: widget.readOnly
                          ? null
                          : () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (!context.mounted) return;
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (!context.mounted) return;
                                if (time != null) {
                                  final newDueDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  final updatedTodo = Todo(
                                    id: widget.todo.id,
                                    title: widget.todo.title,
                                    isCompleted: widget.todo.isCompleted,
                                    dueDate: newDueDate,
                                    userId: widget.todo.userId,
                                    sharedWith: widget.todo.sharedWith,
                                    tags: widget.todo.tags,
                                  );
                                  Provider.of<TodoProvider>(
                                    context,
                                    listen: false,
                                  ).updateTodo(updatedTodo);
                                }
                              }
                            },
                      child: Text(AppLocalizations.of(context)!.setDueDate),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      AppLocalizations.of(context)!.reminderSetDateFirst,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildTextSpans(String text, List<ToolTag> tags) {
    if (tags.isEmpty) {
      return [TextSpan(text: text)];
    }

    List<InlineSpan> spans = [];
    int currentIndex = 0;

    for (var tag in tags) {
      if (tag.startIndex > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, tag.startIndex)));
      }

      Color color = Colors.grey;
      FontWeight fontWeight = FontWeight.bold;
      TapGestureRecognizer? recognizer;
      WidgetSpan? iconSpan;

      if (tag.type == ToolType.person) {
        color = Colors.blue;
      } else if (tag.type == ToolType.group) {
        color = Colors.orangeAccent;
      } else if (tag.type == ToolType.date || tag.type == ToolType.time) {
        color = Colors.green;
      } else if (tag.type == ToolType.unknown) {
        color = Colors.grey;
        // Error/Warning icon
        IconData icon = Icons.error_outline;
        Color iconColor = Colors.red;
        VoidCallback? onTap;

        if (tag.probableType == ToolType.date) {
          icon = Icons.calendar_today;
          iconColor = Colors.orange;
          onTap = () => _showDatePickerForTag(context);
        } else {
          // Generic unknown
          onTap = () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.unknownTagFormat),
              ),
            );
          };
        }

        iconSpan = WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(icon, size: 16, color: iconColor),
            ),
          ),
        );

        recognizer = TapGestureRecognizer()..onTap = onTap;
      }

      spans.add(
        TextSpan(
          text: text.substring(tag.startIndex, tag.endIndex),
          style: TextStyle(color: color, fontWeight: fontWeight),
          recognizer: recognizer,
        ),
      );

      if (iconSpan != null) {
        spans.add(iconSpan);
      }

      currentIndex = tag.endIndex;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  void _showDatePickerForTag(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (!context.mounted) return;
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (!context.mounted) return;
      if (time != null) {
        final newDueDate = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        final updatedTodo = Todo(
          id: widget.todo.id,
          title: widget.todo.title,
          isCompleted: widget.todo.isCompleted,
          dueDate: newDueDate,
          userId: widget.todo.userId,
          sharedWith: widget.todo.sharedWith,
          tags: widget.todo.tags,
        );
        Provider.of<TodoProvider>(
          context,
          listen: false,
        ).updateTodo(updatedTodo);
      }
    }
  }
}
