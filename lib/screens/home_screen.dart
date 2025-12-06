import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/service_card.dart';
import '../theme/app_strings.dart';
import '../services/auth_service.dart';
import '../services/notifications_service.dart';
import '../models/user_model.dart';
import 'my_orders_screen.dart';
import 'profile_screen.dart';
import 'technicians_list_screen.dart';
import 'admin_home_screen.dart';
import 'technician_home_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = AuthService.currentUser;
    if (user != null) {
      final userData = await AuthService.getUserData(user.uid);
      if (mounted && userData != null) {

        if (userData.role == UserRole.admin) {
          Navigator.of(context).pushReplacementNamed(AdminHomeScreen.routeName);
          return;
        } else if (userData.role == UserRole.technician) {
          Navigator.of(context).pushReplacementNamed(TechnicianHomeScreen.routeName);
          return;
        }
        setState(() => _userName = userData.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(
        userName: _userName,
        onServiceTap: (title) {
          Navigator.pushNamed(
            context,
            TechniciansListScreen.routeName,
            arguments: title,
          );
        },
      ),
      const MyOrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _index == 0
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                StreamBuilder<int>(
                  stream: AuthService.currentUser != null
                      ? NotificationsService.getUnreadCount(AuthService.currentUser!.uid)
                      : Stream.value(0),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data ?? 0;
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            Navigator.pushNamed(context, NotificationsScreen.routeName);
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: AppStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.homeTitle,
                    style: AppStyles.headlineSmall,
                  ),
                  if (_userName != null)
                    Text(
                      'مرحباً $_userName',
                      style: AppStyles.bodySmall,
                    ),
                ],
              ),
            )
          : null,
      body: pages[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppTheme.mediumShadow,
          border: Border(
            top: BorderSide(
              color: Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingMD),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_filled,
                  label: 'الرئيسية',
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.assignment_rounded,
                  label: 'طلباتي',
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'حسابي',
                  selected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String? userName;
  final void Function(String title) onServiceTap;

  const _HomeTab({
    this.userName,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'icon': Icons.plumbing,
        'title': 'سباكة',
        'color': AppColors.plumbing,
      },
      {
        'icon': Icons.electrical_services,
        'title': 'كهرباء',
        'color': AppColors.electrical,
      },
      {
        'icon': Icons.ac_unit,
        'title': 'تكييف',
        'color': AppColors.ac,
      },
      {
        'icon': Icons.cleaning_services,
        'title': 'تنظيف',
        'color': AppColors.cleaning,
      },
      {
        'icon': Icons.home_repair_service,
        'title': 'نجارة',
        'color': AppColors.carpentry,
      },
      {
        'icon': Icons.pest_control,
        'title': 'مكافحة حشرات',
        'color': AppColors.pestControl,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppStyles.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر نوع الخدمة',
            style: AppStyles.headlineLarge,
            textAlign: TextAlign.right,
          ),
          const Gap(AppStyles.spacingMD),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppStyles.spacingMD,
                crossAxisSpacing: AppStyles.spacingMD,
                childAspectRatio: 1.1,
              ),
              itemCount: services.length,
              itemBuilder: (_, i) {
                final s = services[i];
                return ServiceCard(
                      key: ValueKey('service_${s['title']}'),
                      icon: s['icon'] as IconData,
                      title: s['title'] as String,
                      color: s['color'] as Color,
                      onTap: () => onServiceTap(s['title'] as String),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textTertiary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.spacingMD,
          vertical: AppStyles.spacingSM,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: selected ? 26 : 24,
            ),
            const Gap(4),
            Text(
              label,
              style: AppStyles.labelSmall.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
