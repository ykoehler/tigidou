import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'providers/person_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';
import 'package:tigidou/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NOTE: DefaultFirebaseOptions requires running `flutterfire configure`
  // For now, we'll wrap in a try-catch or assume the user has configured it.
  // If firebase_options.dart doesn't exist, this will fail to compile.
  // We will assume the user will run `flutterfire configure`.
  // However, to make it compile initially without that file (if the user hasn't run it yet),
  // we might need to comment it out or handle it.
  // But the prompt implies using Firebase, so we should expect the configuration.

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (const bool.fromEnvironment('USE_FIREBASE_EMULATOR')) {
    // For Android emulators, we need to use 10.0.2.2 instead of localhost
    const host = String.fromEnvironment(
      'FIREBASE_EMULATOR_HOST',
      defaultValue: 'localhost',
    );
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => PersonProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              primaryColor: Colors.blueAccent,
              scaffoldBackgroundColor:
                  Colors.transparent, // For GradientScaffold
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                labelStyle: const TextStyle(color: Colors.white70),
              ),
              cardTheme: CardThemeData(
                color: Colors.white.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            home: auth.isAuthenticated
                ? const MainScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
