# 🌤️ Weather App - Firebase Cloud Messaging (FCM) Implementation

## ✨ Что реализовано

Полнофункциональная система push-уведомлений с Firebase Cloud Messaging:

✅ **Получение уведомлений** в 3 состояниях приложения:
   - Foreground (приложение открыто)
   - Background (приложение в фоне)
   - Terminated (холодный запуск)

✅ **Управление device tokens**:
   - Сохранение в Firestore (`users/{uid}/device_tokens/{token}`)
   - Сохранение локально в SharedPreferences
   - Автоматическое обновление при смене токена

✅ **Экран NotificationDetails** с полной информацией:
   - Город и температура
   - Влажность, ветер, давление, видимость
   - Время получения уведомления

✅ **Экран Settings**:
   - Toggle включения/отключения FCM
   - Toggle звука уведомлений
   - Toggle вибрации
   - Сброс на значения по умолчанию

✅ **Логирование событий**:
   - Локальное хранение в SharedPreferences
   - Синхронизация с Firestore каждый час (WorkManager)
   - Отслеживание: тип события (received/opened), время, payload, state

✅ **Deep linking**:
   - Парсинг UUID из payload
   - Автоматическая навигация на notification details

---

## 📦 Установка

### 1. Клонировать репозиторий и установить зависимости
```bash
cd weather_app
flutter pub get
```

### 2. Настроить Firebase

