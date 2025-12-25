import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list_item.dart';
import '../widgets/suggestion_overlay.dart';
import '../utils/tool_parser.dart';
import 'package:tigidou/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CompositedTransformTarget(
                link: _layerLink,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
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
                      _searchFocusNode.requestFocus();
                    }
                  },
                ),
              ),
              SuggestionOverlay(
                controller: _searchController,
                focusNode: _searchFocusNode,
                layerLink: _layerLink,
                onSuggestionSelected: () {
                  setState(() {
                    _searchQuery = _searchController.text;
                  });
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

              // Filter todos based on search query
              final filteredTodos = todos.where((todo) {
                return todo.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
              }).toList();

              // If list is empty, decide what to show
              if (filteredTodos.isEmpty) {
                // Case 1: Search query is active - show live preview
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
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
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

                // Case 2: Search query is empty, and list is empty
                final activeTodos = todos.where((t) => !t.isCompleted).toList();
                if (activeTodos.isEmpty) {
                  return Align(
                    alignment: const Alignment(0, -0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.itsBrand,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w300,
                                ),
                          ),
                          Image.asset(
                            'assets/images/logo_banner.png',
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }

              return ListView.builder(
                itemCount: filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = filteredTodos[index];
                  return TodoListItem(
                    key: ValueKey(todo.id),
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
    );
  }
}
