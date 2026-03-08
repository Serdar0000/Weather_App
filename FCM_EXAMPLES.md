# FCM Implementation Examples

## 1. Инициализация FCM в приложении

### app.dart
```dart
// Уже реализовано в app.dart
// При авторизации:
- FCMService инициализируется
- TokenService получает device token
- Token сохраняется в Firestore

// При logout:
- Token удаляется из Firestore
- Все сервисы очищаются
```

## 2. Обработка уведомлений в разных состояниях

### Foreground (приложение открыто)
```dart
_fcmService.setOnNotificationReceived((payload) {
  // Уведомление получено
  // Показывается локальное уведомление
  // При нажатии - открывается NotificationDetailsView
  print('Foreground: ${payload.cityRu}');
});
```

### Background (приложение в background)
```dart
_fcmService.setOnNotificationOpened((payload) {
  // Пользователь нажал на системное уведомление
  // Приложение переходит в foreground
  // Открывается NotificationDetailsView
  print('Background tap: ${payload.cityRu}');
});
```

### Terminated (холодный запуск)
```dart
// При запуске приложения проверяется initial message
// Если приложение запущено с уведомления:
final initialMessage = await _fcmService.getInitialMessage();
if (initialMessage != null) {
  // Попадаем сюда при холодном запуске
  _handleTerminatedMessageTap(initialMessage);
}
```

## 3. Deep Linking

### Структура deep link
```
weather://notification/details?id=UUID
weather://weather/details?id=CITY_ID
```

### Обработка deep link
```dart
_fcmService.setOnDeepLinkReceived((type, params) {
  if (type == 'notification_details') {
    final id = params['id'];
    _navigateToNotificationDetails(id);
  }
});
```

### Payload для отправки
```json
{
  "data": {
    "id": "weather-20250308-150000",
    "city": "London",
    "city_ru": "Лондон",
    "temp": "15.5",
    "description": "Partly cloudy",
    "humidity": "60",
    "wind_speed": "5.2",
    "pressure": "1013",
    "visibility": "10000",
    "icon": "partly-cloudy",
    "timestamp": "1709908200000"
  }
}
```

## 4. Логирование событий

### Что логируется
```
// Каждый раз когда уведомление:
- Получено (received)
  - Localstorage: добавить в pending_logs
  
- Открыто (opened)
  - Localstorage: добавить в pending_logs
  
// Каждый час (WorkManager):
- Синхронизировать все pending_logs с Firestore
- Очистить pending_logs
```

### Структура лога
```dart
NotificationEvent(
  id: 'event-uuid',
  type: 'received' | 'opened',
  payload: NotificationPayload(...),
  deviceToken: 'fcm_token',
  appState: 'foreground' | 'background' | 'terminated',
  timestamp: 1709908200000,
)
```

### Доступ к логам
```dart
// В weather_view.dart или любом месте:
final notificationPresenter = context.read<NotificationPresenter>();

// Загрузить события
await notificationPresenter.loadNotificationEvents();
final events = notificationPresenter.events;

// Фильтровать
final opened = notificationPresenter.filterEventsByType('opened');
final russia = notificationPresenter.filterEventsByCity('Moscow');
```

## 5. Settings Screen интеграция

### Добавить в weather_view.dart

```dart
// Импорт
import 'package:weather_app/views/settings_view.dart';

// В FAB или меню
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsView()),
    );
  },
  child: const Icon(Icons.settings),
)

// Или через AppBar
AppBar(
  actions: [
    IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsView()),
        );
      },
    ),
  ],
)
```

## 6. Notification Details Screen

### Открыть вручную
```dart
final payload = NotificationPayload(
  city: 'London',
  cityRu: 'Лондон',
  temp: 15.5,
  description: 'Partly cloudy',
  humidity: 60,
  windSpeed: 5.2,
);

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => NotificationDetailsView(
      notification: payload,
      onClose: () {
        print('Closed');
      },
    ),
  ),
);
```

## 7. Firebase Cloud Function пример

