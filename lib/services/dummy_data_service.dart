import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DummyDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;


  static const String _dummyPassword = '123456';


  static Future<bool> _checkDummyDataExists() async {
    try {

      final techDoc = await _firestore.collection('users').where('role', isEqualTo: 'technician').limit(1).get();

      final customerDoc = await _firestore.collection('users').where('role', isEqualTo: 'customer').limit(1).get();
      return techDoc.docs.isNotEmpty && customerDoc.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }


  static Future<void> createDummyAdmin() async {
    try {
      const email = 'admin@m.com';


      final existingUsers = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        print('حساب المدير موجود بالفعل');
        return;
      }


      final uid = await _createAuthAccount(
        email: email,
        password: _dummyPassword,
      );

      if (uid == null) {
        print('فشل إنشاء حساب Firebase Auth للمدير');
        return;
      }


      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'email': email,
        'name': 'مدير النظام',
        'phone': '0500000000',
        'address': 'الرياض',
        'role': 'admin',
        'isProfileComplete': true,
        'isBlocked': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 600)).toIso8601String(),
      });

      print('✓ تم إنشاء حساب المدير: admin@m.com');
    } catch (e) {
      print('✗ خطأ في إنشاء حساب المدير: $e');
    }
  }


  static Future<void> createDummyCustomers() async {
    final customers = [
      {
        'email': 'a1@m.com',
        'name': 'إبراهيم علي',
        'phone': '0501111111',
        'address': 'الرياض - حي العليا - شارع التحلية',
        'role': 'customer',
        'isProfileComplete': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 100)),
      },
      {
        'email': 'b2@m.com',
        'name': 'جمال محمد',
        'phone': '0502222222',
        'address': 'الرياض - حي النرجس - شارع الملك فهد',
        'role': 'customer',
        'isProfileComplete': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 80)),
      },
      {
        'email': 'c3@m.com',
        'name': 'خالد سعيد',
        'phone': '0503333333',
        'address': 'الرياض - حي المطار - شارع العروبة',
        'role': 'customer',
        'isProfileComplete': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 60)),
      },
      {
        'email': 'd4@m.com',
        'name': 'لؤي أحمد',
        'phone': '0504444444',
        'address': 'الرياض - حي الياسمين - شارع العليا',
        'role': 'customer',
        'isProfileComplete': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 40)),
      },
      {
        'email': 'e5@m.com',
        'name': 'ماجد حسن',
        'phone': '0505555555',
        'address': 'الرياض - حي النخيل - شارع الأمير سلطان',
        'role': 'customer',
        'isProfileComplete': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      },
    ];

    for (var customer in customers) {
      try {
        final email = customer['email'] as String;


        final existingUsers = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (existingUsers.docs.isNotEmpty) {
          print('العميل ${customer['name']} موجود بالفعل');
          continue;
        }


        final uid = await _createAuthAccount(
          email: email,
          password: _dummyPassword,
        );

        if (uid == null) {
          print('فشل إنشاء حساب Firebase Auth للعميل: ${customer['name']}');
          continue;
        }


        await _firestore.collection('users').doc(uid).set({
          'id': uid,
          'email': email,
          'name': customer['name'],
          'phone': customer['phone'],
          'address': customer['address'],
          'role': customer['role'],
          'isProfileComplete': customer['isProfileComplete'],
          'isBlocked': false,
          'createdAt': (customer['createdAt'] as DateTime).toIso8601String(),
        });

        print('✓ تم إنشاء عميل: ${customer['name']} (${email})');
      } catch (e) {
        print('✗ خطأ في إنشاء عميل ${customer['name']}: $e');
      }
    }
  }


  static Future<String?> _createAuthAccount({
    required String email,
    required String password,
  }) async {
    try {
      // محاولة تسجيل الدخول أولاً للتحقق من وجود الحساب
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        final user = _auth.currentUser;
        // عدم تسجيل الخروج - البقاء مسجلاً لإنشاء البيانات في Firestore
        return user?.uid;
      } catch (e) {
        // الحساب غير موجود، سننشئه
      }

      // إنشاء حساب جديد
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // البقاء مسجلاً لإنشاء البيانات
      return credential.user?.uid;
    } catch (e) {
      // في حالة الخطأ، محاولة تسجيل الدخول مرة أخرى
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = _auth.currentUser;
        return user?.uid;
      } catch (_) {
        // فشل تماماً
      }
      return null;
    }
  }


  static Future<void> createDummyTechnicians() async {
    final technicians = [
      {
        'id': 'tech_001',
        'email': 'a@m.com',
        'name': 'أحمد محمد',
        'phone': '0501234567',
        'address': 'الرياض - حي النرجس - شارع الملك فهد',
        'role': 'technician',
        'isProfileComplete': true,
        'specialties': ['سباكة'],
        'bio': 'فني سباكة محترف مع أكثر من 10 سنوات من الخبرة في إصلاح جميع أنواع المشاكل',
        'rating': 4.8,
        'totalOrders': 156,
        'isVerified': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 365)),
      },
      {
        'id': 'tech_002',
        'email': 'b@m.com',
        'name': 'بدر خالد',
        'phone': '0502345678',
        'address': 'الرياض - حي العليا - شارع التحلية',
        'role': 'technician',
        'isProfileComplete': true,
        'specialties': ['كهرباء'],
        'bio': 'مهندس كهرباء متخصص في إصلاح الأعطال الكهربائية المنزلية والتجارية',
        'rating': 4.9,
        'totalOrders': 203,
        'isVerified': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 400)),
      },
      {
        'id': 'tech_003',
        'email': 'c@m.com',
        'name': 'خالد عبدالله',
        'phone': '0503456789',
        'address': 'الرياض - حي المطار - شارع العروبة',
        'role': 'technician',
        'isProfileComplete': true,
        'specialties': ['تكييف'],
        'bio': 'متخصص في صيانة وتركيب أجهزة التكييف بجميع أنواعها',
        'rating': 4.7,
        'totalOrders': 189,
        'isVerified': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 300)),
      },
      {
        'id': 'tech_004',
        'email': 'd@m.com',
        'name': 'داوود حسن',
        'phone': '0504567890',
        'address': 'الرياض - حي الياسمين - شارع العليا',
        'role': 'technician',
        'isProfileComplete': true,
        'specialties': ['تنظيف'],
        'bio': 'خدمات تنظيف شاملة للمنازل والمكاتب بأحدث المعدات',
        'rating': 4.6,
        'totalOrders': 142,
        'isVerified': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 250)),
      },
      {
        'id': 'tech_005',
        'email': 'e@m.com',
        'name': 'محمد صالح',
        'phone': '0505678901',
        'address': 'الرياض - حي النخيل - شارع الأمير سلطان',
        'role': 'technician',
        'isProfileComplete': true,
        'specialties': ['نجارة'],
        'bio': 'نجار محترف متخصص في صناعة وإصلاح الأثاث الخشبي',
        'rating': 4.5,
        'totalOrders': 98,
        'isVerified': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 200)),
      },
      {
        'id': 'tech_006',
        'email': 'f@m.com',
        'name': 'فهد أحمد',
        'phone': '0506789012',
        'address': 'الرياض - حي العريجاء - شارع العليا',
        'role': 'technician',
        'isProfileComplete': true,
        'specialties': ['مكافحة حشرات'],
        'bio': 'خدمات مكافحة الحشرات والقوارض بطرق آمنة وفعالة',
        'rating': 4.8,
        'totalOrders': 167,
        'isVerified': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 180)),
      },
      {
        'id': 'tech_007',
        'email': 'g@m.com',
        'name': 'علي خالد',
        'phone': '0507890123',
        'address': 'الرياض - حي الشفا - شارع العليا',
        'role': 'technician',
        'isProfileComplete': true,
        'specialties': ['سباكة', 'كهرباء'],
        'bio': 'فني متعدد التخصصات في السباكة والكهرباء مع خبرة واسعة',
        'rating': 4.7,
        'totalOrders': 234,
        'isVerified': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 500)),
      },
      {
        'id': 'tech_008',
        'email': 'h@m.com',
        'name': 'حسام محمود',
        'phone': '0508901234',
        'address': 'الرياض - حي الورود - شارع الملك فهد',
        'role': 'technician',
        'isProfileComplete': true,
        'specialties': ['تكييف', 'تنظيف'],
        'bio': 'متخصص في صيانة التكييف والتنظيف العميق',
        'rating': 4.6,
        'totalOrders': 178,
        'isVerified': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 320)),
      },
    ];

    for (var tech in technicians) {
      try {
        final email = tech['email'] as String;
        final techId = tech['id'] as String;


        final doc = await _firestore.collection('users').doc(techId).get();
        if (doc.exists) {
          print('الفني ${tech['name']} موجود بالفعل');
          continue;
        }


        final uid = await _createAuthAccount(
          email: email,
          password: _dummyPassword,
        );

        if (uid == null) {
          print('فشل إنشاء حساب Firebase Auth للفني: ${tech['name']}');
          continue;
        }


        await _firestore.collection('users').doc(uid).set({
          'id': uid,
          'email': email,
          'name': tech['name'],
          'phone': tech['phone'],
          'address': tech['address'],
          'role': tech['role'],
          'isProfileComplete': tech['isProfileComplete'],
          'isBlocked': false,
          'specialties': tech['specialties'],
          'bio': tech['bio'],
          'rating': tech['rating'],
          'totalOrders': tech['totalOrders'],
          'isVerified': tech['isVerified'],
          'createdAt': (tech['createdAt'] as DateTime).toIso8601String(),
        });

        print('✓ تم إنشاء فني: ${tech['name']} (${email})');
      } catch (e) {
        print('✗ خطأ في إنشاء فني ${tech['name']}: $e');
      }
    }
  }


  static Future<void> createDummyOrders(String currentUserId) async {
    final orders = [
      {
        'userId': currentUserId,
        'technicianId': 'tech_001',
        'serviceType': 'سباكة',
        'address': 'الرياض - حي النرجس - شارع الملك فهد',
        'description': 'يوجد تسرب ماء في الحمام الرئيسي، يحتاج إلى إصلاح فوري',
        'status': 'completed',
        'rating': 5.0,
        'review': 'خدمة ممتازة، تم الإصلاح بسرعة واحترافية',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 4)),
      },
      {
        'userId': currentUserId,
        'technicianId': 'tech_002',
        'serviceType': 'كهرباء',
        'address': 'الرياض - حي العليا - شارع التحلية',
        'description': 'انقطاع التيار الكهربائي في غرفة المعيشة',
        'status': 'inProgress',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'userId': currentUserId,
        'technicianId': 'tech_003',
        'serviceType': 'تكييف',
        'address': 'الرياض - حي المطار - شارع العروبة',
        'description': 'جهاز التكييف لا يعمل بشكل صحيح، يحتاج إلى صيانة',
        'status': 'pending',
        'createdAt': DateTime.now().subtract(const Duration(hours: 6)),
      },
      {
        'userId': currentUserId,
        'serviceType': 'تنظيف',
        'address': 'الرياض - حي الياسمين - شارع العليا',
        'description': 'تنظيف شامل للمنزل',
        'status': 'pending',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'userId': currentUserId,
        'technicianId': 'tech_005',
        'serviceType': 'نجارة',
        'address': 'الرياض - حي النخيل - شارع الأمير سلطان',
        'description': 'إصلاح باب الخزانة المكسور',
        'status': 'completed',
        'rating': 4.5,
        'review': 'عمل جيد، لكن كان يمكن أن يكون أسرع',
        'createdAt': DateTime.now().subtract(const Duration(days: 10)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 9)),
      },
      {
        'userId': currentUserId,
        'technicianId': 'tech_006',
        'serviceType': 'مكافحة حشرات',
        'address': 'الرياض - حي العريجاء - شارع العليا',
        'description': 'وجود نمل في المطبخ',
        'status': 'completed',
        'rating': 4.8,
        'review': 'تم حل المشكلة بشكل نهائي، شكراً',
        'createdAt': DateTime.now().subtract(const Duration(days: 15)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 14)),
      },
    ];

    for (var order in orders) {
      try {
        final orderData = {
          ...order,
          'createdAt': (order['createdAt'] as DateTime).toIso8601String(),
          if (order['updatedAt'] != null)
            'updatedAt': (order['updatedAt'] as DateTime).toIso8601String(),
        };
        await _firestore.collection('orders').add(orderData);
        print('تم إنشاء طلب: ${order['serviceType']}');
      } catch (e) {
        print('خطأ في إنشاء طلب: $e');
      }
    }
  }


  static Future<void> initializeDummyData() async {
    try {
      // التحقق من وجود البيانات
      final exists = await _checkDummyDataExists();
      if (exists) {
        print('البيانات التجريبية موجودة بالفعل');
        return;
      }

      print('بدء إنشاء البيانات التجريبية...');

      // إنشاء المدير
      await createDummyAdmin();

      // إنشاء الفنيين
      await createDummyTechnicians();

      // إنشاء العملاء
      await createDummyCustomers();
      
      // تسجيل الخروج بعد إنشاء جميع البيانات
      await _auth.signOut();

      print('✓ تم إنشاء جميع البيانات التجريبية بنجاح!');
      print('\n👑 حساب المدير (كلمة المرور: 123456):');
      print('  - admin@m.com (مدير النظام)');
      print('\n📋 حسابات الفنيين (كلمة المرور: 123456):');
      print('  - a@m.com (أحمد محمد - سباكة)');
      print('  - b@m.com (بدر خالد - كهرباء)');
      print('  - c@m.com (خالد عبدالله - تكييف)');
      print('  - d@m.com (داوود حسن - تنظيف)');
      print('  - e@m.com (محمد صالح - نجارة)');
      print('  - f@m.com (فهد أحمد - مكافحة حشرات)');
      print('  - g@m.com (علي خالد - سباكة وكهرباء)');
      print('  - h@m.com (حسام محمود - تكييف وتنظيف)');
      print('\n👤 حسابات العملاء (كلمة المرور: 123456):');
      print('  - a1@m.com (إبراهيم علي)');
      print('  - b2@m.com (جمال محمد)');
      print('  - c3@m.com (خالد سعيد)');
      print('  - d4@m.com (لؤي أحمد)');
      print('  - e5@m.com (ماجد حسن)');
    } catch (e) {
      print('✗ خطأ في إنشاء البيانات التجريبية: $e');
      // تسجيل الخروج حتى في حالة الخطأ
      await _auth.signOut();
    }
  }


  static Future<void> createDummyOrdersForUser(String userId) async {
    try {

      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (ordersSnapshot.docs.isNotEmpty) {
        print('الطلبات التجريبية موجودة بالفعل للمستخدم');
        return;
      }

      await createDummyOrders(userId);
      print('✓ تم إنشاء الطلبات التجريبية');
    } catch (e) {
      print('✗ خطأ في إنشاء الطلبات: $e');
    }
  }
}

