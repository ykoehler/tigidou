import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'providers/person_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'package:tigidou/l10n/app_localizations.dart';

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
