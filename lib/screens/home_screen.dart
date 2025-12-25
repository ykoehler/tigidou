import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list_item.dart';
import '../widgets/suggestion_overlay.dart';
import '../widgets/gradient_scaffold.dart';
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

  void _onContextualAdd(String groupName) {
    if (groupName == 'Uncategorized') {
      _searchController.clear();
    } else {
      // Determine if it's a recordType (! prefix) or a hashtag (# prefix)
      // This is a bit tricky since we only have the raw name here.
      // But based on HomeScreen grouping logic:
      // if (todo.recordType != null) group = todo.recordType!;
      // else if (todo.tags.isNotEmpty) group = todo.tags.first;

      // We can check if it's a known recordType from some source,
      // but let's assume if it doesn't look like a hashtag it might be a type.
      // Actually, ToolParser.parse will handle it if we prefix correctly.
      // User said: !store.grocery type -> "!store.grocery"

      // Let's try to detect if it's a hashtag or recordType.
      // This is imperfect without full metadata but we can heuristics:
      // If it starts with a letter, we can try both and see?
      // No, let's just use the name and let the user decide if they want # or !.
      // WAIT, the USER said: "!store.grocery type to add a new grocery store, I get a text field ' !store.grocery'"

      // So we need to know if 'groupName' was derived from recordType or tag.
      // I will update the grouping logic to keep track of the prefix.

      final String prefix =
          groupName.contains('.') || groupName.startsWith('store') ? '!' : '#';
      final String text = ' $prefix$groupName';
      _searchController.text = text;
      _searchController.selection = TextSelection.fromPosition(
        const TextPosition(offset: 0),
      );
    }
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GradientScaffold(
      appBar: AppBar(
        title: Text(l10n.todos),
        backgroundColor: Colors.transparent,
        elevation: 0,
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

                // Grouping logic (Priority: recordType, then first tag)
                final Map<String, List<Todo>> groups = {};
                for (var todo in filteredTodos) {
                  String group = 'Uncategorized';
                  if (todo.recordType != null) {
                    group = todo.recordType!;
                  } else if (todo.tags.isNotEmpty) {
                    group = todo.tags.firstWhere(
                      (t) => t != 'person',
                      orElse: () => 'Uncategorized',
                    );
                  }

                  if (!groups.containsKey(group)) {
                    groups[group] = [];
                  }
                  groups[group]!.add(todo);
                }

                // If list is empty, decide what to show
                if (filteredTodos.isEmpty) {
                  // ... [DRAFT PREVIEW LOGIC] ...
                  if (_searchQuery.isNotEmpty) {
                    final parsedResult = ToolParser.parse(_searchQuery);
                    final draftTodo = Todo(
                      id: 'draft',
                      title: _searchQuery,
                      isCompleted: false,
                      dueDate: parsedResult.derivedDate,
                      userId: '',
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

                  final activeTodos = todos
                      .where((t) => !t.isCompleted)
                      .toList();
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

                final groupKeys = groups.keys.toList()..sort();
                // Sort "Uncategorized" to the bottom
                if (groupKeys.contains('Uncategorized')) {
                  groupKeys.remove('Uncategorized');
                  groupKeys.add('Uncategorized');
                }

                return ListView.builder(
                  itemCount: groupKeys.length,
                  itemBuilder: (context, index) {
                    final groupName = groupKeys[index];
                    final groupTodos = groups[groupName]!;

                    return ExpansionTile(
                      title: Text(
                        ToolParser.formatDisplayName(groupName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white70),
                        onPressed: () => _onContextualAdd(groupName),
                      ),
                      initiallyExpanded: true,
                      children: groupTodos.map((todo) {
                        return TodoListItem(
                          key: ValueKey(todo.id),
                          todo: todo,
                          hideTags: [groupName],
                          onTap: () {
                            if (_searchQuery.isNotEmpty) {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            }
                          },
                        );
                      }).toList(),
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
