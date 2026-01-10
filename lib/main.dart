import 'package:env_flutter/env_flutter.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/app.dart';

void main() async{
  await dotenv.load();
  runApp(const WeatherApp());
}

