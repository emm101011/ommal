import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../services/auth_service.dart';
import '../services/notifications_service.dart';
import '../models/user_model.dart';
import 'technician_orders_screen.dart';
import 'profile_screen.dart';
import 'admin_home_screen.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';

class TechnicianHomeScreen extends StatefulWidget {
  static const String routeName = '/technician-home';
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
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
        } else if (userData.role == UserRole.customer) {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          return;
        }
        setState(() => _userName = userData.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TechnicianOrdersScreen(),
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
                    'طلباتي',
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
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.assignment_rounded,
                  label: 'طلباتي',
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'حسابي',
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
              ],
            ),
          ),
        ),
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
    final color = selected ? AppColors.technician : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
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
    );
  }
}