#### Firebase Console:
1. Перейти на [firebase.google.com](https://firebase.google.com)
2. Создать Firestore Database (Start in test mode)
3. Добавить Security Rules (см. `FCM_SETUP.md`)

#### Android:
- ✅ `google-services.json` уже должен быть в `android/app/`
- Добавьте разрешение в `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
  ```

#### iOS:
- Откройте `ios/Runner.xcworkspace` в Xcode
- В Signing & Capabilities добавьте:
  - Push Notifications
  - Background Modes (Remote notifications, Background fetch)
- Загрузите APNs certificate в Firebase Console

---

## 🚀 Запуск

### Development
```bash
flutter run
```

### Release (Android)
```bash
flutter build apk --release
flutter install
```

### Release (iOS)
```bash
flutter build ios --release
# Затем загрузить в App Store Connect
```

---

## 🧪 Тестирование

### Отправить тестовое уведомление:

1. **Firebase Console** → Cloud Messaging → Send message
2. Заполнить:
   ```
   Title: 🌤️ Weather Update
   Body: Temperature: 15°C, Partly cloudy
   
   Custom data:
   - id: weather-123
   - city: London
   - city_ru: Лондон  
   - temp: 15.5
   - description: Partly cloudy
   - humidity: 60
   - wind_speed: 5.2
   - pressure: 1013
   - visibility: 10000
   ```
3. Нажать "Send test message" или "Send"

### Типы тестов:

**Foreground:**
- Приложение открыто
- Должно показаться локальное уведомление
- Нажать → откроется NotificationDetailsView

**Background:**
- Приложение свернуто (Home)
- Нажать на системное уведомление
- Должно открыться NotificationDetailsView

**Terminated:**
- Закрыть приложение из recent apps
- Нажать на системное уведомление
- Приложение запустится с холодного старта и откроет NotificationDetailsView

---

## 📁 Структура проекта

```
lib/
├── models/
│   ├── notification_payload.dart      ← Модель уведомления
│   └── notification_event.dart        ← Модель события
├── services/
│   ├── fcm_service.dart               ← Основной FCM сервис
│   ├── token_service.dart             ← Управление токенами
│   ├── notification_service.dart      ← Локальные уведомления
│   ├── event_logger_service.dart      ← Логирование
│   ├── deep_link_service.dart         ← Парсинг deep links
│   └── background_tasks.dart          ← WorkManager
├── repositories/
│   ├── notification_repository.dart   ← Работа с Firestore
│   └── settings_repository.dart       ← Работа с ShPref
├── presenters/
│   ├── notification_presenter.dart    ← Состояние уведомлений
│   └── settings_presenter.dart        ← Состояние настроек
├── views/
│   ├── notification_details_view.dart ← Экран деталей
│   └── settings_view.dart             ← Экран настроек
├── main.dart                          ← Инициализация
└── app.dart                           ← App root + FCM
```

---

## 🔧 Файлы конфигурации

- `FCM_SETUP.md` - Полная инструкция по настройке (самая важная!)
- `ANDROID_FCM_CONFIG.md` - Android специфичная конфигурация
- `IOS_FCM_CONFIG.md` - iOS специфичная конфигурация
- `FCM_EXAMPLES.md` - Примеры использования API
- `FCM_CHECKLIST.md` - Чек-лист всего реализованного

---

## 📊 Firestore структура

```
firestore/
└── users/{uid}
    ├── device_tokens/{token_id}
    │   ├── token: "fcm_token_xxx"
    │   ├── platform: "android"
    │   ├── created_at: timestamp
    │   └── updated_at: timestamp
    │
    └── notification_logs/{log_id}
        ├── id: "event_id"
        ├── type: "received" | "opened"
        ├── timestamp: timestamp
        ├── payload: {...weather data...}
        ├── device_token: "fcm_token"
        ├── app_state: "foreground" | "background" | "terminated"
        └── created_at: timestamp
```

---

## 💾 LocalStorage (SharedPreferences)

```
fcm_notifications_enabled: true    ← FCM вкл/выкл
notification_sound_enabled: true   ← Звук вкл/выкл
notification_vibration_enabled: true ← Вибрация вкл/выкл
fcm_device_token: "abc123..."      ← Текущий токен
pending_notification_logs: [...]   ← Логи в ожидании отправки
last_notification_sync: timestamp  ← Время последней синхронизации
```

---

## 🐛 Troubleshooting

### Уведомления не приходят

1. **Убеждаться в разрешениях:**
   - Android: Settings → Apps → Weather → Notifications → ON
   - iOS: Settings → Notifications → Weather App → Allow

2. **Проверить token в Firestore:**
   ```
   Firebase Console → Firestore → users/{uid}/device_tokens
   ```

3. **Проверить логи:**
   ```bash
   flutter logs | grep FCM
   ```

### Разные версии зависимостей

Если возникают проблемы с версиями:
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Холодный старт не работает

- Убедитесь что приложение полностью закрыто (недостаточно Home)
- На Android: свернуть из Recent Apps (долгий клик на Home)
- На iOS: Xcode Debug → Stop, затем запустить через Xcode

---

## 📞 API Reference

### FCMService
```dart
await _fcmService.init();                           // Инициализировать
_fcmService.setOnNotificationReceived((payload) {}); // Callback foreground
_fcmService.setOnNotificationOpened((payload) {});  // Callback открытия
_fcmService.getDeviceToken();                       // Получить токен
await _fcmService.dispose();                        // Очистить
```

### TokenService
```dart
await _tokenService.init();                         // Инициализировать
await _tokenService.getToken();                     // Получить FCM token
await _tokenService.saveCurrentUserToken(uid);     // Сохранить в Firestore
await _tokenService.deleteCurrentUserToken(uid);   // Удалить при logout
```

### SettingsPresenter
```dart
await settingsPresenter.init();                     // Инициализировать
await settingsPresenter.setFCMEnabled(bool);       // Вкл/выкл FCM
await settingsPresenter.resetToDefaults();         // Сбросить
```

### NotificationPresenter
```dart
notificationPresenter.setCurrentUser(uid);          // Установить текущего пользователя
await notificationPresenter.loadNotificationEvents(); // Загрузить события
notificationPresenter.selectNotification(event);    // Выбрать для просмотра
```

---

## 📚 Дополнительные ресурсы

- [Firebase Documentation](https://firebase.flutter.dev/)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [workmanager](https://pub.dev/packages/workmanager)
- [Firebase Console](https://console.firebase.google.com)

---

## 📝 Лицензия

MIT

---

## 🎯 Next Steps

После успешного запуска:

1. [ ] Развернуть Cloud Functions для отправки каждый час
2. [ ] Настроить production Security Rules
3. [ ] Добавить Analytics
4. [ ] Выпустить на App Store / Play Store

---

**Версия:** 1.0  
**Дата:** 8 марта 2026  
**Статус:** ✅ Ready for testing
