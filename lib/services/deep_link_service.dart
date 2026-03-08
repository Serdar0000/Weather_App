import 'package:weather_app/models/notification_payload.dart';

/// Сервис для обработки deep links из payload уведомлений
class DeepLinkService {
  static const String notificationDetailsScheme = 'weather://notification';
  static const String weatherDetailsScheme = 'weather://weather';

  /// Парсить deep link из payload
  /// Возвращает тип и параметры
  static (String type, Map<String, String> params)? parseDeepLink(
    NotificationPayload payload,
  ) {
    try {
      // Генерируем deep link на основе payload
      // Формат: weather://notification/details?id=UUID
      final params = <String, String>{
        'id': payload.id,
        'city': payload.city,
        'city_ru': payload.cityRu,
        'temp': payload.temp.toString(),
      };

      return ('notification_details', params);
    } catch (e) {
      print('[DeepLinkService] Ошибка при парсинге: $e');
      return null;
    }
  }

  /// Создать deep link по ID
  static String createNotificationDetailsLink(String id) {
    return '$notificationDetailsScheme/details?id=$id';
  }

  /// Создать deep link для погоды
  static String createWeatherDetailsLink(String cityId) {
    return '$weatherDetailsScheme/details?id=$cityId';
  }

  /// Проверить, является ли строка валидным deep link
  static bool isValidDeepLink(String link) {
    return link.startsWith(notificationDetailsScheme) ||
        link.startsWith(weatherDetailsScheme);
  }

  /// Извлечь параметры из query string
  static Map<String, String> extractQueryParams(String queryString) {
    final params = <String, String>{};
    final pairs = queryString.split('&');
    for (final pair in pairs) {
      final keyValue = pair.split('=');
      if (keyValue.length == 2) {
        params[keyValue[0]] = Uri.decodeComponent(keyValue[1]);
      }
    }
    return params;
  }
}
