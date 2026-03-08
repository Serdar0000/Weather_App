import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather_app/models/notification_event.dart';

/// Репозиторий для работы с уведомлениями в Firestore
class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Сохранить событие уведомления в Firestore
  Future<void> logNotificationEvent(String uid, NotificationEvent event) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notification_logs')
          .doc(event.id)
          .set(event.toJson(), SetOptions(merge: true));

      print('[NotificationRepository] Событие сохранено: ${event.type}');
    } catch (e) {
      print('[NotificationRepository] Ошибка при сохранении события: $e');
      rethrow;
    }
  }

  /// Получить все события уведомлений пользователя
  Future<List<NotificationEvent>> getNotificationEvents(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notification_logs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => NotificationEvent.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('[NotificationRepository] Ошибка при получении событий: $e');
      return [];
    }
  }

  /// Получить события типа 'opened'
  Future<List<NotificationEvent>> getOpenedNotifications(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notification_logs')
          .where('type', isEqualTo: 'opened')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => NotificationEvent.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('[NotificationRepository] Ошибка при получении открытых: $e');
      return [];
    }
  }

  /// Получить события типа 'received'
  Future<List<NotificationEvent>> getReceivedNotifications(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notification_logs')
          .where('type', isEqualTo: 'received')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => NotificationEvent.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('[NotificationRepository] Ошибка при получении полученных: $e');
      return [];
    }
  }

  /// Получить события за определённый период времени
  Future<List<NotificationEvent>> getNotificationEventsByTimeRange(
    String uid,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notification_logs')
          .where('timestamp',
              isGreaterThanOrEqualTo: startTime.millisecondsSinceEpoch)
          .where('timestamp', isLessThanOrEqualTo: endTime.millisecondsSinceEpoch)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationEvent.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('[NotificationRepository] Ошибка при получении событий по периоду: $e');
      return [];
    }
  }

  /// Удалить событие
  Future<void> deleteNotificationEvent(String uid, String eventId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notification_logs')
          .doc(eventId)
          .delete();

      print('[NotificationRepository] Событие удалено');
    } catch (e) {
      print('[NotificationRepository] Ошибка при удалении события: $e');
      rethrow;
    }
  }

  /// Удалить все события пользователя (WARNING: опасно!)
  Future<void> deleteAllNotificationEvents(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notification_logs')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('[NotificationRepository] Все события удалены');
    } catch (e) {
      print('[NotificationRepository] Ошибка при удалении всех событий: $e');
      rethrow;
    }
  }

  /// Stream для real-time получения событий
  Stream<List<NotificationEvent>> watchNotificationEvents(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notification_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationEvent.fromJson(doc.data()))
          .toList();
    });
  }
}
