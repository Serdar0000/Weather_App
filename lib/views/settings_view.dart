import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/presenters/settings_presenter.dart';

/// Экран настроек уведомлений
class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    // Инициализировать presenter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsPresenter>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки уведомлений'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsPresenter>(
        builder: (context, settingsPresenter, _) {
          if (settingsPresenter.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Ошибка если есть
                if (settingsPresenter.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            settingsPresenter.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        IconButton(
                          onPressed: settingsPresenter.clearError,
                          icon: const Icon(Icons.close),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),

                // Основные настройки
                _SettingSection(
                  title: 'Основные',
                  children: [
                    _SettingSwitchTile(
                      title: 'Push-уведомления',
                      subtitle:
                          'Получать уведомления от сервера о погоде и событиях',
                      value: settingsPresenter.fcmEnabled,
                      onChanged: (value) {
                        settingsPresenter.setFCMEnabled(value);
                      },
                      leading: Icons.notifications,
                    ),
                  ],
                ),

                // Звук и вибрация
                _SettingSection(
                  title: 'Звук и вибрация',
                  children: [
                    _SettingSwitchTile(
                      title: 'Звук уведомления',
                      subtitle: 'Проигрывать звук при получении уведомления',
                      value: settingsPresenter.soundEnabled,
                      onChanged: (value) {
                        settingsPresenter.setSoundEnabled(value);
                      },
                      leading: Icons.volume_up,
                    ),
                    const Divider(height: 1),
                    _SettingSwitchTile(
                      title: 'Вибрация',
                      subtitle: 'Вибрировать при получении уведомления',
                      value: settingsPresenter.vibrationEnabled,
                      onChanged: (value) {
                        settingsPresenter.setVibrationEnabled(value);
                      },
                      leading: Icons.vibration,
                    ),
                  ],
                ),

                // Информационная секция
                _SettingSection(
                  title: 'Информация',
                  children: [
                    _SettingInfoTile(
                      title: 'О уведомлениях',
                      subtitle:
                          'Уведомления помогают вам оставаться в курсе актуальной информации о погоде и важных событиях.',
                      icon: Icons.info,
                    ),
                  ],
                ),

                // Кнопки действий
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Кнопка сброса
                      OutlinedButton.icon(
                        onPressed: () {
                          _showResetConfirmationDialog(
                            context,
                            settingsPresenter,
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Сбросить настройки'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Кнопка закрытия
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Готово'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Показать диалог подтверждения сброса
  void _showResetConfirmationDialog(
    BuildContext context,
    SettingsPresenter presenter,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Сбросить настройки?'),
        content: const Text(
          'Все настройки будут возвращены на значения по умолчанию.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              presenter.resetToDefaults();
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}

/// Секция настроек
class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// Switch tile для настроек
class _SettingSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? leading;

  const _SettingSwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        leading: leading != null ? Icon(leading) : null,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Info tile для информационных секций
class _SettingInfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const _SettingInfoTile({
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        leading: icon != null ? Icon(icon) : null,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
