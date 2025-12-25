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

  patrolTest('validate unified tagging and hierarchical groups', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    final l10n = AppLocalizations.of($.tester.element(find.byType(MyApp)))!;

    // 1. SETUP: Authenticate with test account
    await $(l10n.noAccount).tap();
    await $.pumpAndSettle();

    final testEmail =
        'tag-test-${DateTime.now().millisecondsSinceEpoch}@example.com';
    await $(l10n.email).enterText(testEmail);
    await $(l10n.password).enterText('password123');
    await $(l10n.confirmPassword).enterText('password123');
    await $(l10n.register).tap();
    await $.pumpAndSettle();

    // 2. TEST: Hierarchical Tagging & Focus Retention
    const hierarchicalTodo = 'Buy cake #wedding.iga';
    await $(l10n.searchHint).enterText(hierarchicalTodo);
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
    await $.pumpAndSettle();

    // Verify record is created
    expect($(hierarchicalTodo), findsOneWidget);

    // Verify search bar focus retention (TextField should be clear and focused)
    final textField = $.tester.widget<TextField>($(TextField));
    expect(textField.controller?.text, isEmpty);
    // Note: In E2E, checking focus node status can be tricky, but we can verify text is gone.

    // 3. TEST: Search/Filter for hierarchies
    // Search for top-level #wedding
    await $(l10n.searchHint).enterText('#wedding');
    await $.pumpAndSettle();
    expect($(hierarchicalTodo), findsOneWidget);

    // Search for subgroup #iga
    await $(l10n.searchHint).enterText('#iga');
    await $.pumpAndSettle();
    expect($(hierarchicalTodo), findsOneWidget);

    // 4. TEST: @mention to People page mapping
    await $(l10n.searchHint).enterText(''); // Clear search
    await $.pumpAndSettle();

    const mentionTodo = 'Call @father about dinner';
    await $(l10n.searchHint).enterText(mentionTodo);
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
    await $.pumpAndSettle();

    // Navigate to People page
    await $(l10n.people).tap();
    await $.pumpAndSettle();

    // Verify it appears on the People page
    expect($(mentionTodo), findsOneWidget);

    // 5. TEST: #person tag to People page mapping
    await $(l10n.todos).tap(); // Back to todos
    await $.pumpAndSettle();

    const personTagTodo = 'Renew passport #person.admin';
    await $(l10n.searchHint).enterText(personTagTodo);
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
    await $.pumpAndSettle();

    await $(l10n.people).tap(); // Navigate to People
    await $.pumpAndSettle();

    expect($(personTagTodo), findsOneWidget);
  });
}
