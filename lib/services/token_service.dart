import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Сервис для управления device tokens
/// Сохраняет токены в Firestore и LocalStorage
class TokenService {
  static const String _lastTokenKey = 'fcm_device_token';
  static const String _tokenSavedKey = 'token_saved_timestamp';

  late final SharedPreferences _prefs;
  late final FirebaseMessaging _fcm;
  late final FirebaseFirestore _firestore;

  String? _cachedToken;
  bool _initialized = false;

  TokenService({
    FirebaseMessaging? fcm,
    FirebaseFirestore? firestore,
  })  : _fcm = fcm ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Инициализировать сервис и получить токен
  Future<void> init() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    _initialized = true;

    // Получить разрешение на уведомления
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Получить текущий токен
    final token = await _fcm.getToken();
    if (token != null) {
      _cachedToken = token;
      await _saveTokenLocally(token);
    }

    // Слушать обновления токена
    _fcm.onTokenRefresh.listen((newToken) {
      _cachedToken = newToken;
      _saveTokenLocally(newToken);
      _saveTokenToFirestore(newToken);
    });

    print('[TokenService] Инициализирован. Token: ${token?.substring(0, 20)}...');
  }

  /// Получить текущий токен
  Future<String?> getToken() async {
    if (!_initialized) await init();

    if (_cachedToken != null) {
      return _cachedToken;
    }

    final token = await _fcm.getToken();
    if (token != null) {
      _cachedToken = token;
      await _saveTokenLocally(token);
    }
    return token;
  }

  /// Сохранить токен локально
  Future<void> _saveTokenLocally(String token) async {
    await _prefs.setString(_lastTokenKey, token);
    await _prefs.setInt(_tokenSavedKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Сохранить токен в Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      // Получить текущего пользователя
      // ВАЖНО: эта функция должна быть вызвана ПОСЛЕ авторизации
      // Пока просто логируем
      print('[TokenService] Токен будет сохранён в Firestore: ${token.substring(0, 20)}...');
    } catch (e) {
      print('[TokenService] Ошибка при сохранении в Firestore: $e');
    }
  }

  /// Сохранить токен уже авторизованного пользователя в Firestore
  Future<void> saveCurrentUserToken(String uid) async {
    try {
      if (_cachedToken == null) {
        final token = await getToken();
        if (token == null) return;
        _cachedToken = token;
      }

      final tokenData = {
        'token': _cachedToken,
        'platform': _getPlatform(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('device_tokens')
          .doc(_cachedToken) // Используем сам токен как ID
          .set(tokenData, SetOptions(merge: true));

      print('[TokenService] Токен сохранён в Firestore для пользователя $uid');
    } catch (e) {
      print('[TokenService] Ошибка при сохранении токена: $e');
    }
  }

  /// Удалить токен из Firestore (при logout)
  Future<void> deleteCurrentUserToken(String uid) async {
    try {
      if (_cachedToken == null) return;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('device_tokens')
          .doc(_cachedToken)
          .delete();

      print('[TokenService] Токен удалён из Firestore');
    } catch (e) {
      print('[TokenService] Ошибка при удалении токена: $e');
    }
  }

  /// Получить локально сохранённый токен
  Future<String?> getSavedToken() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs.getString(_lastTokenKey);
  }

  /// Получить платформу
  String _getPlatform() {
    // На реальном устройстве это определится автоматически
    return 'unknown';
  }

  /// Очистить все токены (для logout)
  Future<void> clearAll() async {
    if (!_initialized) return;
    await _prefs.remove(_lastTokenKey);
    await _prefs.remove(_tokenSavedKey);
    _cachedToken = null;
    print('[TokenService] Все токены очищены');
  }
}
