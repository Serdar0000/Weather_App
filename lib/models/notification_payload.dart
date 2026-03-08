  import 'package:uuid/uuid.dart';

/// Модель для payload уведомления
class NotificationPayload {
  final String id;
  final String city;
  final String cityRu;
  final double temp;
  final String description;
  final double humidity;
  final double windSpeed;
  final int? pressure;
  final int? visibility;
  final String? icon;
  final int timestamp;

  NotificationPayload({
    String? id,
    required this.city,
    required this.cityRu,
    required this.temp,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    this.pressure,
    this.visibility,
    this.icon,
    int? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  /// Преобразовать в JSON для отправки в FCM
  Map<String, String> toFcmData() => {
        'id': id,
        'city': city,
        'city_ru': cityRu,
        'temp': temp.toString(),
        'description': description,
        'humidity': humidity.toString(),
        'wind_speed': windSpeed.toString(),
        'pressure': pressure?.toString() ?? '',
        'visibility': visibility?.toString() ?? '',
        'icon': icon ?? '',
        'timestamp': timestamp.toString(),
      };

  /// Преобразовать из JSON (из FCM)
  factory NotificationPayload.fromMap(Map<String, dynamic> map) =>
      NotificationPayload(
        id: map['id'] ?? const Uuid().v4(),
        city: map['city'] ?? 'Unknown',
        cityRu: map['city_ru'] ?? 'Неизвестно',
        temp: double.tryParse(map['temp']?.toString() ?? '0') ?? 0.0,
        description: map['description'] ?? '',
        humidity: double.tryParse(map['humidity']?.toString() ?? '0') ?? 0.0,
        windSpeed: double.tryParse(map['wind_speed']?.toString() ?? '0') ?? 0.0,
        pressure: int.tryParse(map['pressure']?.toString() ?? ''),
        visibility: int.tryParse(map['visibility']?.toString() ?? ''),
        icon: map['icon'],
        timestamp: int.tryParse(map['timestamp']?.toString() ?? '') ??
            DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'city': city,
        'city_ru': cityRu,
        'temp': temp,
        'description': description,
        'humidity': humidity,
        'wind_speed': windSpeed,
        'pressure': pressure,
        'visibility': visibility,
        'icon': icon,
        'timestamp': timestamp,
      };

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      NotificationPayload.fromMap(json);

  @override
  String toString() =>
      'NotificationPayload(id: $id, city: $city, temp: $temp°C, desc: $description)';
}
