import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list_item.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/suggestion_overlay.dart';
import 'package:tigidou/l10n/app_localizations.dart';

class CategoryScreen extends StatefulWidget {
  final String title;
  final String? tagFilter;
  final String? typeFilter;

  const CategoryScreen({
    super.key,
    required this.title,
    this.tagFilter,
    this.typeFilter,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onAddTodo() {
    final text = _searchController.text;
    if (text.isEmpty) {
      // Pre-fill with our filter if empty
      final prefix = widget.typeFilter != null ? '!' : '#';
      final filter = widget.typeFilter ?? widget.tagFilter ?? '';
      _searchController.text = ' $prefix$filter';
      _searchController.selection = const TextSelection.collapsed(offset: 0);
      _searchFocusNode.requestFocus();
    } else {
      Provider.of<TodoProvider>(context, listen: false).addTodo(text, null);
      _searchController.clear();
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hideTags = <String>[];
    if (widget.tagFilter != null) hideTags.add(widget.tagFilter!);
    if (widget.typeFilter != null) {
      if (widget.typeFilter!.contains('.')) {
        hideTags.addAll(widget.typeFilter!.split('.'));
      } else {
        hideTags.add(widget.typeFilter!);
      }
    }

    return GradientScaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _onAddTodo),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Column(
              children: [
                CompositedTransformTarget(
                  link: _layerLink,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _onAddTodo();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                SuggestionOverlay(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  layerLink: _layerLink,
                  onSuggestionSelected: () {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Todo>>(
              stream: Provider.of<TodoProvider>(context).todos,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(l10n.error(snapshot.error.toString())),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final todos = snapshot.data ?? [];
                final filteredTodos = todos.where((todo) {
                  bool matches = true;
                  if (widget.tagFilter != null) {
                    matches = matches && todo.tags.contains(widget.tagFilter);
                  }
                  if (widget.typeFilter != null) {
                    matches =
                        matches &&
                        (todo.recordType?.startsWith(widget.typeFilter!) ??
                            false);
                  }

                  // Apply search query filter
                  if (_searchQuery.isNotEmpty) {
                    final normalizedQuery = _searchQuery.toLowerCase();
                    if (!normalizedQuery.startsWith('#') &&
                        !normalizedQuery.startsWith('@') &&
                        !normalizedQuery.startsWith('!')) {
                      matches =
                          matches &&
                          todo.title.toLowerCase().contains(normalizedQuery);
                    }
                  }

                  return matches;
                }).toList();

                if (filteredTodos.isEmpty) {
                  return Center(
                    child: Text(
                      'No items found for ${widget.title}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = filteredTodos[index];
                    return TodoListItem(
                      key: ValueKey(todo.id),
                      todo: todo,
                      hideTags: hideTags,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
