import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'technician_home_screen.dart';
import 'admin_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/dummy_data_service.dart';
import '../models/user_model.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _controller.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      return;
    }


    try {
      final userModel = await AuthService.getUserData(user.uid);
      if (userModel != null) {

        if (userModel.role == UserRole.customer) {
          DummyDataService.createDummyOrdersForUser(user.uid).catchError((e) {
            print('Error creating dummy orders: $e');
          });
        }

        if (userModel.isAccountFrozen) {

          Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
          return;
        }


        if (userModel.role == UserRole.technician) {
          Navigator.of(context).pushReplacementNamed(TechnicianHomeScreen.routeName);
          return;
        } else if (userModel.role == UserRole.customer) {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          return;
        } else if (userModel.role == UserRole.admin) {
          Navigator.of(context).pushReplacementNamed(AdminHomeScreen.routeName);
          return;
        }
      }
    } catch (e) {

      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      return;
    }

    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingXL),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.build_rounded,
                    color: AppColors.primary,
                    size: 64,
                  ),
                ),
                const Gap(AppStyles.spacingLG),
                Text(
                  'تطبيق الصيانة',
                  style: AppStyles.displayLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
