import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.inProgress:
        return 'قيد التنفيذ';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  String get firestoreValue {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.inProgress:
        return 'inProgress';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromFirestore(String value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'inProgress':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String? technicianId;
  final String serviceType;
  final String address;
  final String description;
  final OrderStatus status;
  final List<String>? images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? rating;
  final String? review;
  final bool isDeleted;
  final String? cancelledBy;

  OrderModel({
    required this.id,
    required this.userId,
    this.technicianId,
    required this.serviceType,
    required this.address,
    required this.description,
    required this.status,
    this.images,
    required this.createdAt,
    this.updatedAt,
    this.rating,
    this.review,
    this.isDeleted = false,
    this.cancelledBy,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'technicianId': technicianId,
      'serviceType': serviceType,
      'address': address,
      'description': description,
      'status': status.firestoreValue,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'rating': rating,
      'review': review,
      'isDeleted': isDeleted,
      'cancelledBy': cancelledBy,
    };
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return OrderModel(
      id: doc.id,
      userId: data['userId'] as String,
      technicianId: data['technicianId'] as String?,
      serviceType: data['serviceType'] as String,
      address: data['address'] as String,
      description: data['description'] as String,
      status: OrderStatus.fromFirestore(data['status'] as String? ?? 'pending'),
      images: data['images'] != null
          ? List<String>.from(data['images'] as List)
          : null,
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(data['updatedAt']),
      rating: (data['rating'] as num?)?.toDouble(),
      review: data['review'] as String?,
      isDeleted: data['isDeleted'] as bool? ?? false,
      cancelledBy: data['cancelledBy'] as String?,
    );
  }
}

