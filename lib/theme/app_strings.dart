class AppStrings {
  static const String appName = 'تطبيق الصيانة';


  static const String homeTitle = 'الرئيسية';
  static const String ordersTitle = 'الطلبات';
  static const String profileTitle = 'الملف الشخصي';
  static const String settingsTitle = 'الإعدادات';

  static const String techniciansTitle = 'الفنيون المتاحون';
  static const String technicianDetailsTitle = 'بيانات الفني';
  static const String newRequestTitle = 'طلب خدمة جديد';
  static const String loginTitle = 'تسجيل الدخول';
  static const String ratingTitle = 'تقييم الخدمة';


  static String mapAuthErrorToArabic(String message) {
    final m = message.toLowerCase();


    if (m.contains('invalid-credential') || 
        m.contains('wrong-password') || 
        m.contains('user-not-found')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    if (m.contains('user-disabled')) {
      return 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم';
    }

    if (m.contains('email-already-in-use') || 
        m.contains('account-exists-with-different-credential')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    }

    if (m.contains('weak-password')) {
      return 'كلمة المرور ضعيفة. يجب أن تكون 6 أحرف على الأقل';
    }

    if (m.contains('invalid-email')) {
      return 'البريد الإلكتروني غير صحيح';
    }

    if (m.contains('operation-not-allowed')) {
      return 'هذه العملية غير مسموحة';
    }

    if (m.contains('too-many-requests')) {
      return 'تم إرسال طلبات كثيرة. يرجى المحاولة بعد قليل';
    }

    if (m.contains('network-request-failed') || 
        m.contains('network') ||
        m.contains('socketexception')) {
      return 'خطأ في الاتصال بالإنترنت. تحقق من اتصالك';
    }

    if (m.contains('timeout') || m.contains('deadline-exceeded')) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
    }

    if (m.contains('email-not-verified') || 
        m.contains('requires-recent-login')) {
      return 'يرجى تأكيد البريد الإلكتروني أولاً';
    }

    if (m.contains('invalid-verification-code') || 
        m.contains('invalid-verification-id')) {
      return 'رمز التحقق غير صحيح';
    }

    if (m.contains('session-expired')) {
      return 'انتهت جلسة العمل. يرجى تسجيل الدخول مرة أخرى';
    }


    if (m.contains('firebase') || 
        m.contains('auth') ||
        m.contains('authentication')) {
      return 'حدث خطأ في المصادقة. يرجى المحاولة مرة أخرى';
    }


    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
  }


  static String cleanErrorMessage(dynamic error) {
    if (error == null) return 'حدث خطأ غير معروف';

    String errorStr = error.toString();


    errorStr = errorStr
        .replaceAll('Exception: ', '')
        .replaceAll('Error: ', '')
        .replaceAll('PlatformException(', '')
        .replaceAll('FirebaseAuthException: ', '')
        .replaceAll('FirebaseException: ', '');


    errorStr = errorStr.replaceAll(RegExp(r'\[.*?\]'), '');


    errorStr = errorStr.replaceAll(RegExp(r'\(.*?:\d+\)'), '');


    errorStr = errorStr.trim();


    if (errorStr.contains('package:') || 
        errorStr.contains('dart:') ||
        errorStr.contains('firebase_auth') ||
        errorStr.length > 100) {
      return mapAuthErrorToArabic(errorStr);
    }

    return mapAuthErrorToArabic(errorStr);
  }
}
