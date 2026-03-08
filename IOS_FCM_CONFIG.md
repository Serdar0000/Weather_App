# iOS FCM Configuration Guide

## XCode Setup

### 1. Открыть workspace
```bash
cd ios
open Runner.xcworkspace
```

### 2. Добавить Capabilities

1. Выбрать **Runner** в левой панели (не Runner.xcodeproj, а sам Runner)
2. Выбрать target **Runner**
3. Вкладка **Signing & Capabilities**
4. Нажать **+ Capability** и добавить:

#### 2.1 Push Notifications
1. Нажать **+ Capability**
2. Поиск: "Push Notifications"
3. Выбрать и добавить

#### 2.2 Background Modes
1. Нажать **+ Capability**
2. Поиск: "Background Modes"
3. Выбрать и добавить
4. В чекбоксах отметить:
   - ☑ Remote notifications
   - ☑ Background fetch
   - ☑ Background processing (если iOS 13+)

### 3. Set Up Apple Push Notifications

#### 3.1 Apple Developer Certificate

1. Перейти на [developer.apple.com](https://developer.apple.com)
2. **Certificates, Identifiers & Profiles**
3. **Identifiers** → выбрать App ID
4. Отметить **Push Notifications** capability
5. **Certificates** → создать **Apple Push Notification service SSL Certificate**
   - Выбрать **Production** (для App Store)
   - Выбрать ваш Bundle ID
6. Скачать `.cer` файл

#### 3.2 Конвертировать сертификат

```bash
# Открыть .cer файл в Keychain Access
open ~/Downloads/aps_production_ios.cer

# Экспортировать из Keychain:
# 1. Найти сертификат (Apple Push Services: com.yourcompany.yourapp)
# 2. Right click → Export
# 3. Сохранить как .p12 файл (запомнить пароль)

# Конвертировать в PEM
openssl pkcs12 -in Certificates.p12 -out Certificates.pem -nodes -clcerts
```

#### 3.3 Загрузить в Firebase

1. Firebase Console → Project Settings
2. **Cloud Messaging** вкладка
3. **iOS app configuration**
4. **Upload APNs Certificate**
5. Загрузить `Certificates.pem` файл

### 4. Info.plist конфигурация

Убедитесь что в `ios/Runner/Info.plist` есть:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... other configs ... -->
    
    <!-- Firebase Configuration -->
    <key>FirebaseCloudMessagingEnabled</key>
    <true/>
    
    <!-- Deep Linking Schemes -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>weather</string>
            </array>
        </dict>
    </array>
    
</dict>
</plist>
```

### 5. Podfile конфигурация

Убедитесь что в `ios/Podfile`:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    # Добавить для Firebase compatibility
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

Запустить:
```bash
cd ios
pod install --repo-update
cd ..
```

### 6. AppDelegate.swift обновление

Убедитесь что в `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase initialization
    FirebaseApp.configure()
    
    // Set up notification delegate
    UNUserNotificationCenter.current().delegate = self
    
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle notification when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([[.banner, .sound, .badge]])
  }
  
  // Handle notification tap
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    
    // Handle deep link
    // Can be used to navigate to specific screen
    
    completionHandler()
  }
}
```

## Testing на Simulator

### Device Setup
1. Xcode → Window → Devices and Simulators
2. Выбрать simulator
3. Убедиться что iOS 13+ (для соответствия требованиям)

### Отправить test notification

```bash
# Using xcrun command
xcrun simctl push booted com.yourcompany.weather '{
  "aps": {
    "alert": {
      "title": "Weather Update",
      "body": "Temperature: 15°C"
    },
    "badge": 1,
    "sound": "default",
    "custom_data": {
      "id": "test-123",
      "city": "London",
      "city_ru": "Лондон",
      "temp": "15.5"
    }
  }
}'
```

## Troubleshooting

### APNs Certificate Error
- ☑ Убедитесь что сертификат в PEM формате
- ☑ Убедитесь что выбран PRODUCTION certificate (не Development)
- ☑ Проверьте Bundle ID совпадает с App ID

### Notification не приходит на simulator
- ☑ Simulator не поддерживает push notifications native
- ☑ Используйте реальное устройство для тестирования
- ☑ Или используйте локальные уведомления (flutter_local_notifications)

### Background fetch не работает
- ☑ Убедитесь что Background Modes включены в capabilities
- ☑ Проверьте что в AppDelegate.swift правильная конфигурация
- ☑ На реальном устройстве: Settings → Privacy → Background App Refresh

### Deep linking не работает
- ☑ Убедитесь что в Info.plist добавлены CFBundleURLSchemes
- ☑ Bundle Identifier должен совпадать во всех местах
- ☑ Проверьте что deep link правильно форматирован

### Фоновые задачи не выполняются
- ☑ На iOS требуется Background App Refresh capability
- ☑ WorkManager на iOS имеет ограничения (запускается как background task)
- ☑ Рекомендуется использовать APNs для пробуждения приложения
