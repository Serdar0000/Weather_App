# 📋 Реализованный функционал FCM

## ✅ Реализовано

### 1. Models
- ✅ `notification_payload.dart` - Модель данных уведомления
- ✅ `notification_event.dart` - Модель события уведомления

### 2. Services
- ✅ `fcm_service.dart` - Основной сервис FCM (обработка 3 states)
- ✅ `token_service.dart` - Управление device tokens
- ✅ `notification_service.dart` - Локальные уведомления (foreground)
- ✅ `deep_link_service.dart` - Парсинг deep links
- ✅ `event_logger_service.dart` - Логирование событий
- ✅ `background_tasks.dart` - WorkManager для синхронизации каждый час

### 3. Repositories
- ✅ `notification_repository.dart` - Работа с Firestore
- ✅ `settings_repository.dart` - Работа с SharedPreferences

### 4. Presenters
- ✅ `notification_presenter.dart` - Управление состоянием уведомлений
- ✅ `settings_presenter.dart` - Управление настройками

### 5. Views
- ✅ `notification_details_view.dart` - Экран деталей уведомления
- ✅ `settings_view.dart` - Экран настроек (вкл/выкл FCM)

### 6. Конфигурация
- ✅ `pubspec.yaml` - Все зависимости добавлены
- ✅ `main.dart` - Инициализация FCM и background tasks
- ✅ `app.dart` - Integration FCM, deep links, navigation

### 7. Documentation
- ✅ `FCM_SETUP.md` - Полная инструкция по настройке
- ✅ `ANDROID_FCM_CONFIG.md` - Android конфигурация
- ✅ `IOS_FCM_CONFIG.md` - iOS конфигурация
- ✅ `FCM_EXAMPLES.md` - Примеры использования

---

## 🎯 Функциональность

### Получение и обработка уведомлений
```
✅ Foreground: показ локального уведомления при открытом приложении
✅ Background: обработка нажатия на системное уведомление
✅ Terminated: холодный запуск приложения по deep link
```

### Device Token управление
```
✅ Получение FCM token при авторизации
✅ Сохранение в Firestore (users/{uid}/device_tokens/{token})
✅ Сохранение локально в SharedPreferences
✅ Обновление при изменении токена
✅ Удаление при logout
```

### Логирование events
```
✅ Локальное хранение в SharedPreferences (pending_logs)
✅ Логирование: тип (received/opened), timestamp, payload, appState
✅ Синхронизация с Firestore каждый час (WorkManager)
✅ Очистка после успешной отправки
```

### Deep Linking
```
✅ Парсинг UUID из payload
✅ Навигация на NotificationDetailsScreen
✅ Передача всех параметров (city, temp, humidity и т.д.)
```

### Настройки уведомлений
```
✅ Toggle FCM (вкл/выкл) - SharedPreferences
✅ Toggle Sound (вкл/выкл) - SharedPreferences  
✅ Toggle Vibration (вкл/выкл) - SharedPreferences
✅ Сброс на значения по умолчанию
```

---

## 🚀 Шаги для запуска

### 1. Установить зависимости
```bash
flutter pub get
```

### 2. Настроить Firebase
- [ ] Создать Firestore Database в Firebase Console
- [ ] Добавить Security Rules (см. FCM_SETUP.md)
- [ ] Загрузить google-services.json (уже должен быть)

### 3. Android конфигурация
- [ ] Добавить разрешение в AndroidManifest.xml (POST_NOTIFICATIONS)
- [ ] Создать notification icon
- [ ] Запустить на Android 8+ (API 26+)

### 4. iOS конфигурация
- [ ] Добавить Push Notifications capability в Xcode
- [ ] Добавить Background Modes capability
- [ ] Загрузить APNs certificate в Firebase
- [ ] Обновить AppDelegate.swift

### 5. Собрать и запустить
```bash
flutter run
```

