import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:env_flutter/env_flutter.dart' show dotenv;
import 'package:weather_app/app.dart';
import 'package:weather_app/firebase_options.dart';
import 'package:weather_app/presenters/auth_presenter.dart';
import 'package:weather_app/presenters/weather_presenter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthPresenter()),
        ChangeNotifierProvider(create: (_) => WeatherPresenter()),
      ],
      child: const WeatherApp(),
    ),
  );
}

