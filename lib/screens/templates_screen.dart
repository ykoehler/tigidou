import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import 'package:tigidou/l10n/app_localizations.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return StreamBuilder<List<Todo>>(
          stream: todoProvider.todos,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(l10n.somethingWentWrong));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allRecords = snapshot.data ?? [];
            final dbTemplates = allRecords.where((record) {
              return record.recordType == 'template';
            }).toList();

            // Ensure default todo template is always visible
            final templateRecords = [...dbTemplates];
            if (!templateRecords.any(
              (t) => t.title.toLowerCase().contains('todo'),
            )) {
              templateRecords.add(
                Todo(
                  id: 'default_todo',
                  title:
                      'Default Todo !template { layout: "row", fields: ["title", "qty:right"] }',
                  isCompleted: false,
                  userId: 'system',
                  recordType: 'template',
                  tags: ['todo'],
                ),
              );
            }

            if (templateRecords.isEmpty) {
              return const Center(child: Text('No Views defined yet.'));
            }

            return ListView.builder(
              itemCount: templateRecords.length,
              itemBuilder: (context, index) {
                final record = templateRecords[index];
                return ListTile(
                  title: Text(record.title),
                  subtitle: Text(
                    record.tags.isNotEmpty
                        ? '#${record.tags.join(', #')}'
                        : 'Global',
                  ),
                  leading: const Icon(
                    Icons.visibility_outlined,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    // Navigate to template editor?
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
