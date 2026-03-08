import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:env_flutter/env_flutter.dart' show dotenv;
import 'package:weather_app/app.dart';
import 'package:weather_app/firebase_options.dart';
import 'package:weather_app/presenters/auth_presenter.dart';
import 'package:weather_app/presenters/weather_presenter.dart';
import 'package:weather_app/presenters/notification_presenter.dart';
import 'package:weather_app/presenters/settings_presenter.dart';
import 'package:weather_app/services/background_tasks.dart';
import 'package:weather_app/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Установить background handler для FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Инициализировать фоновые задачи
  await initBackgroundTasks();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthPresenter()),
        ChangeNotifierProvider(create: (_) => WeatherPresenter()),
        ChangeNotifierProvider(create: (_) => NotificationPresenter()),
        ChangeNotifierProvider(create: (_) => SettingsPresenter()),
      ],
      child: const WeatherApp(),
    ),
  );
}

