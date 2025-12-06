import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  static Stream<QuerySnapshot> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }


  static Stream<QuerySnapshot> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }


  static Stream<QuerySnapshot> getTechnicianOrders(String technicianId) {
    return _firestore
        .collection('orders')
        .where('technicianId', isEqualTo: technicianId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }


  static Stream<QuerySnapshot> getPendingOrdersForTechnician(String technicianId) {
    return _firestore
        .collection('orders')
        .where('technicianId', isEqualTo: technicianId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }


  static Future<DocumentSnapshot?> getOrderById(String orderId) async {
    try {
      return await _firestore.collection('orders').doc(orderId).get();
    } catch (e) {
      return null;
    }
  }


  static Future<String?> createOrder({
    required String userId,
    required String serviceType,
    required String address,
    required String description,
    String? technicianId,
    List<String>? images,
  }) async {
    try {
      final docRef = await _firestore.collection('orders').add({
        'userId': userId,
        'technicianId': technicianId,
        'serviceType': serviceType,
        'address': address,
        'description': description,
        'status': 'pending',
        'images': images,
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }


  static Future<bool> updateOrderStatus(
    String orderId,
    String status, {
    String? cancelledBy,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (cancelledBy != null) {
        updateData['cancelledBy'] = cancelledBy;
      }
      await _firestore.collection('orders').doc(orderId).update(updateData);
      return true;
    } catch (e) {
      return false;
    }
  }


  static Future<bool> submitRating({
    required String orderId,
    required double rating,
    String? review,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'rating': rating,
        'review': review,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }


  static Future<bool> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }


  static Future<bool> cancelOrderByCustomer(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelledBy': 'customer',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }


  static Future<double?> calculateTechnicianRating(String technicianId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .where('rating', isNotEqualTo: null)
          .get();

      if (snapshot.docs.isEmpty) return null;

      double totalRating = 0.0;
      int ratedCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final rating = data['rating'];
        if (rating != null) {
          totalRating += (rating as num).toDouble();
          ratedCount++;
        }
      }

      if (ratedCount == 0) return null;
      return totalRating / ratedCount;
    } catch (e) {
      return null;
    }
  }


  static Future<int> calculateTechnicianTotalOrders(String technicianId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }


  static Future<int> calculateCustomerTotalOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }


  static Future<bool> deleteReview(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'review': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}

