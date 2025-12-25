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
  final List<String> hideTags;

  const TodoListItem({
    super.key,
    required this.todo,
    this.onTap,
    this.readOnly = false,
    this.initiallyExpanded = false,
    this.hideTags = const [],
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
    final allTodos = Provider.of<TodoProvider>(context).allTodos;
    final l10n = AppLocalizations.of(context)!;

    // Dynamic Smart Lookup Logic
    String? bestPriceText;
    if (!widget.todo.isCompleted) {
      final itemName = widget.todo.title
          .replaceAll(RegExp(r'(@|#|!|\$)[a-zA-Z0-9:\-\.]+'), '')
          .replaceAll(
            RegExp(r'\b(\d+(\.\d+)?)(x|qty)\b|\bq:(\d+(\.\d+)?)\b'),
            '',
          )
          .trim();

      if (itemName.isNotEmpty) {
        // Find all categories for this item (hashtags)
        final categories = widget.todo.tags.toList();

        Todo? bestPriceTodo;
        String? bestStoreName;

        for (final category in categories) {
          // Find stores for this category (recordType == store.category)
          final storeRecords = allTodos
              .where((t) => t.recordType == 'store.$category')
              .toList();
          final storeNames = storeRecords.map((s) {
            return s.title
                .replaceAll(RegExp(r'(@|#|!|\$)[a-zA-Z0-9:\-\.]+'), '')
                .trim();
          }).toList();

          if (storeNames.isEmpty) continue;

          for (final other in allTodos) {
            if (other.id == widget.todo.id) continue;
            if (other.price == null) continue;

            final otherName = other.title
                .replaceAll(RegExp(r'(@|#|!|\$)[a-zA-Z0-9:\-\.]+'), '')
                .replaceAll(
                  RegExp(r'\b(\d+(\.\d+)?)(x|qty)\b|\bq:(\d+(\.\d+)?)\b'),
                  '',
                )
                .trim();

            if (otherName.toLowerCase() == itemName.toLowerCase()) {
              // Check if this priced todo mentions one of the stores for this category
              for (final storeName in storeNames) {
                if (other.title.toLowerCase().contains(
                  storeName.toLowerCase(),
                )) {
                  if (bestPriceTodo == null ||
                      other.price! < bestPriceTodo.price!) {
                    bestPriceTodo = other;
                    bestStoreName = storeName;
                  }
                }
              }
            }
          }
        }

        if (bestPriceTodo != null && bestStoreName != null) {
          bestPriceText =
              'Best: \$${bestPriceTodo.price!.toStringAsFixed(2)} at $bestStoreName';
        }
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          if (bestPriceText != null)
            Padding(
              padding: const EdgeInsets.only(left: 72.0, bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      bestPriceText,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
                      l10n.due(
                        DateFormat(
                          'MMM d, y h:mm a',
                        ).format(widget.todo.dueDate!),
                      ),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l10n.reminder,
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
                      child: Text(l10n.setDueDate),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l10n.reminderSetDateFirst,
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
      // Check if this tag should be hidden
      final tagData = tag.data.toLowerCase();
      if (widget.hideTags.any((ht) => ht.toLowerCase() == tagData)) {
        // Add text before the hidden tag
        if (tag.startIndex > currentIndex) {
          spans.add(
            TextSpan(text: text.substring(currentIndex, tag.startIndex)),
          );
        }
        // Skip this tag
        currentIndex = tag.endIndex;
        // If there's a space after the tag, skip it too for cleaner UI
        if (currentIndex < text.length && text[currentIndex] == ' ') {
          currentIndex++;
        }
        continue;
      }

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
      } else if (tag.type == ToolType.recordType) {
        color = Colors.purpleAccent;
      } else if (tag.type == ToolType.price) {
        color = Colors.green;
      } else if (tag.type == ToolType.quantity) {
        color = Colors.blueGrey;
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
