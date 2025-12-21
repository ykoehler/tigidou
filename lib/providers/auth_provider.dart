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

  Future<void> setBiometricEnabled(bool enabled) async {
    _isBiometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
    if (!enabled) {
      await _secureStorage.delete(key: 'email');
      await _secureStorage.delete(key: 'password');
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signIn(email, password);
      if (_isBiometricEnabled) {
        await _secureStorage.write(key: 'email', value: email);
        await _secureStorage.write(key: 'password', value: password);
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
        final email = await _secureStorage.read(key: 'email');
        final password = await _secureStorage.read(key: 'password');

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
