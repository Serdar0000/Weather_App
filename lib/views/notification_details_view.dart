import 'package:flutter/material.dart';
import 'package:weather_app/models/notification_payload.dart';

/// Экран с деталями уведомления
class NotificationDetailsView extends StatelessWidget {
  final NotificationPayload notification;
  final VoidCallback? onClose;

  const NotificationDetailsView({
    Key? key,
    required this.notification,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(notification.timestamp);
    final formattedDate =
        '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомление о погоде'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            onClose?.call();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка с основной информацией
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Город
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.cityRu,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              notification.city,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        // Температура
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${notification.temp.toStringAsFixed(1)}°C',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Температура',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Описание
                    Text(
                      notification.description,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Детали погоды
            Text(
              'Детали погоды',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Сетка с информацией
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _DetailCard(
                  label: 'Влажность',
                  value: '${notification.humidity.toStringAsFixed(0)}%',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                ),
                _DetailCard(
                  label: 'Ветер',
                  value: '${notification.windSpeed.toStringAsFixed(1)} м/с',
                  icon: Icons.air,
                  color: Colors.cyan,
                ),
                if (notification.pressure != null)
                  _DetailCard(
                    label: 'Давление',
                    value: '${notification.pressure} мб',
                    icon: Icons.compress,
                    color: Colors.purple,
                  ),
                if (notification.visibility != null)
                  _DetailCard(
                    label: 'Видимость',
                    value: '${notification.visibility} м',
                    icon: Icons.visibility,
                    color: Colors.grey,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // ID и время
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Метаданные',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _MetadataRow(
                      label: 'ID уведомления:',
                      value: notification.id.substring(0, 8) + '...',
                    ),
                    _MetadataRow(
                      label: 'Получено:',
                      value: formattedDate,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Кнопка закрытия
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  onClose?.call();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
                label: const Text('Закрыть'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Виджет для отображения детали
class _DetailCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Виджет для строки метаданных
class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
