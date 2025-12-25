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

  patrolTest(
    'validate smart grocery features: record types, parsing, and best price',
    ($) async {
      await $.pumpWidgetAndSettle(const MyApp());

      final l10n = AppLocalizations.of($.tester.element(find.byType(MyApp)))!;

      // 1. SETUP: Authenticate with test account
      await $(l10n.noAccount).tap();
      await $.pumpAndSettle();

      final testEmail =
          'grocery-test-${DateTime.now().millisecondsSinceEpoch}@example.com';
      await $(l10n.email).enterText(testEmail);
      await $(l10n.password).enterText('password123');
      await $(l10n.confirmPassword).enterText('password123');
      await $(l10n.register).tap();
      await $.pumpAndSettle();

      // 2. TEST: Record Type Suggestions
      await $(l10n.searchHint).enterText('!');
      await $.pumpAndSettle();
      expect($('store'), findsOneWidget);
      expect($('grocery_list'), findsOneWidget);

      await $('store').tap();
      await $.pumpAndSettle();

      // Search bar should now contain '!store'
      final textField = $.tester.widget<TextField>($(TextField));
      expect(textField.controller?.text, contains('!store'));

      // Clear for next test
      await $(Icons.clear).tap();
      await $.pumpAndSettle();

      // 3. TEST: Creating Stores and Prices
      const store1 = 'IGA !store.groceries';
      await $(l10n.searchHint).enterText(store1);
      await $.tester.testTextInput.receiveAction(TextInputAction.done);
      await $.pumpAndSettle();
      expect($(store1), findsOneWidget);

      const price1 = 'Milk @IGA \$4.50 2x';
      await $(l10n.searchHint).enterText(price1);
      await $.tester.testTextInput.receiveAction(TextInputAction.done);
      await $.pumpAndSettle();
      expect($(price1), findsOneWidget);

      const store2 = 'Costco !store.groceries';
      await $(l10n.searchHint).enterText(store2);
      await $.tester.testTextInput.receiveAction(TextInputAction.done);
      await $.pumpAndSettle();
      expect($(store2), findsOneWidget);

      const price2 = 'Milk @Costco \$4.25';
      await $(l10n.searchHint).enterText(price2);
      await $.tester.testTextInput.receiveAction(TextInputAction.done);
      await $.pumpAndSettle();
      expect($(price2), findsOneWidget);

      // 4. TEST: Smart Grocery Best Price Lookup
      const groceryItem = 'Milk #groceries';
      await $(l10n.searchHint).enterText(groceryItem);
      await $.tester.testTextInput.receiveAction(TextInputAction.done);
      await $.pumpAndSettle();
      expect($(groceryItem), findsOneWidget);

      // Verify "Best: $4.25 at Costco" appears
      expect($('Best: \$4.25 at Costco'), findsOneWidget);

      // 5. TEST: Panel Views and Tag Stripping
      await $(Icons.dashboard_rounded).tap();
      await $.pumpAndSettle();

      // Tap on "Stores" card (Index 3 in GridView usually, but we use text)
      await $('Stores').tap();
      await $.pumpAndSettle();

      // In "Stores" panel, "IGA !store.groceries" should just show "IGA"
      expect($('IGA'), findsOneWidget);
      expect($('!store.groceries'), findsNothing);

      await $(Icons.arrow_back).tap();
      await $.pumpAndSettle();

      // Tap on "Groceries" card
      await $('Groceries').tap();
      await $.pumpAndSettle();

      // In "Groceries" panel, "Milk #groceries" should just show "Milk"
      expect(
        $('Milk'),
        findsWidgets,
      ); // Might find multiple Milks, but check for lack of tag
      expect($('#groceries'), findsNothing);
    },
  );
}
