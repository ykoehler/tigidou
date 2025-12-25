import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tigidou/app.dart';
import 'package:tigidou/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  patrolTest('verify people management and task association', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    final l10n = AppLocalizations.of($.tester.element(find.byType(MyApp)))!;

    // 1. Authenticate
    await $(l10n.noAccount).tap();
    await $.pumpAndSettle();

    final testEmail =
        'test-people-${DateTime.now().millisecondsSinceEpoch}@example.com';
    await $(l10n.email).enterText(testEmail);
    await $(l10n.password).enterText('password123');
    await $(l10n.confirmPassword).enterText('password123');
    await $(l10n.register).tap();
    await $.pumpAndSettle();

    // 2. Go to Templates tab
    await $(l10n.templates).tap();
    await $.pumpAndSettle();

    // 3. Add a Person
    await $(Icons.add).tap();
    await $.pumpAndSettle();

    await $(l10n.usernameHint).enterText('john');
    await $(l10n.displayNameHint).enterText('John Doe');
    await $(l10n.add).tap();
    await $.pumpAndSettle();

    expect($('John Doe'), findsOneWidget);
    expect($('@john'), findsOneWidget);

    // 4. Add an associated Todo (Go to Todos tab)
    await $(l10n.todos).tap();
    await $.pumpAndSettle();

    await $(Icons.add).tap();
    await $.pumpAndSettle();
    await $(l10n.addTodoHint).enterText('Email @john about the report');
    await $(l10n.add).tap();
    await $.pumpAndSettle();

    // 5. Verify association in Templates tab
    await $(l10n.templates).tap();
    await $.pumpAndSettle();

    // Expand John Doe's entry
    // The expand icon is next to the delete icon in the trailing row
    await $(Icons.expand_more).tap();
    await $.pumpAndSettle();

    expect($('Email @john about the report'), findsOneWidget);
  });
}
