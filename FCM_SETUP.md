# Firebase Cloud Messaging Setup Guide

## 📋 Инструкция по настройке FCM

### 1. Firebase Console конфигурация

#### 1.1 Создать Firestore Database
1. Перейти в [Firebase Console](https://console.firebase.google.com/)
2. Выбрать проект
3. В левой панели: **Firestore Database** → **Create Database**
4. Выбрать режим: **Start in test mode** (для разработки)
5. Выбрать регион: **europe-west1** (или ближайший)

#### 1.2 Настроить Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Только авторизованные юзеры могут писать свои данные
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
      
      match /device_tokens/{tokenId} {
        allow read, write: if request.auth.uid == uid;
      }
      
      match /notification_logs/{logId} {
        allow read, write: if request.auth.uid == uid;
      }
    }
  }
}
```

### 2. Android конфигурация

#### 2.1 AndroidManifest.xml
Добавить разрешения в `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

#### 2.2 Добавить notification icon
1. Создать iконку для уведомлений (PNG)
2. Запустить Android resource converter: [androidassets.com](https://www.androidassets.com/)
3. Поместить в папки:
   - `android/app/src/main/res/drawable/` (512x512)
   - Система автоматически создаст нужные размеры

#### 2.3 gradle конфигурация
Уже настроено в `android/app/build.gradle.kts`, но проверьте наличие:
```kotlin
dependencies {
    // FCM (если нет)
    implementation("com.google.firebase:firebase-messaging-ktx")
}
```

### 3. iOS конфигурация

#### 3.1 Добавить capabilities в Xcode
1. Открыть `ios/Runner.xcworkspace` в Xcode (НЕ `Runner.xcodeproj`)
2. Выбрать **Runner** в левой панели
3. Выбрать target **Runner**
4. Вкладка **Signing & Capabilities**
5. Нажать **+ Capability** и добавить:
   - **Push Notifications**
   - **Background Modes** → выбрать:
     - ☑ Remote notifications
     - ☑ Background fetch

#### 3.2 Сертификаты APNs
1. В Apple Developer: [developer.apple.com](https://developer.apple.com)
2. Перейти в **Certificates, Identifiers & Profiles**
3. Создать или обновить **APNs Certificate** (Production)
4. В Firebase Console → **Project Settings** → **Cloud Messaging** → **iOS**
5. Загрузить APNs certificate

### 4. Отправка тестового уведомления

#### Способ 1: Firebase Console
1. Firebase Console → **Cloud Messaging**
2. Нажать **Create campaign** → **Compose message**
3. Заполнить:
   - **Title**: "Test Weather"
   - **Body**: "Temperature: 15°C"
4. В **Additional options** → **Custom data**:
```
id: test-123
city: London
city_ru: Лондон
temp: 15.5
description: Partly cloudy
humidity: 60
wind_speed: 5.2
```
5. Нажать **Send test message**
6. Выбрать устройство и отправить

#### Способ 2: Cloud Function (каждый час)
Создать файл `functions/index.js`:

```javascript
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// Отправить уведомление каждый час
exports.scheduleWeatherNotification = functions
  .pubsub.schedule("every 1 hours")
  .timeZone("Europe/London")
  .onRun(async (context) => {
    try {
      // Получить все активные device tokens
      const tokensSnapshot = await db
        .collectionGroup("device_tokens")
        .get();

      const tokens = tokensSnapshot.docs
        .map((doc) => doc.data().token)
        .filter((token) => token);

      if (tokens.length === 0) {
        console.log("No device tokens found");
        return;
      }

      // Подготовить сообщение
      const message = {
        notification: {
          title: "🌤️ Weather Update",
          body: "Temperature: 15°C, Partly cloudy",
        },
        data: {
          id: "weather-" + Date.now(),
          city: "London",
          city_ru: "Лондон",
          temp: "15.5",
          description: "Partly cloudy",
          humidity: "60",
          wind_speed: "5.2",
          pressure: "1013",
          visibility: "10000",
          timestamp: Date.now().toString(),
        },
      };

      // Отправить всем токенам
      const response = await messaging.sendMulticast(
        { ...message, tokens }
      );

      console.log(
        `Successfully sent ${response.successCount} messages, failed: ${response.failureCount}`
      );
      return null;
    } catch (error) {
      console.error("Error sending notification:", error);
      return null;
    }
  });

// Очистить старые токены
exports.cleanupOldTokens = functions
  .pubsub.schedule("every 24 hours")
  .timeZone("Europe/London")
  .onRun(async (context) => {
    try {
      const now = Date.now();
      const thirtyDaysAgo = now - 30 * 24 * 60 * 60 * 1000;

      const snapshot = await db
        .collectionGroup("device_tokens")
        .where("updated_at", "<", thirtyDaysAgo)
        .get();

      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`Deleted ${snapshot.docs.length} old tokens`);
      return null;
    } catch (error) {
      console.error("Error cleaning up tokens:", error);
      return null;
    }
  });
```

Развернуть:
```bash
cd functions
npm install
firebase deploy --only functions
```

### 5. Firestore структура

```
firestore/
├── users/{uid}
│   ├── device_tokens/{token_id}
│   │   ├── token: "fcm_token_xxx"
│   │   ├── platform: "android" | "ios"
│   │   ├── created_at: timestamp
│   │   └── updated_at: timestamp
│   │
│   └── notification_logs/{log_id}
│       ├── id: "notification_id"
│       ├── type: "received" | "opened"
│       ├── timestamp: timestamp
│       ├── payload: {...}
│       ├── device_token: "..."
│       └── app_state: "foreground" | "background" | "terminated"
```

### 6. Local Storage (SharedPreferences)

```
fcm_notifications_enabled: true/false      # Включено ли FCM
notification_sound_enabled: true/false     # Включен ли звук
notification_vibration_enabled: true/false # Включена ли вибрация
pending_notification_logs: [...]           # Очередь логов для отправки
```

### 7. Логирование событий

Приложение логирует:
- ✅ `received` - когда уведомление получено (foreground/background/terminated)
- ✅ `opened` - когда пользователь нажимает на уведомление
- ✅ `device_token` - обновление токена при изменении

Логи хранятся:
- Локально в SharedPreferences
- Отправляются в Firestore каждый час (WorkManager background)

### 8. Testing

#### Тестирование Foreground
1. Приложение открыто
2. Отправить тестовое уведомление
3. Должно показаться локальное уведомление
4. При нажатии - открыть NotificationDetailsScreen

#### Тестирование Background
1. Приложение в background (нажать Home)
2. Отправить тестовое уведомление
3. Уведомление придёт системой
4. При нажатии - приложение откроется и покажет DetailScreen

#### Тестирование Terminated
1. Закрыть приложение (свернуть из recent apps)
2. Отправить тестовое уведомление
3. Нажать на уведомление
4. Приложение запустится и покажет DetailScreen

#### Тестирование Deep Link
1. Использовать payload с `id` параметром
2. При нажатии должно открыться `notification://details?id=UUID`

### 9. Troubleshooting

#### Уведомления не приходят
- ☑ Проверить device token в Logcat
- ☑ Проверить что FCM Permission предоставлено
- ☑ Проверить Security Rules в Firestore
- ☑ В Android: Settings → Notifications → Weather App → Include → ON

#### Foreground уведомления не показываются
- ☑ Проверить что NotificationService инициализирован
- ☑ Проверить что Android notification channel создан
- ☑ В Android 13+: метроговое разрешение POST_NOTIFICATIONS

#### Background tasks не работают
- ☑ Проверить что WorkManager инициализирован в main.dart
- ☑ В Android: Settings → App Battery → Weather App → Don't optimize
- ☑ В iOS: Background App Refresh должен быть включен

### 10. Отправка уведомления с API

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/{PROJECT_ID}/messages:send \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "{DEVICE_TOKEN}",
      "notification": {
        "title": "Weather Update",
        "body": "Temperature: 15°C"
      },
      "data": {
        "id": "weather-123",
        "city": "London",
        "city_ru": "Лондон",
        "temp": "15.5",
        "description": "Partly cloudy",
        "humidity": "60",
        "wind_speed": "5.2"
      }
    }
  }'
```
