import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  newOrder,
  orderAccepted,
  orderRejected,
  orderCompleted,
  orderCancelled,
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? orderId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.orderId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'orderId': orderId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      if (value is Timestamp) return value.toDate();
      return null;
    }

    NotificationType parseType(String? value) {
      switch (value) {
        case 'newOrder':
          return NotificationType.newOrder;
        case 'orderAccepted':
          return NotificationType.orderAccepted;
        case 'orderRejected':
          return NotificationType.orderRejected;
        case 'orderCompleted':
          return NotificationType.orderCompleted;
        case 'orderCancelled':
          return NotificationType.orderCancelled;
        default:
          return NotificationType.newOrder;
      }
    }

    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String,
      type: parseType(data['type'] as String?),
      title: data['title'] as String,
      body: data['body'] as String,
      orderId: data['orderId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }
}

