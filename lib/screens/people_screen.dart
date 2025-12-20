import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/person_provider.dart';
import '../providers/todo_provider.dart';
import '../models/person_model.dart';
import '../models/todo_model.dart';
import 'package:tigidou/l10n/app_localizations.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.people)),
      body: Consumer<PersonProvider>(
        builder: (context, personProvider, child) {
          return StreamBuilder<List<Person>>(
            stream: personProvider.people,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(l10n.somethingWentWrong));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final people = snapshot.data ?? [];

              if (people.isEmpty) {
                return Center(child: Text(l10n.noPeople));
              }

              return ListView.builder(
                itemCount: people.length,
                itemBuilder: (context, index) {
                  final person = people[index];
                  return PersonListItem(person: person);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPersonDialog(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController displayNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.addPersonDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(hintText: l10n.usernameHint),
              ),
              TextField(
                controller: displayNameController,
                decoration: InputDecoration(hintText: l10n.displayNameHint),
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
                if (usernameController.text.isNotEmpty &&
                    displayNameController.text.isNotEmpty) {
                  Provider.of<PersonProvider>(context, listen: false).addPerson(
                    usernameController.text,
                    displayNameController.text,
                  );
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

class PersonListItem extends StatefulWidget {
  final Person person;

  const PersonListItem({super.key, required this.person});

  @override
  State<PersonListItem> createState() => _PersonListItemState();
}

class _PersonListItemState extends State<PersonListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.person.displayName),
          subtitle: Text('@${widget.person.username}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  Provider.of<PersonProvider>(
                    context,
                    listen: false,
                  ).deletePerson(widget.person.id);
                },
              ),
            ],
          ),
        ),
        if (_isExpanded)
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              return StreamBuilder<List<Todo>>(
                stream: todoProvider.todos,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final allTodos = snapshot.data!;
                  // Filter todos that contain @username
                  // We should probably use ToolParser to be accurate, or just string check for now.
                  // String check might match partials (e.g. @father matches @grandfather).
                  // Better to use ToolParser or regex.
                  // Regex: @username\b

                  final regex = RegExp(
                    r'@' + RegExp.escape(widget.person.username) + r'\b',
                    caseSensitive: false,
                  );

                  final associatedTodos = allTodos
                      .where((todo) => regex.hasMatch(todo.title))
                      .toList();

                  if (associatedTodos.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        AppLocalizations.of(context)!.noAssociatedTodos,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    children: associatedTodos.map((todo) {
                      return ListTile(
                        title: Text(todo.title),
                        leading: const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.only(
                          left: 32.0,
                          right: 16.0,
                        ),
                        onTap: () {
                          // Navigate to todo? Or just show it.
                          // For now just show it.
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
