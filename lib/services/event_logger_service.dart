import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/notification_event.dart';

/// Сервис для логирования событий уведомлений (локально)
/// Хранит события в SharedPreferences и синхронизирует с Firestore
class EventLoggerService {
  static const String _pendingLogsKey = 'pending_notification_logs';
  static const String _lastSyncKey = 'last_notification_sync';
  static const int _maxLocalLogs = 100; // Максимум логов локально

  late final SharedPreferences _prefs;
  bool _initialized = false;

  /// Инициализировать сервис
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    print('[EventLogger] Инициализирован');
  }

  /// Добавить событие в локальную очередь
  Future<void> logEvent(NotificationEvent event) async {
    if (!_initialized) await init();

    final logs = await getPendingLogs();
    logs.add(event);

    // Ограничить количество логов
    if (logs.length > _maxLocalLogs) {
      logs.removeRange(0, logs.length - _maxLocalLogs);
    }

    await _prefs.setString(
      _pendingLogsKey,
      jsonEncode(logs.map((e) => e.toJson()).toList()),
    );

    print('[EventLogger] Событие залогировано: ${event.type} - ${event.payload.cityRu}');
  }

  /// Получить все ожидающие логи
  Future<List<NotificationEvent>> getPendingLogs() async {
    if (!_initialized) await init();

    final json = _prefs.getString(_pendingLogsKey);
    if (json == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((e) => NotificationEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[EventLogger] Ошибка при разборе логов: $e');
      return [];
    }
  }

  /// Очистить логи после успешной отправки
  Future<void> clearLogs() async {
    if (!_initialized) await init();
    await _prefs.remove(_pendingLogsKey);
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    print('[EventLogger] Логи очищены');
  }

  /// Получить время последней синхронизации
  Future<DateTime?> getLastSyncTime() async {
    if (!_initialized) await init();
    final timestamp = _prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Количество ожидающих логов
  Future<int> getPendingLogsCount() async {
    final logs = await getPendingLogs();
    return logs.length;
  }

  /// Очистить все данные (для logout)
  Future<void> clearAll() async {
    if (!_initialized) await init();
    await _prefs.remove(_pendingLogsKey);
    await _prefs.remove(_lastSyncKey);
    print('[EventLogger] Все логи удалены');
  }
}
