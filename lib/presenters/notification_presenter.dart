import 'package:flutter/foundation.dart';
import 'package:weather_app/models/notification_event.dart';
import 'package:weather_app/models/notification_payload.dart';
import 'package:weather_app/repositories/notification_repository.dart';

/// Presenter для управления уведомлениями
class NotificationPresenter with ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  bool _isLoading = false;
  List<NotificationEvent> _events = [];
  NotificationPayload? _selectedNotification;
  String? _currentUid;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  List<NotificationEvent> get events => _events;
  NotificationPayload? get selectedNotification => _selectedNotification;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _events.where((e) => e.type == 'received').length;

  /// Установить текущего пользователя
  void setCurrentUser(String uid) {
    _currentUid = uid;
  }

  /// Загрузить события уведомлений
  Future<void> loadNotificationEvents() async {
    if (_currentUid == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _repository.getNotificationEvents(_currentUid!);
      print('[NotificationPresenter] Загружено событий: ${_events.length}');
    } catch (e) {
      _errorMessage = 'Ошибка при загрузке событий: $e';
      print('[NotificationPresenter] $errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Получить только открытые уведомления
  Future<void> loadOpenedNotifications() async {
    if (_currentUid == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events =
          await _repository.getOpenedNotifications(_currentUid!);
      print('[NotificationPresenter] Загружено открытых: ${_events.length}');
    } catch (e) {
      _errorMessage = 'Ошибка при загрузке открытых: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Получить только полученные уведомления
  Future<void> loadReceivedNotifications() async {
    if (_currentUid == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _repository
          .getReceivedNotifications(_currentUid!);
      print('[NotificationPresenter] Загружено полученных: ${_events.length}');
    } catch (e) {
      _errorMessage = 'Ошибка при загрузке полученных: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Выбрать уведомление для просмотра деталей
  void selectNotification(NotificationEvent event) {
    _selectedNotification = event.payload;
    print('[NotificationPresenter] Выбрано: ${event.payload.cityRu}');
    notifyListeners();
  }

  /// Очистить выбранное уведомление
  void clearSelectedNotification() {
    _selectedNotification = null;
    notifyListeners();
  }

  /// Удалить событие
  Future<void> deleteNotificationEvent(String eventId) async {
    if (_currentUid == null) return;

    try {
      await _repository.deleteNotificationEvent(_currentUid!, eventId);
      _events.removeWhere((e) => e.id == eventId);
      notifyListeners();
      print('[NotificationPresenter] Событие удалено');
    } catch (e) {
      _errorMessage = 'Ошибка при удалении: $e';
      notifyListeners();
    }
  }

  /// Фильтровать события по параметру
  List<NotificationEvent> filterEventsByCity(String city) =>
      _events.where((e) => e.payload.city.contains(city)).toList();

  /// Фильтровать события по типу
  List<NotificationEvent> filterEventsByType(String type) =>
      _events.where((e) => e.type == type).toList();

  /// Очистить ошибку
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Очистить все (для logout)
  void clear() {
    _events = [];
    _selectedNotification = null;
    _currentUid = null;
    _errorMessage = null;
    notifyListeners();
  }
}