### 6. Тестировать
- [ ] Отправить тестовое уведомление через Firebase Console
- [ ] Проверить foreground notification
- [ ] Проверить background notification
- [ ] Проверить terminated (cold start)
- [ ] Проверить что детали открываются корректно

### 7. Cloud Functions (опционально)
- [ ] Развернуть functions для отправки каждый час
- [ ] Проверить логирование в Firestore
- [ ] Проверить синхронизацию в фоне

---

## 📁 Структура файлов

```
lib/
├── models/
│   ├── notification_payload.dart  ✅
│   ├── notification_event.dart    ✅
│   └── weather.dart              (существует)
│
├── services/
│   ├── fcm_service.dart          ✅
│   ├── token_service.dart        ✅
│   ├── notification_service.dart ✅
│   ├── deep_link_service.dart    ✅
│   ├── event_logger_service.dart ✅
│   ├── background_tasks.dart     ✅
│   ├── auth_service.dart         (существует)
│   └── (others)
│
├── repositories/
│   ├── notification_repository.dart  ✅
│   ├── settings_repository.dart      ✅
│   └── weatherRepository.dart        (существует)
│
├── presenters/
│   ├── notification_presenter.dart   ✅
│   ├── settings_presenter.dart       ✅
│   ├── auth_presenter.dart           (существует)
│   └── weather_presenter.dart        (существует)
│
├── views/
│   ├── notification_details_view.dart ✅
│   ├── settings_view.dart             ✅
│   ├── login_view.dart                (существует)
│   ├── register_view.dart             (существует)
│   └── weather_view.dart              (существует)
│
├── main.dart      ✅ (обновлён)
├── app.dart       ✅ (обновлён)
└── (others)

root/
├── FCM_SETUP.md                ✅
├── ANDROID_FCM_CONFIG.md       ✅
├── IOS_FCM_CONFIG.md           ✅
├── FCM_EXAMPLES.md             ✅
├── FCM_CHECKLIST.md            ✅ (этот файл)
├── pubspec.yaml                ✅ (обновлён)
└── (others)
```

---

## 🔍 Как работает

### Lifecycle 1: Приложение открыто (Foreground)

```
1. User не авторизирован
   → Auth страницы (Login/Register)

2. User авторизирован
   → app.dart инициализирует FCM
   → TokenService получает device token
   → Token сохранияется в Firestore + LocalStorage

3. FCM уведомление приходит
   → firebaseMessagingBackgroundHandler вызывается
   → Если foreground: показать локальное уведомление
   → При нажатии: вызвать _handleNotificationOpened

4. User нажимает на уведомление
   → Вызвать deep link handler
   → Открыть NotificationDetailsView
   → Залогировать event = 'opened'
   → Сохранить локально прямо же
```

### Lifecycle 2: Приложение в Background

```
1. System notification приходит
   → firebaseMessagingBackgroundHandler обработает
   → Залогировать event = 'received'

2. User нажимает на уведомление
   → Приложение переходит из background в foreground
   → FirebaseMessaging.onMessageOpenedApp срабатывает
   → Вызвать _handleBackgroundMessageTap
   → Открыть NotificationDetailsView
   → Залогировать event = 'opened'
```

### Lifecycle 3: Приложение Terminated (Cold Start)

```
1. System notification приходит
   → firebaseMessagingBackgroundHandler обработает
   → Залогировать event = 'received'

2. User нажимает на уведомление
   → Android/iOS запускает приложение с intent
   → main.dart запускается
   → app.dart инициализирует FCM
   → FCMService.init() проверит getInitialMessage()
   → Если есть: вызвать _handleTerminatedMessageTap
   → Открыть NotificationDetailsView
   → Залогировать event = 'opened'
```

### Lifecycle 4: Фоновая синхронизация (каждый час)

```
1. WorkManager планирует задачу на каждый час
2. Когда час прошеёл:
   → callbackDispatcher вызывается
   → syncNotificationLogsWithFirestore() срабатывает
   → Получить все pending_logs из SharedPreferences
   → Для каждого лога:
      → Отправить в Firestore (users/{uid}/notification_logs/{id})
   → Очистить pending_logs
   → Обновить last_sync timestamp
```

