import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tigidou/main.dart';
import 'package:tigidou/l10n/app_localizations.dart';

void main() {
  patrolTest('verify login and registration flow navigation', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    // Use l10n to find widgets
    final l10n = AppLocalizations.of($.tester.element(find.byType(MyApp)))!;

    // 1. Check if we are on Login Screen
    expect($(l10n.appTitle), findsOneWidget);

    // 2. Go to Register Screen
    await $(l10n.noAccount).tap();
    await $.pumpAndSettle();
    expect($(l10n.createAccount), findsOneWidget);

    // 3. Go back to Login
    await $.native.pressBack();
    await $.pumpAndSettle();
    expect($(l10n.appTitle), findsOneWidget);

    // 4. Try invalid login
    await $(l10n.email).enterText('invalid@email.com');
    await $(l10n.password).enterText('short');
    await $(l10n.login).tap();

    // Validation should show up (built-in Flutter behavior for text fields)
    // For more complex E2E we would check for the error text in French/English
  });
}
