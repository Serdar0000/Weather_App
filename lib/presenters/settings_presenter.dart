import 'package:flutter/foundation.dart';
import 'package:weather_app/repositories/settings_repository.dart';

/// Presenter для управления настройками уведомлений
class SettingsPresenter with ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();

  bool _fcmEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get fcmEnabled => _fcmEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Инициализировать и загрузить настройки
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.init();
      await _loadSettings();
      print('[SettingsPresenter] Инициализирован');
    } catch (e) {
      _errorMessage = 'Ошибка при инициализации: $e';
      print('[SettingsPresenter] $errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Загрузить все настройки
  Future<void> _loadSettings() async {
    try {
      _fcmEnabled = await _repository.isFCMEnabled();
      _soundEnabled = await _repository.isSoundEnabled();
      _vibrationEnabled = await _repository.isVibrationEnabled();
      print('[SettingsPresenter] Настройки загружены');
    } catch (e) {
      _errorMessage = 'Ошибка при загрузке настроек: $e';
    }
    notifyListeners();
  }

  /// Включить/отключить FCM
  Future<void> setFCMEnabled(bool enabled) async {
    try {
      await _repository.setFCMEnabled(enabled);
      _fcmEnabled = enabled;
      notifyListeners();
      print('[SettingsPresenter] FCM обновлен: $enabled');
    } catch (e) {
      _errorMessage = 'Ошибка при обновлении FCM: $e';
      notifyListeners();
    }
  }

  /// Включить/отключить звук
  Future<void> setSoundEnabled(bool enabled) async {
    try {
      await _repository.setSoundEnabled(enabled);
      _soundEnabled = enabled;
      notifyListeners();
      print('[SettingsPresenter] Звук обновлен: $enabled');
    } catch (e) {
      _errorMessage = 'Ошибка при обновлении звука: $e';
      notifyListeners();
    }
  }

  /// Включить/отключить вибрацию
  Future<void> setVibrationEnabled(bool enabled) async {
    try {
      await _repository.setVibrationEnabled(enabled);
      _vibrationEnabled = enabled;
      notifyListeners();
      print('[SettingsPresenter] Вибрация обновлена: $enabled');
    } catch (e) {
      _errorMessage = 'Ошибка при обновлении вибрации: $e';
      notifyListeners();
    }
  }

  /// Сбросить все настройки на значения по умолчанию
  Future<void> resetToDefaults() async {
    try {
      await _repository.resetToDefaults();
      _fcmEnabled = true;
      _soundEnabled = true;
      _vibrationEnabled = true;
      notifyListeners();
      print('[SettingsPresenter] Настройки просброшены');
    } catch (e) {
      _errorMessage = 'Ошибка при сбросе: $e';
      notifyListeners();
    }
  }

  /// Очистить ошибку
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Очистить все (для logout)
  Future<void> clear() async {
    try {
      await _repository.clearAll();
      _fcmEnabled = true;
      _soundEnabled = true;
      _vibrationEnabled = true;
      notifyListeners();
    } catch (e) {
      print('[SettingsPresenter] Ошибка при очистке: $e');
    }
  }
}
