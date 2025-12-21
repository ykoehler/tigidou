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

  patrolTest('verify security isolation between multiple users', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    final l10n = AppLocalizations.of($.tester.element(find.byType(MyApp)))!;

    // --- SETUP USER 1 ---
    await $(l10n.noAccount).tap();
    await $.pumpAndSettle();

    final user1Email =
        'user1-${DateTime.now().millisecondsSinceEpoch}@example.com';
    const user1TodoTitle = 'User1 Secret Todo';

    await $(l10n.email).enterText(user1Email);
    await $(l10n.password).enterText('password123');
    await $(l10n.confirmPassword).enterText('password123');
    await $(l10n.register).tap();
    await $.pumpAndSettle();

    // Verify User 1 is on Home Screen
    expect($(l10n.todos), findsOneWidget);

    // Create User 1 Todo
    await $(Icons.add).tap();
    await $.pumpAndSettle();
    await $(l10n.addTodoHint).enterText(user1TodoTitle);
    await $(l10n.add).tap();
    await $.pumpAndSettle();

    // Verify Todo A exists for User 1
    expect($(user1TodoTitle), findsOneWidget);

    // Logout User 1
    await $(Icons.logout).tap();
    await $.pumpAndSettle();

    // --- SETUP USER 2 ---
    await $(l10n.noAccount).tap();
    await $.pumpAndSettle();

    final user2Email =
        'user2-${DateTime.now().millisecondsSinceEpoch}@example.com';
    const user2TodoTitle = 'User2 Private Todo';

    await $(l10n.email).enterText(user2Email);
    await $(l10n.password).enterText('password123');
    await $(l10n.confirmPassword).enterText('password123');
    await $(l10n.register).tap();
    await $.pumpAndSettle();

    // Verify User 2 is on Home Screen
    expect($(l10n.todos), findsOneWidget);

    // Create User 2 Todo
    await $(Icons.add).tap();
    await $.pumpAndSettle();
    await $(l10n.addTodoHint).enterText(user2TodoTitle);
    await $(l10n.add).tap();
    await $.pumpAndSettle();

    // Verify Todo B exists for User 2
    expect($(user2TodoTitle), findsOneWidget);

    // --- SECURITY CHECK (User 2) ---
    // User 2 should NOT see User 1's todo
    expect($(user1TodoTitle), findsNothing);

    // Logout User 2
    await $(Icons.logout).tap();
    await $.pumpAndSettle();

    // --- RE-VERIFY USER 1 ---
    // Log back in as User 1
    await $(l10n.email).enterText(user1Email);
    await $(l10n.password).enterText('password123');
    await $(l10n.login).tap();
    await $.pumpAndSettle();

    // Verify User 1 sees their own todo
    expect($(user1TodoTitle), findsOneWidget);

    // --- SECURITY CHECK (User 1) ---
    // User 1 should NOT see User 2's todo
    expect($(user2TodoTitle), findsNothing);
  });
}
