import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static User? get currentUser => _auth.currentUser;


  static Stream<User?> get authStateChanges => _auth.authStateChanges();


  static Future<UserModel?> signUp({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;


      final userModel = UserModel.fromFirebaseAuth(
        credential.user!.uid,
        email,
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());


      await credential.user!.sendEmailVerification();

      return userModel;
    } catch (e) {
      throw Exception('خطأ في التسجيل: ${e.toString()}');
    }
  }


  static Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;


      return await getUserData(credential.user!.uid);
    } catch (e) {
      throw Exception('خطأ في تسجيل الدخول: ${e.toString()}');
    }
  }


  static Future<void> signOut() async {
    await _auth.signOut();
  }


  static Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {

        final user = _auth.currentUser;
        if (user != null) {
          final userModel = UserModel.fromFirebaseAuth(
            user.uid,
            user.email ?? '',
            role: UserRole.customer,
          );
          await _firestore
              .collection('users')
              .doc(userId)
              .set(userModel.toFirestore());
          return userModel;
        }
        return null;
      }

      return UserModel.fromFirestore(doc.data()!);
    } catch (e) {
      throw Exception('خطأ في جلب بيانات المستخدم: ${e.toString()}');
    }
  }


  static Stream<UserModel?> getUserDataStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc.data()!);
    });
  }


  static Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('خطأ في تحديث الملف الشخصي: ${e.toString()}');
    }
  }


  static Future<bool> toggleUserBlock(String userId, bool block) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isBlocked': block,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }


  static Future<void> updateProfileImage({
    required String userId,
    required String imageBase64,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImage': imageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في تحديث صورة الملف الشخصي: ${e.toString()}');
    }
  }


  static Future<void> completeTechnicianProfile({
    required String userId,
    required String name,
    required String phone,
    required String address,
    required List<String> specialties,
    required String bio,
    String? profileImageBase64,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'name': name,
        'phone': phone,
        'address': address,
        'specialties': specialties,
        'bio': bio,
        'isProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (profileImageBase64 != null) {
        updateData['profileImage'] = profileImageBase64;
      }

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('خطأ في تحديث ملف الفني: ${e.toString()}');
    }
  }


  static Future<bool> isAccountFrozen(String userId) async {
    try {
      final userData = await getUserData(userId);
      return userData?.isAccountFrozen ?? false;
    } catch (e) {
      return false;
    }
  }


  static Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}

