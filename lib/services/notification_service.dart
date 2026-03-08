import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:weather_app/models/notification_payload.dart';

/// Сервис для локальных уведомлений (отображение в foreground)
class NotificationService {
  static const String channelId = 'weather_notifications';
  static const String channelName = 'Weather Notifications';
  static const String channelDescription = 'Weather notifications from server';

  late final FlutterLocalNotificationsPlugin _localNotifications;
  Function(NotificationPayload)? _onNotificationTap;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _localNotifications = FlutterLocalNotificationsPlugin();

    // Android инициализация
    final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS инициализация
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Создать канал для Android 8+
    final channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
    print('[NotificationService] Инициализирован');
  }

  /// Установить callback при нажатии на уведомление
  void setOnNotificationTap(Function(NotificationPayload) callback) {
    _onNotificationTap = callback;
  }

  /// Показать локальное уведомление
  Future<void> showNotification({
    required String title,
    required String body,
    required NotificationPayload payload,
    String? imagePath,
  }) async {
    if (!_initialized) await init();

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        ticker: 'Weather Notification',
        // Большой вид уведомления
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: '',
        ),
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Конвертировать payload в JSON для передачи
      final payloadJson = payload.toJson().toString();

      await _localNotifications.show(
        payload.id.hashCode, // Уникальный ID
        title,
        body,
        notificationDetails,
        payload: payloadJson,
      );

      print('[NotificationService] Уведомление показано: $title');
    } catch (e) {
      print('[NotificationService] Ошибка при показе уведомления: $e');
    }
  }

  /// Обработчик нажатия на уведомление
  Future<void> _handleNotificationTap(
      NotificationResponse response) async {
    try {
      if (response.payload != null && response.payload!.isNotEmpty) {
        // Парсить payload
        final payloadJson = response.payload!;
        // Это строка, нужно её парсить
        print('[NotificationService] Нажато на уведомление: $payloadJson');

        // Вызвать callback если установлен
        _onNotificationTap?.call(NotificationPayload.fromJson(
          Map<String, dynamic>.from(
            (response.payload as dynamic),
          ),
        ));
      }
    } catch (e) {
      print('[NotificationService] Ошибка при обработке нажатия: $e');
    }
  }

  /// Отменить все уведомления
  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;
    await _localNotifications.cancelAll();
    print('[NotificationService] Все уведомления отменены');
  }

  /// Очистить все
  Future<void> dispose() async {
    await cancelAllNotifications();
  }
}
