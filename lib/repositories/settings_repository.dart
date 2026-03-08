import 'package:shared_preferences/shared_preferences.dart';

/// Репозиторий для настроек уведомлений
class SettingsRepository {
  static const String _fcmEnabledKey = 'fcm_notifications_enabled';
  static const String _soundEnabledKey = 'notification_sound_enabled';
  static const String _vibrationEnabledKey = 'notification_vibration_enabled';

  late final SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Получить статус включения FCM уведомлений
  Future<bool> isFCMEnabled() async {
    if (!_initialized) await init();
    return _prefs.getBool(_fcmEnabledKey) ?? true;
  }

  /// Установить статус FCM уведомлений
  Future<void> setFCMEnabled(bool enabled) async {
    if (!_initialized) await init();
    await _prefs.setBool(_fcmEnabledKey, enabled);
    print('[SettingsRepository] FCM уведомления: ${enabled ? 'включены' : 'отключены'}');
  }

  /// Получить статус звука уведомлений
  Future<bool> isSoundEnabled() async {
    if (!_initialized) await init();
    return _prefs.getBool(_soundEnabledKey) ?? true;
  }

  /// Установить статус звука уведомлений
  Future<void> setSoundEnabled(bool enabled) async {
    if (!_initialized) await init();
    await _prefs.setBool(_soundEnabledKey, enabled);
    print('[SettingsRepository] Звук уведомлений: ${enabled ? 'включен' : 'отключен'}');
  }

  /// Получить статус вибрации уведомлений
  Future<bool> isVibrationEnabled() async {
    if (!_initialized) await init();
    return _prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  /// Установить статус вибрации уведомлений
  Future<void> setVibrationEnabled(bool enabled) async {
    if (!_initialized) await init();
    await _prefs.setBool(_vibrationEnabledKey, enabled);
    print('[SettingsRepository] Вибрация уведомлений: ${enabled ? 'включена' : 'отключена'}');
  }

  /// Получить все настройки
  Future<Map<String, bool>> getAllSettings() async {
    if (!_initialized) await init();
    return {
      'fcm_enabled': await isFCMEnabled(),
      'sound_enabled': await isSoundEnabled(),
      'vibration_enabled': await isVibrationEnabled(),
    };
  }

  /// Сбросить все настройки на значения по умолчанию
  Future<void> resetToDefaults() async {
    if (!_initialized) await init();
    await _prefs.remove(_fcmEnabledKey);
    await _prefs.remove(_soundEnabledKey);
    await _prefs.remove(_vibrationEnabledKey);
    print('[SettingsRepository] Настройки просброшены на значения по умолчанию');
  }

  /// Очистить все настройки (для logout)
  Future<void> clearAll() async {
    if (!_initialized) await init();
    await resetToDefaults();
  }
}
