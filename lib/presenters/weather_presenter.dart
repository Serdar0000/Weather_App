import 'package:flutter/foundation.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/repositories/weatherRepository.dart';

class WeatherPresenter extends ChangeNotifier {
  final WeatherRepository _weatherRepository = WeatherRepository();

  Weather? _currentWeather;
  List<Weather>? _weekWeather;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentCity = 'Astana';

  // Getters
  Weather? get currentWeather => _currentWeather;
  List<Weather>? get weekWeather => _weekWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentCity => _currentCity;

  /// Load weather data for a city
  Future<void> loadWeather(String city) async {
    _currentCity = city.isEmpty ? 'Astana' : city;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dayData = await _weatherRepository.getWeather(_currentCity);
      final weekData = await _weatherRepository.getWeatherforWeek(_currentCity);

      _currentWeather = dayData;
      _weekWeather = weekData;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Ошибка загрузки погоды: $e';
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
