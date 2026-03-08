import 'package:dio/dio.dart';
import 'package:env_flutter/env_flutter.dart' show dotenv;
import 'package:weather_app/models/weather.dart';

class WeatherRepository {
  final Dio dio = Dio();
  final String? apiKey = dotenv.env["API_KEY"];
  final weekdays = {
    1: "Понедельник",
    2: "Вторник",
    3: "Среда",
    4: "Четверг",
    5: "Пятница",
    6: "Суббота",
    7: "Воскресенье",
  };

  // Запрос на текущую погоду
  Future<Weather?> getWeather(String city) async {
    try {
      final response = await dio.get(
        "https://api.openweathermap.org/data/2.5/weather",
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric',
        },
      );

      final data = response.data;
      return Weather(
        temp: (data['main']['temp'] as num).round(),
        icon: data['weather'][0]['icon'].toString(),
        maxTemp: (data['main']['temp_max'] as num).round(),
        minTemp: (data['main']['temp_min'] as num).round(),
        type: data['weather'][0]['main'].toString(),
        humidity: (data['main']['humidity'] as num?)?.toDouble() ?? 0,
        windSpeed: (data['wind']['speed'] as num?)?.toDouble() ?? 0,
        pressure: (data['main']['pressure'] as num?)?.toInt() ?? 0,
        visibility: (data['visibility'] as num?)?.toInt() ?? 0,
        city: data['name'].toString(),
        country: data['sys']['country'].toString(),
      );
    } on DioException catch (e) {
      print("Error: ${e.message}");
      return null;
    }
  }

  // Запрос на неделю (forecast)
  Future<List<Weather>> getWeatherforWeek(String city) async {
    try {
      final response = await dio.get(
        "https://api.openweathermap.org/data/2.5/forecast",
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final List days = data["list"];
      final cityName = data["city"]["name"].toString();
      final countryName = data["city"]["country"].toString();
      
      List<Weather> res = []; // Создаем пустой список для результата
      String last_weekday = '';

      for (var value in days) {
        final weekday_number = DateTime.fromMillisecondsSinceEpoch(value['dt'] * 1000).weekday;
        final weekday = weekdays[weekday_number] ?? "";

        // Если этот день уже добавили, пропускаем остальные 3-часовые замеры
        if (weekday == last_weekday) {
          continue;
        }

        final weather = Weather(
          // Раз используем units=metric, просто округляем, вычитать 273 не надо
          temp: (value['main']['temp'] as num).round(),
          maxTemp: (value['main']['temp_max'] as num).round(),
          minTemp: (value['main']['temp_min'] as num).round(),
          icon: value['weather'][0]['icon'].toString(),
          weekday: weekday,
          type: value['weather'][0]['main'].toString(),
          humidity: (value['main']['humidity'] as num?)?.toDouble() ?? 0,
          windSpeed: (value['wind']['speed'] as num?)?.toDouble() ?? 0,
          pressure: (value['main']['pressure'] as num?)?.toInt() ?? 0,
          visibility: (value['visibility'] as num?)?.toInt() ?? 0,
          city: cityName,
          country: countryName,
        );

        res.add(weather);
        last_weekday = weekday;
      }
      return res;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}