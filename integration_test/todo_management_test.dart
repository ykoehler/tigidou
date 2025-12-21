import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tigidou/app.dart';
import 'package:tigidou/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  patrolTest('verify todo management: add via FAB and search bar preview', (
    $,
  ) async {
    await $.pumpWidgetAndSettle(const MyApp());

    final l10n = AppLocalizations.of($.tester.element(find.byType(MyApp)))!;

    // 1. Authenticate (using a test account)
    // Assuming the emulator is running and resets for each run.
    await $(l10n.noAccount).tap();
    await $.pumpAndSettle();

    final testEmail =
        'test-${DateTime.now().millisecondsSinceEpoch}@example.com';
    await $(l10n.email).enterText(testEmail);
    await $(l10n.password).enterText('password123');
    await $(l10n.confirmPassword).enterText('password123');
    await $(l10n.register).tap();

    // Wait for registration and auto-login to home
    await $.pumpAndSettle();
    expect($(l10n.todos), findsOneWidget);

    // 2. Add Todo via FAB
    await $(Icons.add).tap();
    await $.pumpAndSettle();
    expect($(l10n.addTodoDialogTitle), findsOneWidget);

    await $(l10n.addTodoHint).enterText('Buy milk @tomorrow');
    await $(l10n.add).tap();
    await $.pumpAndSettle();

    expect($('Buy milk @tomorrow'), findsOneWidget);

    // 3. Test Search Bar & Draft Preview (NLP)
    await $(l10n.searchHint).enterText('Call mom @date:2025-12-25 @10:00');
    await $.pumpAndSettle();

    // Should show the "New Todo Preview" because it's a unique query
    expect($(l10n.newTodoPreview), findsOneWidget);
    expect($('Call mom @date:2025-12-25 @10:00'), findsOneWidget);

    // Check if NLP parsed the date correctly in the expanded view
    // Since TodoListItem is initiallyExpanded: true in the preview
    expect(
      $('Dec 25, 2025 10:00 AM'),
      findsWidgets,
    ); // Might be multiple if another test ran

    // 4. Create Todo from Preview
    await $(l10n.createTodo).tap();
    await $.pumpAndSettle();

    // Search should be cleared, and new todo should be in list
    expect($(l10n.newTodoPreview), findsNothing);
    expect($('Call mom @date:2025-12-25 @10:00'), findsOneWidget);
  });
}
