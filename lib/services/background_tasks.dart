import 'package:workmanager/workmanager.dart';
import 'package:weather_app/services/event_logger_service.dart';

/// Фоновые задачи, выполняемые по расписанию
/// Используется WorkManager для обработки задач даже при terminated приложении

/// Уникальный ID фоновой задачи
const String syncNotificationLogsTaskId = 'sync_notification_logs';

/// Инициализировать WorkManager для фоновых задач
Future<void> initBackgroundTasks() async {
  try {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Измените на false для продакшена
    );

    // Запланировать задачу каждый час
    await Workmanager().registerPeriodicTask(
      syncNotificationLogsTaskId,
      'syncNotificationLogs',
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    print('[BackgroundTasks] Инициализирован, задача запланирована на каждый час');
  } catch (e) {
    print('[BackgroundTasks] Ошибка при инициализации: $e');
  }
}

/// Callback dispatcher для фоновых задач
/// ВАЖНО: эта функция должна быть TOP LEVEL, вне класса
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      print('[BackgroundTasks] Выполнение задачи: $taskName');

      if (taskName == 'syncNotificationLogs') {
        await _syncNotificationLogsWithFirestore();
      }

      return Future.value(true);
    } catch (e) {
      print('[BackgroundTasks] Ошибка при выполнении задачи: $e');
      return Future.value(false);
    }
  });
}

/// Синхронизировать логи уведомлений с Firestore
/// Эта функция вызывается каждый час в background
Future<void> _syncNotificationLogsWithFirestore() async {
  try {
    print('[BackgroundTasks] Синхронизация логов начата');

    final eventLogger = EventLoggerService();
    await eventLogger.init();

    // Получить все ожидающие логи
    final pendingLogs = await eventLogger.getPendingLogs();

    if (pendingLogs.isEmpty) {
      print('[BackgroundTasks] Нет логов для синхронизации');
      return;
    }

    print('[BackgroundTasks] Найдено логов для синхронизации: ${pendingLogs.length}');

    // Отправить логи в Firestore
    // final firestore = FirebaseFirestore.instance;

    for (final log in pendingLogs) {
      try {
        // ВАЖНО: это базовая реализация
        // В реальном приложении нужно знать uid пользователя
        // Рекомендуется передавать uid при инициализации BackgroundTasks
        
        print('[BackgroundTasks] Попытка сохранить лог: ${log.type} для ${log.payload.cityRu}');
        
        // Здесь должна быть реальная отправка в Firestore
        // await firestore
        //     .collection('users')
        //     .doc(uid)
        //     .collection('notification_logs')
        //     .doc(log.id)
        //     .set(log.toJson());
      } catch (e) {
        print('[BackgroundTasks] Ошибка при отправке лога: $e');
      }
    }

    // Очистить логи после успешной отправки
    await eventLogger.clearLogs();
    print('[BackgroundTasks] Синхронизация завершена');
  } catch (e) {
    print('[BackgroundTasks] Ошибка при синхронизации: $e');
  }
}

/// Отменить все запланированные задачи
Future<void> cancelAllBackgroundTasks() async {
  try {
    await Workmanager().cancelAll();
    print('[BackgroundTasks] Все задачи отменены');
  } catch (e) {
    print('[BackgroundTasks] Ошибка при отмене задач: $e');
  }
}
