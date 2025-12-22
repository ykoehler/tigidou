import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();
  final _secureStorage = const FlutterSecureStorage();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;

  AuthProvider() {
    _authService.user.listen((User? user) {
      _user = user;
      notifyListeners();
    });
    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    _isBiometricAvailable = await _biometricService.isBiometricsAvailable();
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    notifyListeners();
  }

  /// Enable or disable biometric authentication
  /// When enabling, prompts for biometric authentication immediately
  Future<bool> setBiometricEnabled(
    bool enabled,
    String enrollmentReason,
  ) async {
    if (enabled) {
      // Prompt for biometric authentication to enroll
      final authenticated = await _biometricService.authenticate(
        localizedReason: enrollmentReason,
      );

      if (!authenticated) {
        return false; // Failed to authenticate, don't enable
      }

      // Store current user's email for future auto-login
      final currentUser = _authService.currentUser;
      if (currentUser != null && currentUser.email != null) {
        await _secureStorage.write(
          key: 'biometric_email',
          value: currentUser.email,
        );
        await _secureStorage.write(
          key: 'biometric_user_id',
          value: currentUser.uid,
        );
      }

      _isBiometricEnabled = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', true);
    } else {
      // Disable biometric
      await _clearBiometricCredentials();
      _isBiometricEnabled = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', false);
    }

    notifyListeners();
    return true;
  }

  /// Clear all stored biometric credentials
  Future<void> _clearBiometricCredentials() async {
    await _secureStorage.delete(key: 'biometric_email');
    await _secureStorage.delete(key: 'biometric_user_id');
    await _secureStorage.delete(key: 'biometric_password');
  }

  /// Attempt auto-login with biometrics on app start
  /// Returns true if auto-login succeeded, false otherwise
  Future<bool> attemptBiometricAutoLogin(String biometricReason) async {
    if (!_isBiometricEnabled) {
      return false;
    }

    try {
      // Check if we have stored credentials
      final email = await _secureStorage.read(key: 'biometric_email');
      final password = await _secureStorage.read(key: 'biometric_password');

      if (email == null) {
        // No stored email, can't auto-login
        return false;
      }

      // Prompt for biometric authentication
      final authenticated = await _biometricService.authenticate(
        localizedReason: biometricReason,
      );

      if (!authenticated) {
        return false; // User cancelled or failed authentication
      }

      // Check if we have a stored password (from previous login)
      if (password != null) {
        // Attempt sign in with stored credentials
        _setLoading(true);
        await _authService.signIn(email, password);
        _setLoading(false);
        return true;
      } else {
        // No password stored - user needs to log in manually once
        return false;
      }
    } catch (e) {
      debugPrint('Auto-login failed: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signIn(email, password);

      // If biometric is enabled, store the password for future auto-login
      if (_isBiometricEnabled) {
        final storedEmail = await _secureStorage.read(key: 'biometric_email');
        if (storedEmail == email) {
          // Same user, store password
          await _secureStorage.write(
            key: 'biometric_password',
            value: password,
          );
        }
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithBiometrics(String localizedReason) async {
    _setLoading(true);
    _clearError();
    try {
      final authenticated = await _biometricService.authenticate(
        localizedReason: localizedReason,
      );

      if (authenticated) {
        final email = await _secureStorage.read(key: 'biometric_email');
        final password = await _secureStorage.read(key: 'biometric_password');

        if (email != null && password != null) {
          await _authService.signIn(email, password);
        } else {
          _setError('Stored credentials not found');
        }
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.register(email, password);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    // Clear biometric password on logout (but keep email/enabled state)
    if (_isBiometricEnabled) {
      await _secureStorage.delete(key: 'biometric_password');
    }
    await _authService.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
