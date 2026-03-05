import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:weather_app/services/auth_service.dart';

class AuthPresenter extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  AuthPresenter() {
    _currentUser = _authService.currentUser;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Register with email and password
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    clearError();

    // Validation
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Пожалуйста, заполните все поля';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Пароли не совпадают';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Пароль должен быть не менее 6 символов';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.register(
        email: email,
        password: password,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _parseFirebaseError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Произошла ошибка: $e';
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    clearError();

    // Validation
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Пожалуйста, заполните все поля';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _parseFirebaseError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Произошла ошибка: $e';
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      clearError();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Ошибка при выходе: $e';
      notifyListeners();
    }
  }

  /// Parse Firebase error codes to user-friendly messages
  String _parseFirebaseError(String code) {
    return switch (code) {
      'weak-password' => 'Пароль слишком слабый',
      'email-already-in-use' =>
        'Этот email уже зарегистрирован',
      'invalid-email' => 'Некорректный email адрес',
      'user-not-found' => 'Пользователь не найден',
      'wrong-password' => 'Неверный пароль',
      'user-disabled' => 'Учетная запись отключена',
      'operation-not-allowed' => 'Операция не разрешена',
      'too-many-requests' =>
        'Слишком много попыток входа. Попробуйте позже',
      _ => 'Ошибка: $code',
    };
  }
}
