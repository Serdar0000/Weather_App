# Android FCM Configuration Guide

## AndroidManifest.xml конфигурация

Добавьте в `android/app/src/main/AndroidManifest.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- FCM Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.VIBRATE" />
    
    <application
        android:label="Weather App"
        android:icon="@mipmap/ic_launcher">
        
        <!-- FCM Service -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <!-- Handle deep links from notifications -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="weather" android:host="notification" />
                <data android:scheme="weather" android:host="weather" />
            </intent-filter>
            
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            <meta-data
                android:name="io.flutter.embedding.android.SplashScreenDrawable"
                android:resource="@drawable/launch_background" />
        </activity>
        
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="weather_notifications" />

    </application>

</manifest>
```

## Gradle конфигурация

### android/app/build.gradle.kts

Убедитесь что добавлен google-services плагин:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // Added for Firebase
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

dependencies {
    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-messaging")
    
    // FCM
    implementation("com.google.firebase:firebase-messaging-ktx")
    
    // WorkManager (для background tasks)
    implementation("androidx.work:work-runtime-ktx:2.8.1")
}
```

### android/build.gradle.kts

```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
        classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.9")
    }
}
```

## Notification Icon

1. Создайте иконку размером 512x512 PNG (прозрачьный фон)
2. Используйте онлайн конвертер: [Android Asset Generator](https://www.androidassets.com/)
3. Поместите в: `android/app/src/main/res/drawable/notification.png`

Или подготовьте вручную для всех плотностей:
- `drawable-ldpi/notification.png` (36x36)
- `drawable-mdpi/notification.png` (48x48)
- `drawable-hdpi/notification.png` (72x72)
- `drawable-xhdpi/notification.png` (96x96)
- `drawable-xxhdpi/notification.png` (144x144)
- `drawable-xxxhdpi/notification.png` (192x192)

## Звук уведомления (опционально)

Поместите MP3 файл в `android/app/src/main/res/raw/notification.mp3`

## Background Task Setup

WorkManager автоматически настраивается через `background_tasks.dart`.

Для более надежной доставки добавьте в `MainActivity.kt`:

```kotlin
package com.example.weather_app

import android.os.Build
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Create notification channel for Android 8+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "weather_notifications"
            val channelName = "Weather Notifications"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(channelId, channelName, importance)
            channel.description = "Weather notifications from server"
            
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
```

## Testing на эмуляторе

```bash
# Запустить эмулятор с Google Play Services
flutter emulators --launch Pixel_4_API_30

# Убедиться что Google Play Services установлены в эмуляторе
# Settings → Apps → Show system → Google Play Services → убедиться что установлены

# Запустить приложение
flutter run

# Логирование
flutter logs -v
```

## Troubleshooting

### Ошибка: "FCM Token is null"
- ☑ Убедитесь что Google Play Services установлены на устройстве
- ☑ На эмуляторе: скачайте API с Google Play Services (API 30+)
- ☑ Перезагрузите эмулятор

### Ошибка: "POST_NOTIFICATIONS permission denied"
- ☑ Добавьте разрешение в AndroidManifest.xml
- ☑ На Android 13+: пользователь должен вручную разрешить в настройках
- ☑ Запросите разрешение в коде через flutter_local_notifications

### Уведомления не показываются в foreground
- ☑ Убедитесь что NotificationChannel создан (Android 8+)
- ☑ Проверьте что `flutter_local_notifications` инициализирован
- ☑ Проверьте что название channel_id совпадает везде

### Background service не вызывается
- ☑ Убедитесь что `firebaseMessagingBackgroundHandler` установлена
- ☑ Убедитесь что это top-level function, НЕ метод класса
