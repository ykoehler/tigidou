import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'package:tigidou/l10n/app_localizations.dart';

/// Splash screen that handles app initialization and biometric auto-login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Small delay to show splash screen briefly
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Check if user is already authenticated (Firebase session valid)
    if (authProvider.isAuthenticated) {
      _navigateToMain();
      return;
    }

    // Attempt biometric auto-login if enabled
    if (authProvider.isBiometricEnabled) {
      final l10n = AppLocalizations.of(context)!;
      final success = await authProvider.attemptBiometricAutoLogin(
        l10n.biometricReason,
      );

      if (!mounted) return;

      if (success) {
        _navigateToMain();
      } else {
        _navigateToLogin();
      }
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToMain() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1), // Dark blue
              Color(0xFF1976D2), // Medium blue
              Color(0xFF42A5F5), // Light blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_banner.png',
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