### Lifecycle 5: Settings
```
1. User открывает SettingsView
   → SettingsPresenter инициализируется
   → Загружаются текущие значения из SharedPreferences
   
2. User меняет toggle (FCM/Sound/Vibration)
   → Сохранить в SharedPreferences
   → Обновить UI
   
3. User нажимает "Сбросить":
   → Удалить все значения из SharedPreferences
   → Вернуть на defaults (все true)
```

---

## 🧪 Тестирование

### Тест 1: Foreground Notification
1. Запустить приложение
2. Отправить тестовое уведомление через Firebase Console
3. ✅ Должно появиться локальное уведомление сверху
4. Нажать на уведомление
5. ✅ Должно открыться NotificationDetailsView

### Тест 2: Background Notification
1. Приложение в background (нажать Home/Recent)
2. Отправить тестовое уведомление
3. ✅ Должно появиться в notification center
4. Нажать на уведомление
5. ✅ Приложение откроется с NotificationDetailsView

### Тест 3: Terminated (Cold Start)
1. Полностью закрыть приложение (свернуть из recent)
2. Отправить тестовое уведомление
3. Нажать на уведомление
4. ✅ Приложение запустится и покажет NotificationDetailsView

### Тест 4: Deep Linking
1. Отправить payload с id параметром
2. При нажатии
3. ✅ Должно открыться weather://notification/details?id={UUID}

### Тест 5: Settings
1. Открыть Settings из UI
2. ✅ Все toggles должны загружаться корректно
3. Выключить FCM
4. ✅ Уведомления не должны приходить (нужна логика)
5. Включить FCM
6. ✅ Уведомления должны приходить снова

### Тест 6: Logging
1. Получить несколько уведомлений
2. Открыть некоторые из них
3. ✅ Логи должны быть в SharedPreferences
4. Подождать очередную синхронизацию (часа)
5. ✅ Логи должны быть в Firestore

---

## 📝 Дополнительные TODO

### Для продакшена
- [ ] Отключить debug mode в WorkManager (background_tasks.dart)
- [ ] Добавить proper error handling для Cloud Functions
- [ ] Реализовать retry logic для failed notifications
- [ ] Добавить encryption для sensitive data
- [ ] Настроить production Security Rules (не test mode)

### UI Improvements
- [ ] Добавить notification badge на settings icon
- [ ] Добавить animation при открытии DetailView
- [ ] Добавить swipe to dismiss на notification cards
- [ ] Добавить notification categories (weather, system, etc)

### Features
- [ ] Группировка уведомлений по городам
- [ ] Фильтрация уведомлений по типу
- [ ] Export логов как CSV/JSON
- [ ] Analytics для событий
- [ ] Rich notifications (images, actions)

---

## 🆘 Troubleshooting

### Ошибка: "firebaseMessagingBackgroundHandler not found"
**Решение:** Убедитесь что функция определена как TOP LEVEL (не внутри класса)

### Ошибка: "Token is null"
**Решение:** Проверьте что Google Play Services установлены на устройстве

### Ошибка: "NotificationChannel error"
**Решение:** На Android 8+ нужно создать NotificationChannel (уже реализовано)

### Логи не отправляются в Firestore
**Решение:** Проверьте Security Rules и что uid правильно передан

### Settings не сохраняются
**Решение:** Убедитесь что SharedPreferences инициализирован перед использованием

---

## 📞 Support

Если возникают проблемы:
1. Проверить консоль Firebase (Logs)
2. Проверить Logcat (Android) или Xcode logs (iOS)
3. Включить debug logging в services
4. Проверить Security Rules в Firestore
5. Убедиться что разрешения предоставлены

---

**Дата создания:** 8 марта 2026
**Версия:** 1.0
**Статус:** ✅ Ready for testing
