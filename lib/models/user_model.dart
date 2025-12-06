import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  customer,
  technician,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'عميل';
      case UserRole.technician:
        return 'فني';
      case UserRole.admin:
        return 'مدير';
    }
  }

  String get firestoreValue {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.technician:
        return 'technician';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromFirestore(String value) {
    switch (value) {
      case 'customer':
        return UserRole.customer;
      case 'technician':
        return UserRole.technician;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? address;
  final UserRole role;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime? updatedAt;


  final List<String>? specialties;
  final String? bio;
  final double? rating;
  final int? totalOrders;
  final bool? isVerified;
  final String? profileImage;
  final bool isBlocked;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.address,
    required this.role,
    this.isProfileComplete = false,
    required this.createdAt,
    this.updatedAt,
    this.specialties,
    this.bio,
    this.rating,
    this.totalOrders,
    this.isVerified,
    this.profileImage,
    this.isBlocked = false,
  });


  bool get isAccountFrozen {
    return role == UserRole.technician && !isProfileComplete;
  }


  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'role': role.firestoreValue,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      if (role == UserRole.technician) ...{
        'specialties': specialties,
        'bio': bio,
      'rating': rating,
      'totalOrders': totalOrders,
      'isVerified': isVerified ?? false,
      },
      'profileImage': profileImage,
      'isBlocked': isBlocked,
    };
  }


  factory UserModel.fromFirestore(Map<String, dynamic> data) {

    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return UserModel(
      id: data['id'] as String,
      email: data['email'] as String,
      name: data['name'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      role: UserRole.fromFirestore(data['role'] as String? ?? 'customer'),
      isProfileComplete: data['isProfileComplete'] as bool? ?? false,
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(data['updatedAt']),
      specialties: data['specialties'] != null
          ? List<String>.from(data['specialties'] as List)
          : null,
      bio: data['bio'] as String?,
      rating: (data['rating'] as num?)?.toDouble(),
      totalOrders: data['totalOrders'] as int?,
      isVerified: data['isVerified'] as bool?,
      profileImage: data['profileImage'] as String?,
      isBlocked: data['isBlocked'] as bool? ?? false,
    );
  }


  factory UserModel.fromFirebaseAuth(
    String uid,
    String email, {
    UserRole role = UserRole.customer,
  }) {
    return UserModel(
      id: uid,
      email: email,
      role: role,
      isProfileComplete: role != UserRole.technician,
      createdAt: DateTime.now(),
    );
  }


  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    UserRole? role,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? specialties,
    String? bio,
    double? rating,
    int? totalOrders,
    bool? isVerified,
    String? profileImage,
    bool? isBlocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specialties: specialties ?? this.specialties,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      isVerified: isVerified ?? this.isVerified,
      profileImage: profileImage ?? this.profileImage,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

