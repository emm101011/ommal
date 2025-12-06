import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'technician_setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  UserRole _selectedRole = UserRole.customer;
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _email.text = 'a@m.com';
    _password.text = '123456';
    _confirmPassword.text = '123456';
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {

    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'يرجى إدخال البريد الإلكتروني');
      return;
    }
    if (_password.text.isEmpty) {
      setState(() => _error = 'يرجى إدخال كلمة المرور');
      return;
    }
    if (_password.text.length < 6) {
      setState(() => _error = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (_password.text != _confirmPassword.text) {
      setState(() => _error = 'كلمات المرور غير متطابقة');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {

      final userModel = await AuthService.signUp(
        email: _email.text.trim(),
        password: _password.text,
        role: _selectedRole,
      );

      if (userModel == null) {
        setState(() => _error = 'فشل إنشاء الحساب');
        return;
      }

      if (!mounted) return;


      if (_selectedRole == UserRole.technician) {

        Navigator.pushReplacementNamed(
          context,
          TechnicianSetupScreen.routeName,
          arguments: userModel.id,
        );
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إرسال رابط التحقق إلى بريدك'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            ),
          ),
        );
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
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
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
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
                'إنشاء حساب جديد',
                style: AppStyles.displayLarge,
                textAlign: TextAlign.right,
              ),
              const Gap(AppStyles.spacingMD),


              Text(
                'اختر نوع حسابك للمتابعة',
                style: AppStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.right,
              ),
              const Gap(AppStyles.spacingXL),


              _buildRoleSelector(),
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
                textInputAction: TextInputAction.next,
                decoration: AppStyles.inputDecoration('كلمة المرور').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                style: AppStyles.bodyLarge,
              ),
              const Gap(AppStyles.spacingMD),


              TextField(
                controller: _confirmPassword,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signUp(),
                decoration: AppStyles.inputDecoration('تأكيد كلمة المرور').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const Gap(AppStyles.spacingSM),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppStyles.bodyMedium.copyWith(color: AppColors.error),
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
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _signUp,
                      style: AppStyles.primaryButton,
                      child: const Text('إنشاء الحساب'),
                    ),
              const Gap(AppStyles.spacingLG),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لديك حساب بالفعل؟ ',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      LoginScreen.routeName,
                    ),
                    style: AppStyles.textButton,
                    child: const Text('تسجيل الدخول'),
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

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الحساب',
          style: AppStyles.titleMedium,
          textAlign: TextAlign.right,
        ),
        const Gap(AppStyles.spacingMD),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                role: UserRole.customer,
                icon: Icons.person_outline,
                title: 'عميل',
                subtitle: 'طلب خدمات صيانة',
                isSelected: _selectedRole == UserRole.customer,
                onTap: () => setState(() => _selectedRole = UserRole.customer),
              ),
            ),
            const Gap(AppStyles.spacingMD),
            Expanded(
              child: _RoleCard(
                role: UserRole.technician,
                icon: Icons.build_outlined,
                title: 'فني',
                subtitle: 'تقديم خدمات',
                isSelected: _selectedRole == UserRole.technician,
                onTap: () => setState(() => _selectedRole = UserRole.technician),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  Color get _color {
    switch (role) {
      case UserRole.customer:
        return AppColors.customer;
      case UserRole.technician:
        return AppColors.technician;
      case UserRole.admin:
        return AppColors.admin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppStyles.spacingLG),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      _color.withOpacity(0.15),
                      _color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
            border: Border.all(
              color: isSelected ? _color : AppColors.border,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected ? AppTheme.softShadow : null,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.spacingMD),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _color.withOpacity(0.2)
                      : AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: isSelected ? _color : AppColors.textSecondary,
                ),
              ),
              const Gap(AppStyles.spacingMD),
              Text(
                title,
                style: AppStyles.titleMedium.copyWith(
                  color: isSelected ? _color : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              const Gap(AppStyles.spacingXS),
              Text(
                subtitle,
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
