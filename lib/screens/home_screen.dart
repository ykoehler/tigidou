import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list_item.dart';
import '../utils/tool_parser.dart';
import 'package:tigidou/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          // FocusScope.of(context).unfocus(); // Optional: keep focus?
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Provider.of<TodoProvider>(
                    context,
                    listen: false,
                  ).addTodo(value, null);
                  _searchController.clear();
                }
              },
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

                // Filter todos
                final filteredTodos = todos.where((todo) {
                  return todo.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                }).toList();

                if (filteredTodos.isEmpty) {
                  if (_searchQuery.isNotEmpty) {
                    // Parse the query to get a derived date
                    final parsedResult = ToolParser.parse(_searchQuery);
                    final draftTodo = Todo(
                      id: 'draft',
                      title: _searchQuery,
                      isCompleted: false,
                      dueDate: parsedResult.derivedDate,
                      userId: '', // Draft not saved yet
                    );

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              l10n.newTodoPreview,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ),
                          // Show the draft item
                          // We force it expanded so user sees details immediately
                          // TodoListItem manages its own expansion state, but we can't easily force it open from here
                          // without a key or changing its API.
                          // However, since it's a new widget every time query changes (key changes or rebuilt),
                          // we can default it to expanded if we want?
                          // For now, let's just show it. User can expand it.
                          // Actually user said "display todo expanded view".
                          // Let's modify TodoListItem to accept `initiallyExpanded`?
                          // Or just rely on the fact that it's a preview.
                          Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: TodoListItem(
                              key: const ValueKey('draft'),
                              todo: draftTodo,
                              readOnly: true,
                              initiallyExpanded: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<TodoProvider>(
                                context,
                                listen: false,
                              ).addTodo(_searchQuery, null);
                              _searchController.clear();
                            },
                            child: Text(l10n.createTodo),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(child: Text(l10n.noTodos));
                }

                return ListView.builder(
                  itemCount: filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = filteredTodos[index];
                    return TodoListItem(
                      key: ValueKey(
                        todo.id,
                      ), // Important for state preservation
                      todo: todo,
                      onTap: () {
                        if (_searchQuery.isNotEmpty) {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        tooltip: l10n.addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.addTodoDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: l10n.addTodoHint),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  // Pass null for manual dueDate since we parse it from text now
                  Provider.of<TodoProvider>(
                    context,
                    listen: false,
                  ).addTodo(controller.text, null);
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }
}
