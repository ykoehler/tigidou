import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import 'package:tigidou/l10n/app_localizations.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

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
            final peopleRecords = allRecords.where((record) {
              return record.tags.any(
                (tag) => tag == 'person' || tag.startsWith('person.'),
              );
            }).toList();

            if (peopleRecords.isEmpty) {
              return Center(child: Text(l10n.noPeople));
            }

            return ListView.builder(
              itemCount: peopleRecords.length,
              itemBuilder: (context, index) {
                final record = peopleRecords[index];
                return ListTile(
                  title: Text(record.title),
                  leading: const Icon(Icons.person, color: Colors.blueAccent),
                  onTap: () {
                    // Navigate to record details?
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
