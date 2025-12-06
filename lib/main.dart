import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'services/dummy_data_service.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/technicians_list_screen.dart';
import 'screens/technician_details_screen.dart';
import 'screens/new_request_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/rating_screen.dart';
import 'screens/technician_setup_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/order_details_screen.dart';
import 'screens/technician_home_screen.dart';
import 'screens/technician_orders_screen.dart';
import 'screens/technician_order_details_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/admin_user_details_screen.dart';
import 'screens/admin_reviews_screen.dart';
import 'screens/technician_reviews_screen.dart';
import 'screens/notifications_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  DummyDataService.initializeDummyData().catchError((e) {
    print('Error initializing dummy data: $e');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'تطبيق الصيانة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ResponsiveBreakpoints.builder(
            child: content,
            breakpoints: const [
              Breakpoint(start: 0, end: 450, name: MOBILE),
              Breakpoint(start: 451, end: 900, name: TABLET),
              Breakpoint(start: 901, end: 1920, name: DESKTOP),
              Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          ),
        );
      },
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case RegisterScreen.routeName:
            page = const RegisterScreen();
            break;
          case LoginScreen.routeName:
            page = const LoginScreen();
            break;
          case HomeScreen.routeName:
            page = const HomeScreen();
            break;
          case TechniciansListScreen.routeName:
            page = const TechniciansListScreen();
            break;
          case TechnicianDetailsScreen.routeName:
            page = const TechnicianDetailsScreen();
            break;
          case NewRequestScreen.routeName:
            page = const NewRequestScreen();
            break;
          case MyOrdersScreen.routeName:
            page = const MyOrdersScreen();
            break;
          case ProfileScreen.routeName:
            page = const ProfileScreen();
            break;
          case SettingsScreen.routeName:
            page = const SettingsScreen();
            break;
          case RatingScreen.routeName:
            page = const RatingScreen();
            break;
          case TechnicianSetupScreen.routeName:
            page = TechnicianSetupScreen();
            break;
          case EditProfileScreen.routeName:
            page = const EditProfileScreen();
            break;
          case OrderDetailsScreen.routeName:
            page = const OrderDetailsScreen();
            break;
          case TechnicianHomeScreen.routeName:
            page = const TechnicianHomeScreen();
            break;
          case TechnicianOrdersScreen.routeName:
            page = const TechnicianOrdersScreen();
            break;
          case TechnicianOrderDetailsScreen.routeName:
            page = const TechnicianOrderDetailsScreen();
            break;
          case AdminHomeScreen.routeName:
            page = const AdminHomeScreen();
            break;
          case AdminUserDetailsScreen.routeName:
            page = const AdminUserDetailsScreen();
            break;
          case AdminReviewsScreen.routeName:
            page = const AdminReviewsScreen();
            break;
          case TechnicianReviewsScreen.routeName:
            page = const TechnicianReviewsScreen();
            break;
          case NotificationsScreen.routeName:
            page = const NotificationsScreen();
            break;
          case SplashScreen.routeName:
          default:
            page = const SplashScreen();
        }

        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          settings: settings,
        );
      },
      initialRoute: SplashScreen.routeName,
    );
  }
}
