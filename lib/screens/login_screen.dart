import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'technician_home_screen.dart';
import 'admin_home_screen.dart';
import 'register_screen.dart';
import 'technician_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _email.text = 'a@m.com';
    _password.text = '123456';
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {

      final userModel = await AuthService.signIn(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (userModel == null) {
        setState(() => _error = 'فشل تسجيل الدخول');
        return;
      }

      if (!mounted) return;


      if (userModel.isAccountFrozen) {
        Navigator.pushReplacementNamed(
          context,
          TechnicianSetupScreen.routeName,
          arguments: userModel.id,
        );
        return;
      }


      if (userModel.role == UserRole.technician) {
        Navigator.pushReplacementNamed(context, TechnicianHomeScreen.routeName);
      } else if (userModel.role == UserRole.admin) {
        Navigator.pushReplacementNamed(context, AdminHomeScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AppStrings.mapAuthErrorToArabic(e.code));
    } catch (e) {
      setState(() => _error = AppStrings.cleanErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(AppStyles.spacingXL),


              Text(
                'مرحبًا بك 👋',
                style: AppStyles.displayLarge,
                textAlign: TextAlign.right,
              ),
              const Gap(AppStyles.spacingMD),


              Text(
                'سجّل دخولك للمتابعة',
                style: AppStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.right,
              ),
              const Gap(AppStyles.spacingXL),


              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: AppStyles.inputDecoration('البريد الإلكتروني'),
                style: AppStyles.bodyLarge,
              ),
              const Gap(AppStyles.spacingMD),


              TextField(
                controller: _password,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                decoration: AppStyles.inputDecoration('كلمة المرور').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                ),
                style: AppStyles.bodyLarge,
              ),
              const Gap(AppStyles.spacingLG),


              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingMD),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      const Gap(AppStyles.spacingSM),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppStyles.spacingMD),
              ],


              _loading
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                  : ElevatedButton(
                    onPressed: _login,
                    style: AppStyles.primaryButton,
                    child: const Text('تسجيل الدخول'),
                  ),
              const Gap(AppStyles.spacingLG),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ليس لديك حساب؟ ',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(
                          context,
                          RegisterScreen.routeName,
                        ),
                    style: AppStyles.textButton,
                    child: const Text('إنشاء حساب جديد'),
                  ),
                ],
              ),
              const Gap(AppStyles.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}
