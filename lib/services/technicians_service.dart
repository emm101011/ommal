import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class TechniciansService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static Stream<QuerySnapshot> getTechnicians({String? specialty}) {
    var query = _firestore
        .collection('users')
        .where('role', isEqualTo: 'technician')
        .where('isProfileComplete', isEqualTo: true);

    if (specialty != null && specialty != 'الكل') {
      query = query.where('specialties', arrayContains: specialty);
    }

    return query.snapshots();
  }


  static Future<UserModel?> getTechnicianById(String technicianId) async {
    try {
      final doc = await _firestore.collection('users').doc(technicianId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc.data()!);
    } catch (e) {
      return null;
    }
  }


  static Stream<QuerySnapshot> getTechniciansBySpecialty(String specialty) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'technician')
        .where('isProfileComplete', isEqualTo: true)
        .where('specialties', arrayContains: specialty)
        .snapshots();
  }
}

