import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../theme/app_strings.dart';
import '../services/auth_service.dart';
import '../services/orders_service.dart';
import '../models/user_model.dart';
import '../utils/image_helper.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userData;
  bool _loading = true;
  double? _realRating;
  int _realTotalOrders = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = AuthService.currentUser;
    if (user != null) {
      try {
        final userData = await AuthService.getUserData(user.uid);
        if (mounted) {
          setState(() {
            _userData = userData;
            _loading = false;
          });


          if (userData?.role == UserRole.technician) {
            final realRating = await OrdersService.calculateTechnicianRating(user.uid);
            final realTotalOrders = await OrdersService.calculateTechnicianTotalOrders(user.uid);
            if (mounted) {
              setState(() {
                _realRating = realRating;
                _realTotalOrders = realTotalOrders;
              });
            }
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppStrings.profileTitle,
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppStrings.profileTitle,
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(
          child: Text('لا توجد بيانات'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.profileTitle,
          style: AppStyles.headlineSmall,
        ),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: () async {
              await AuthService.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.routeName,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.spacingLG),
          child: Column(
            children: [
              const Gap(AppStyles.spacingLG),


              _buildProfileImage(),
              const Gap(AppStyles.spacingMD),


              Text(
                _userData!.name ?? 'بدون اسم',
                style: AppStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const Gap(4),
              Text(
                _userData!.email,
                style: AppStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const Gap(AppStyles.spacingXL),


              if (_userData!.phone != null)
                _InfoCard(
                  icon: Icons.phone_outlined,
                  title: 'رقم الجوال',
                  value: _userData!.phone!,
                ),
              if (_userData!.phone != null) const Gap(AppStyles.spacingMD),
              if (_userData!.address != null)
                _InfoCard(
                  icon: Icons.location_on_outlined,
                  title: 'العنوان',
                  value: _userData!.address!,
                ),
              if (_userData!.address != null) const Gap(AppStyles.spacingXL),


              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.spacingMD,
                  vertical: AppStyles.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: _getRoleColor(_userData!.role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                  border: Border.all(
                    color: _getRoleColor(_userData!.role),
                    width: 1,
                  ),
                ),
                child: Text(
                  _userData!.role.displayName,
                  style: AppStyles.labelMedium.copyWith(
                    color: _getRoleColor(_userData!.role),
                  ),
                ),
              ),
              const Gap(AppStyles.spacingXL),


              if (_userData!.role == UserRole.technician) ...[
                if (_userData!.specialties != null && _userData!.specialties!.isNotEmpty) ...[
                  const Gap(AppStyles.spacingMD),
                  _InfoCard(
                    icon: Icons.build_outlined,
                    title: 'التخصصات',
                    value: _userData!.specialties!.join(', '),
                  ),
                ],
                if (_userData!.bio != null && _userData!.bio!.isNotEmpty) ...[
                  const Gap(AppStyles.spacingMD),
                  Container(
                    padding: const EdgeInsets.all(AppStyles.spacingMD),
                    decoration: AppStyles.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نبذة',
                          style: AppStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          _userData!.bio!,
                          style: AppStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],

                if (_realRating != null && _realRating! > 0) ...[
                  const Gap(AppStyles.spacingMD),
                  _InfoCard(
                    icon: Icons.star_outline,
                    title: 'التقييم',
                    value: '${_realRating!.toStringAsFixed(1)} ⭐',
                  ),
                ],

                if (_realTotalOrders > 0 || _userData!.totalOrders != null) ...[
                  const Gap(AppStyles.spacingMD),
                  _InfoCard(
                    icon: Icons.assignment_outlined,
                    title: 'عدد الطلبات المكتملة',
                    value: '$_realTotalOrders',
                  ),
                ],
                const Gap(AppStyles.spacingXL),
              ],


              CustomButton(
                label: 'تعديل البيانات',
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    EditProfileScreen.routeName,
                  );
                  if (result == true) {

                    _loadUserData();
                  }
                },
              ),
              const Gap(AppStyles.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
        boxShadow: AppTheme.softShadow,
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: _userData!.profileImage != null &&
                _userData!.profileImage!.isNotEmpty
            ? ImageHelper.base64ToImage(_userData!.profileImage!)
            : Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _userData!.name?.substring(0, 1).toUpperCase() ?? 'U',
                    style: AppStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return AppColors.customer;
      case UserRole.technician:
        return AppColors.technician;
      case UserRole.admin:
        return AppColors.admin;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingMD),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.spacingSM),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const Gap(AppStyles.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Gap(4),
                Text(
                  value,
                  style: AppStyles.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
