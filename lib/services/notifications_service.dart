import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static Future<void> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? orderId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': type.name,
        'title': title,
        'body': body,
        'orderId': orderId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }


  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }


  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }


  static Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }


  static Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }


  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }


  static Future<void> notifyNewOrder({
    required String technicianId,
    required String orderId,
    required String customerName,
    required String serviceType,
  }) async {
    await createNotification(
      userId: technicianId,
      type: NotificationType.newOrder,
      title: 'طلب خدمة جديد',
      body: 'لديك طلب جديد من $customerName - $serviceType',
      orderId: orderId,
    );
  }


  static Future<void> notifyOrderAccepted({
    required String customerId,
    required String orderId,
    required String technicianName,
  }) async {
    await createNotification(
      userId: customerId,
      type: NotificationType.orderAccepted,
      title: 'تم قبول طلبك',
      body: 'قام $technicianName بقبول طلبك',
      orderId: orderId,
    );
  }


  static Future<void> notifyOrderRejected({
    required String customerId,
    required String orderId,
    required String technicianName,
  }) async {
    await createNotification(
      userId: customerId,
      type: NotificationType.orderRejected,
      title: 'تم رفض طلبك',
      body: 'قام $technicianName برفض طلبك',
      orderId: orderId,
    );
  }


  static Future<void> notifyOrderCompleted({
    required String customerId,
    required String orderId,
    required String technicianName,
  }) async {
    await createNotification(
      userId: customerId,
      type: NotificationType.orderCompleted,
      title: 'تم إكمال طلبك',
      body: 'قام $technicianName بإكمال طلبك',
      orderId: orderId,
    );
  }


  static Future<void> notifyOrderCancelled({
    required String userId,
    required String orderId,
    required String cancelledBy,
    String? otherUserName,
  }) async {
    final title = cancelledBy == 'customer' 
        ? 'تم إلغاء الطلب'
        : 'تم رفض الطلب';
    final body = cancelledBy == 'customer'
        ? 'قام العميل بإلغاء الطلب'
        : otherUserName != null
            ? 'قام $otherUserName برفض الطلب'
            : 'تم رفض الطلب';

    await createNotification(
      userId: userId,
      type: NotificationType.orderCancelled,
      title: title,
      body: body,
      orderId: orderId,
    );
  }


  static Future<List<String>> getAllAdminIds() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting admin IDs: $e');
      return [];
    }
  }


  static Future<void> notifyAllAdmins({
    required NotificationType type,
    required String title,
    required String body,
    String? orderId,
  }) async {
    final adminIds = await getAllAdminIds();
    for (final adminId in adminIds) {
      await createNotification(
        userId: adminId,
        type: type,
        title: title,
        body: body,
        orderId: orderId,
      );
    }
  }


  static Future<void> notifyAdminsNewOrder({
    required String customerName,
    required String technicianName,
    required String orderId,
    required String serviceType,
  }) async {
    await notifyAllAdmins(
      type: NotificationType.newOrder,
      title: 'طلب خدمة جديد',
      body: 'قام $customerName بطلب خدمة $serviceType من $technicianName',
      orderId: orderId,
    );
  }


  static Future<void> notifyAdminsOrderAccepted({
    required String technicianName,
    required String customerName,
    required String orderId,
  }) async {
    await notifyAllAdmins(
      type: NotificationType.orderAccepted,
      title: 'تم قبول الطلب',
      body: 'قام $technicianName بالموافقة على طلب $customerName',
      orderId: orderId,
    );
  }


  static Future<void> notifyAdminsOrderRejected({
    required String technicianName,
    required String customerName,
    required String orderId,
  }) async {
    await notifyAllAdmins(
      type: NotificationType.orderRejected,
      title: 'تم رفض الطلب',
      body: 'قام $technicianName برفض طلب $customerName',
      orderId: orderId,
    );
  }


  static Future<void> notifyAdminsOrderCompleted({
    required String technicianName,
    required String customerName,
    required String orderId,
  }) async {
    await notifyAllAdmins(
      type: NotificationType.orderCompleted,
      title: 'تم إكمال الطلب',
      body: 'قام $technicianName بإكمال طلب $customerName',
      orderId: orderId,
    );
  }
}