### Отправить один раз
```bash
# Using Firebase CLI
firebase functions:config:set weather.temp="15.5" weather.city="London"
firebase functions:config:get

# Deploy function
firebase deploy --only functions:sendWeatherNotification
```

### Отправить по расписанию (каждый час)
```javascript
// functions/index.js
exports.scheduleWeatherNotification = functions
  .pubsub.schedule('every 1 hours')
  .timeZone('Europe/London')
  .onRun(async (context) => {
    // Ваш код отправки уведомления
  });
```

## 8. Тестирование

### Unit Tests
```dart
test('NotificationPayload fromJson', () {
  final json = {
    'id': 'test-1',
    'city': 'London',
    'city_ru': 'Лондон',
    'temp': '15.5',
    'description': 'Cloudy',
    'humidity': '60',
    'wind_speed': '5.2',
  };
  
  final payload = NotificationPayload.fromJson(json);
  expect(payload.city, 'London');
  expect(payload.temp, 15.5);
});

test('EventLogger logEvent', () async {
  final logger = EventLoggerService();
  await logger.init();
  
  final event = NotificationEvent(
    id: 'test-event',
    type: 'received',
    payload: NotificationPayload(...),
    deviceToken: 'token',
    appState: 'foreground',
  );
  
  await logger.logEvent(event);
  final logs = await logger.getPendingLogs();
  
  expect(logs.length, 1);
});
```

### Widget Tests
```dart
testWidgets('NotificationDetailsView shows data', (tester) async {
  final payload = NotificationPayload(
    city: 'London',
    cityRu: 'Лондон',
    temp: 15.5,
    description: 'Partly cloudy',
    humidity: 60,
    windSpeed: 5.2,
  );
  
  await tester.pumpWidget(
    MaterialApp(
      home: NotificationDetailsView(notification: payload),
    ),
  );
  
  expect(find.text('Лондон'), findsOneWidget);
  expect(find.text('15.5°C'), findsOneWidget);
});
```

## 9. Debug Logging

### Включить детальное логирование
```dart
// В main.dart
void main() async {
  // ...
  
  // Enable Firebase debug logging
  if (kDebugMode) {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print('[Main] Initial message: $message');
    });
  }
  
  // ...
}
```

### Просмотр логов
```bash
# Android
flutter logs -v | grep FCM
flutter logs -v | grep EventLogger

# iOS
flutter logs -v | grep FirebaseMessaging
```

## 10. Отправка тестового уведомления вручную

### Через cURL
```bash
curl -X POST https://fcm.googleapis.com/v1/projects/{PROJECT_ID}/messages:send \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "{DEVICE_TOKEN}",
      "notification": {
        "title": "Тестовое уведомление",
        "body": "Это тестовое уведомление о погоде"
      },
      "data": {
        "id": "test-123",
        "city": "London",
        "city_ru": "Лондон",
        "temp": "15.5",
        "description": "Partly cloudy",
        "humidity": "60",
        "wind_speed": "5.2",
        "pressure": "1013",
        "visibility": "10000"
      }
    }
  }'
```

### Через Firebase Console
1. Firebase Console → Cloud Messaging
2. Send message
3. Заполнить notification details
4. Send test message
5. Выбрать device

## 11. Проблемы и решения

### Уведомление не срабатывает в foreground
- ☑ Проверить что _fcmService.init() вызван
- ☑ Проверить что NotificationService инициализирован
- ☑ Проверить permissions (Android 13+)

### Payload не парсится правильно
- ☑ Проверить что все ключи в payload совпадают с expected names
- ☑ Проверить что типы данных правильные (string/int/double)
- ☑ Использовать try-catch при парсинге

### Background tasks не выполняются
- ☑ Убедиться что WorkManager инициализирован в main.dart
- ☑ На реальном устройстве: disable battery optimization
- ☑ Проверить что device has enough resources

### Deep links не работают
- ☑ Проверить что scheme правильно определён в manifests
- ☑ Проверить что параметры передаются в data поле
- ☑ Тестировать с `adb shell` для Android
