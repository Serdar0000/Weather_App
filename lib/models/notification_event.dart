import 'notification_payload.dart';

/// Модель для логирования событий уведомлений
class NotificationEvent {
  final String id;
  final String type; // 'received' или 'opened'
  final int timestamp;
  final NotificationPayload payload;
  final String deviceToken;
  final String appState; // 'foreground', 'background', 'terminated'

  NotificationEvent({
    required this.id,
    required this.type,
    required this.payload,
    required this.deviceToken,
    required this.appState,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  /// Преобразовать в JSON для хранения
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'timestamp': timestamp,
        'payload': payload.toJson(),
        'device_token': deviceToken,
        'app_state': appState,
        'created_at': DateTime.now().toIso8601String(),
      };

  factory NotificationEvent.fromJson(Map<String, dynamic> json) =>
      NotificationEvent(
        id: json['id'] ?? '',
        type: json['type'] ?? 'received',
        payload: NotificationPayload.fromJson(json['payload'] ?? {}),
        deviceToken: json['device_token'] ?? '',
        appState: json['app_state'] ?? 'unknown',
        timestamp: json['timestamp'],
      );

  @override
  String toString() =>
      'NotificationEvent($type: ${payload.cityRu}, state: $appState)';
}
