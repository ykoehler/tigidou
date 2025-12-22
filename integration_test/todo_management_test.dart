import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tigidou/app.dart';
import 'package:tigidou/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tigidou/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      const host = String.fromEnvironment(
        'FIREBASE_EMULATOR_HOST',
        defaultValue: 'localhost',
      );
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  patrolTest('comprehensive todo CRUD operations', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    final l10n = AppLocalizations.of($.tester.element(find.byType(MyApp)))!;

    // ========================================
    // SETUP: Authenticate with test account
    // ========================================
    await $(l10n.noAccount).tap();
    await $.pumpAndSettle();

    final testEmail =
        'todo-crud-${DateTime.now().millisecondsSinceEpoch}@example.com';
    await $(l10n.email).enterText(testEmail);
    await $(l10n.password).enterText('password123');
    await $(l10n.confirmPassword).enterText('password123');
    await $(l10n.register).tap();

    await $.pumpAndSettle();
    expect($(l10n.todos), findsOneWidget);

    // ========================================
    // CREATE: Test creating todos
    // ========================================

    // Test 1: Create todo via FAB (Floating Action Button)
    await $(Icons.add).tap();
    await $.pumpAndSettle();
    expect($(l10n.addTodoDialogTitle), findsOneWidget);

    const todo1Title = 'Buy groceries';
    await $(l10n.addTodoHint).enterText(todo1Title);
    await $(l10n.add).tap();
    await $.pumpAndSettle();

    expect($(todo1Title), findsOneWidget);

    // Test 2: Create todo with NLP parsing via search bar
    const todo2Title = 'Call dentist @tomorrow @14:00';
    await $(l10n.searchHint).enterText(todo2Title);
    await $.pumpAndSettle();

    // Should show preview
    expect($(l10n.newTodoPreview), findsOneWidget);
    expect($(todo2Title), findsOneWidget);

    // Create from preview
    await $(l10n.createTodo).tap();
    await $.pumpAndSettle();

    expect($(l10n.newTodoPreview), findsNothing);
    expect($(todo2Title), findsOneWidget);

    // Test 3: Create todo with date format
    const todo3Title = 'Submit report @date:2025-12-25';
    await $(Icons.add).tap();
    await $.pumpAndSettle();
    await $(l10n.addTodoHint).enterText(todo3Title);
    await $(l10n.add).tap();
    await $.pumpAndSettle();

    expect($(todo3Title), findsOneWidget);

    // ========================================
    // READ: Verify todos are displayed
    // ========================================
    expect($(todo1Title), findsOneWidget);
    expect($(todo2Title), findsOneWidget);
    expect($(todo3Title), findsOneWidget);

    // Test search functionality
    await $(l10n.searchHint).enterText('dentist');
    await $.pumpAndSettle();

    expect($(todo2Title), findsOneWidget);
    expect($(todo1Title), findsNothing); // Filtered out

    // Clear search
    final clearButton = find.descendant(
      of: find.byType(TextField),
      matching: find.byIcon(Icons.clear),
    );
    await $.tester.tap(clearButton);
    await $.pumpAndSettle();

    // ========================================
    // UPDATE: Test updating todos
    // ========================================

    // Test 4: Toggle completion status
    // Find the checkbox for the first todo
    final todo1Finder = $(todo1Title);
    expect(todo1Finder, findsOneWidget);

    // Find the checkbox associated with this todo
    final checkboxFinder = find
        .ancestor(of: todo1Finder, matching: find.byType(ListTile))
        .first;

    // Tap the checkbox
    final checkbox = find.descendant(
      of: checkboxFinder,
      matching: find.byType(Checkbox),
    );
    await $.tester.tap(checkbox);
    await $.pumpAndSettle();

    // Verify the todo is marked as completed (has strikethrough)
    // The checkbox should now be checked
    final checkboxWidget = $.tester.widget<Checkbox>(checkbox);
    expect(checkboxWidget.value, true);

    // Toggle it back
    await $.tester.tap(checkbox);
    await $.pumpAndSettle();
    final checkboxWidget2 = $.tester.widget<Checkbox>(checkbox);
    expect(checkboxWidget2.value, false);

    // Test 5: Update due date (expand and set date)
    // First, expand the todo item to access date controls
    final todo1ListTile = find
        .ancestor(of: $(todo1Title), matching: find.byType(ListTile))
        .first;

    // Look for the expand/collapse button
    final expandButton = find.descendant(
      of: todo1ListTile,
      matching: find.byIcon(Icons.add),
    );

    // Only tap if the button exists
    if ($.tester.any(expandButton)) {
      await $.tester.tap(expandButton);
      await $.pumpAndSettle();
    } else {
      // Try tapping the list tile itself to expand
      await $.tester.tap(todo1ListTile);
      await $.pumpAndSettle();
    }

    // Now we should see the "Set due date" button since this todo has no date
    expect($(l10n.setDueDate), findsWidgets);

    // ========================================
    // DELETE: Test deleting todos
    // ========================================

    // Test 6: Delete a todo
    final deleteButton = find.descendant(
      of: find.ancestor(of: $(todo3Title), matching: find.byType(ListTile)),
      matching: find.byIcon(Icons.delete),
    );

    await $.tester.tap(deleteButton);
    await $.pumpAndSettle();

    // Verify the todo is deleted
    expect($(todo3Title), findsNothing);

    // Verify other todos still exist
    expect($(todo1Title), findsOneWidget);
    expect($(todo2Title), findsOneWidget);

    // Test 7: Delete all remaining todos
    final deleteButton2 = find.descendant(
      of: find.ancestor(of: $(todo2Title), matching: find.byType(ListTile)),
      matching: find.byIcon(Icons.delete),
    );
    await $.tester.tap(deleteButton2);
    await $.pumpAndSettle();

    final deleteButton3 = find.descendant(
      of: find.ancestor(of: $(todo1Title), matching: find.byType(ListTile)),
      matching: find.byIcon(Icons.delete),
    );
    await $.tester.tap(deleteButton3);
    await $.pumpAndSettle();

    // Verify all todos are deleted and we see the empty state
    expect($(l10n.noTodos), findsOneWidget);

    // ========================================
    // PERSISTENCE: Verify data persists
    // ========================================

    // Create a new todo
    const persistentTodo = 'Test persistence';
    await $(Icons.add).tap();
    await $.pumpAndSettle();
    await $(l10n.addTodoHint).enterText(persistentTodo);
    await $(l10n.add).tap();
    await $.pumpAndSettle();

    expect($(persistentTodo), findsOneWidget);

    // Logout
    await $(Icons.logout).tap();
    await $.pumpAndSettle();

    // Login again
    await $(l10n.email).enterText(testEmail);
    await $(l10n.password).enterText('password123');
    await $(l10n.login).tap();
    await $.pumpAndSettle();

    // Verify the persistent todo is still there
    expect($(persistentTodo), findsOneWidget);
  });
}
