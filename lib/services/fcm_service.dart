import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:weather_app/models/notification_event.dart';
import 'package:weather_app/models/notification_payload.dart';
import 'package:weather_app/services/event_logger_service.dart';
import 'package:weather_app/services/notification_service.dart';

/// Сервис для управления FCM (Firebase Cloud Messaging)
/// Обрабатывает уведомления в 3 состояниях: foreground, background, terminated
class FCMService {
  late final FirebaseMessaging _fcm;
  late final NotificationService _notificationService;
  late final EventLoggerService _eventLogger;

  // Callbacks для разных событий
  Function(NotificationPayload)? _onNotificationReceived;
  Function(NotificationPayload)? _onNotificationOpened;
  Function(String, Map<String, dynamic>)? _onDeepLinkReceived;

  String? _deviceToken;
  bool _initialized = false;

  FCMService({
    FirebaseMessaging? fcm,
    NotificationService? notificationService,
    EventLoggerService? eventLogger,
  })  : _fcm = fcm ?? FirebaseMessaging.instance,
        _notificationService = notificationService ?? NotificationService(),
        _eventLogger = eventLogger ?? EventLoggerService();

  /// Инициализировать FCM сервис
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Инициализировать сервисы
      await _notificationService.init();
      await _eventLogger.init();

      // Получить device token
      _deviceToken = await _fcm.getToken();
      print('[FCMService] Device Token: $_deviceToken');

      // Обработчик для foreground уведомлений
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Обработчик для background уведомлений (при нажатии)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

      // Обработчик когда приложение было terminated (холодный запуск)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        _handleTerminatedMessageTap(initialMessage);
      }

      // Слушать обновления токена
      _fcm.onTokenRefresh.listen((token) {
        _deviceToken = token;
        print('[FCMService] Новый токен: $token');
      });

      _initialized = true;
      print('[FCMService] Инициализирован');
    } catch (e) {
      print('[FCMService] Ошибка при инициализации: $e');
    }
  }

  /// Установить callback для полученных уведомлений
  void setOnNotificationReceived(Function(NotificationPayload) callback) {
    _onNotificationReceived = callback;
  }

  /// Установить callback для открытых уведомлений
  void setOnNotificationOpened(Function(NotificationPayload) callback) {
    _onNotificationOpened = callback;
  }

  /// Установить callback для deep links
  void setOnDeepLinkReceived(
    Function(String, Map<String, dynamic>) callback,
  ) {
    _onDeepLinkReceived = callback;
  }

  /// Обработка foreground сообщений (приложение активно)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      print('[FCMService] Foreground сообщение: ${message.notification?.title}');

      final payload = NotificationPayload.fromMap(message.data);

      // Залогировать событие
      await _eventLogger.logEvent(
        NotificationEvent(
          id: payload.id,
          type: 'received',
          payload: payload,
          deviceToken: _deviceToken ?? 'unknown',
          appState: 'foreground',
        ),
      );

      // Показать локальное уведомление
      await _notificationService.showNotification(
        title: message.notification?.title ?? 'Weather Update',
        body: message.notification?.body ??
            '${payload.cityRu}: ${payload.temp}°C, ${payload.description}',
        payload: payload,
      );

      // Вызвать callback
      _onNotificationReceived?.call(payload);
    } catch (e) {
      print('[FCMService] Ошибка при обработке foreground сообщения: $e');
    }
  }

  /// Обработка нажатия на background сообщение
  Future<void> _handleBackgroundMessageTap(RemoteMessage message) async {
    try {
      print('[FCMService] Background сообщение (тап): ${message.notification?.title}');

      final payload = NotificationPayload.fromMap(message.data);

      // Залогировать событие
      await _eventLogger.logEvent(
        NotificationEvent(
          id: payload.id,
          type: 'opened',
          payload: payload,
          deviceToken: _deviceToken ?? 'unknown',
          appState: 'background',
        ),
      );

      // Вызвать callback для открытия
      _onNotificationOpened?.call(payload);

      // Отправить deep link
      _onDeepLinkReceived?.call('notification_details', {
        'id': payload.id,
        'city': payload.city,
        'city_ru': payload.cityRu,
        'temp': payload.temp,
      });
    } catch (e) {
      print('[FCMService] Ошибка при обработке background сообщения: $e');
    }
  }

  /// Обработка нажатия на terminated сообщение (холодный запуск)
  Future<void> _handleTerminatedMessageTap(RemoteMessage message) async {
    try {
      print('[FCMService] Terminated сообщение (холодный запуск): ${message.notification?.title}');

      final payload = NotificationPayload.fromMap(message.data);

      // Залогировать событие
      await _eventLogger.logEvent(
        NotificationEvent(
          id: payload.id,
          type: 'opened',
          payload: payload,
          deviceToken: _deviceToken ?? 'unknown',
          appState: 'terminated',
        ),
      );

      // Вызвать callback для открытия
      _onNotificationOpened?.call(payload);

      // Отправить deep link
      _onDeepLinkReceived?.call('notification_details', {
        'id': payload.id,
        'city': payload.city,
        'city_ru': payload.cityRu,
        'temp': payload.temp,
      });
    } catch (e) {
      print('[FCMService] Ошибка при обработке terminated сообщения: $e');
    }
  }

  /// Получить device token
  String? getDeviceToken() => _deviceToken;

  /// Включить/отключить FCM
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      await _fcm.subscribeToTopic('weather_notifications');
      print('[FCMService] Уведомления включены');
    } else {
      await _fcm.unsubscribeFromTopic('weather_notifications');
      print('[FCMService] Уведомления отключены');
    }
  }

  /// Очистить все
  Future<void> dispose() async {
    await _notificationService.dispose();
  }
}

/// Top-level функция для обработки background сообщений
/// ВАЖНО: она должна быть вне класса для работы с FCM
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[FCMService] Background handler: ${message.notification?.title}');

  try {
    final payload = NotificationPayload.fromMap(message.data);
    final eventLogger = EventLoggerService();
    await eventLogger.init();

    // Залогировать событие
    await eventLogger.logEvent(
      NotificationEvent(
        id: payload.id,
        type: 'received',
        payload: payload,
        deviceToken: 'unknown',
        appState: 'background',
      ),
    );

    print('[FCMService] Background сообщение залогировано');
  } catch (e) {
    print('[FCMService] Ошибка в background handler: $e');
  }
}
