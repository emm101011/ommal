import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/orders_service.dart';
import '../services/notifications_service.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import 'profile_screen.dart';
import 'order_details_screen.dart';
import 'admin_user_details_screen.dart';
import 'technician_home_screen.dart';
import 'notifications_screen.dart';
import 'home_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  static const String routeName = '/admin-home';
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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

        if (userData.role == UserRole.technician) {
          Navigator.of(context).pushReplacementNamed(TechnicianHomeScreen.routeName);
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
      const _DashboardTab(),
      const _OrdersTab(),
      const _TechniciansTab(),
      const _CustomersTab(),
      const ProfileScreen(),
    ];

    final labels = ['لوحة التحكم', 'الطلبات', 'الفنيون', 'العملاء', 'حسابي'];
    final icons = [
      Icons.dashboard_rounded,
      Icons.assignment_rounded,
      Icons.build_rounded,
      Icons.people_rounded,
      Icons.person_rounded,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
              labels[_index],
              style: AppStyles.headlineSmall,
            ),
            if (_userName != null)
              Text(
                'مرحباً $_userName',
                style: AppStyles.bodySmall,
              ),
          ],
        ),
      ),
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
              children: List.generate(
                pages.length,
                (i) => _NavItem(
                  icon: icons[i],
                  label: labels[i],
                  selected: _index == i,
                  onTap: () => setState(() => _index = i),
                ),
              ),
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
    final color = selected ? AppColors.admin : AppColors.textSecondary;
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


class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: OrdersService.getAllOrders(),
      builder: (context, ordersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'technician')
              .snapshots(),
          builder: (context, techniciansSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'customer')
                  .snapshots(),
              builder: (context, customersSnapshot) {
                final totalOrders = ordersSnapshot.data?.docs.length ?? 0;
                final pendingOrders = ordersSnapshot.data?.docs
                        .where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['status'] == 'pending';
                        })
                        .length ??
                    0;
                final completedOrders = ordersSnapshot.data?.docs
                        .where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['status'] == 'completed';
                        })
                        .length ??
                    0;
                final totalTechnicians = techniciansSnapshot.data?.docs.length ?? 0;
                final totalCustomers = customersSnapshot.data?.docs.length ?? 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppStyles.spacingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'لوحة التحكم',
                        style: AppStyles.headlineMedium,
                        textAlign: TextAlign.right,
                      ),
                      const Gap(AppStyles.spacingXL),


                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'إجمالي الطلبات',
                              value: totalOrders.toString(),
                              icon: Icons.assignment_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const Gap(AppStyles.spacingMD),
                          Expanded(
                            child: _StatCard(
                              title: 'قيد الانتظار',
                              value: pendingOrders.toString(),
                              icon: Icons.access_time_rounded,
                              color: AppColors.statusPending,
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppStyles.spacingMD),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'مكتملة',
                              value: completedOrders.toString(),
                              icon: Icons.check_circle_rounded,
                              color: AppColors.statusCompleted,
                            ),
                          ),
                          const Gap(AppStyles.spacingMD),
                          Expanded(
                            child: _StatCard(
                              title: 'الفنيون',
                              value: totalTechnicians.toString(),
                              icon: Icons.build_rounded,
                              color: AppColors.technician,
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppStyles.spacingMD),
                      _StatCard(
                        title: 'العملاء',
                        value: totalCustomers.toString(),
                        icon: Icons.people_rounded,
                        color: AppColors.customer,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingMD),
      decoration: AppTheme.glassCard(
        borderRadius: AppStyles.radiusLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const Gap(AppStyles.spacingSM),
          Text(
            value,
            style: AppStyles.headlineLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
          Text(
            title,
            style: AppStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: OrdersService.getAllOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'حدث خطأ: ${snapshot.error}',
              style: AppStyles.bodyMedium,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const Gap(AppStyles.spacingMD),
                Text(
                  'لا توجد طلبات',
                  style: AppStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data!.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList();


        final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).toList();
        final inProgressOrders = orders.where((o) => o.status == OrderStatus.inProgress).toList();
        final completedOrders = orders.where((o) => o.status == OrderStatus.completed).toList();
        final cancelledOrders = orders.where((o) => o.status == OrderStatus.cancelled).toList();
        final deletedOrders = orders.where((o) => o.isDeleted).toList();

        return ListView(
          padding: const EdgeInsets.all(AppStyles.spacingMD),
          children: [
            if (deletedOrders.isNotEmpty) ...[
              _SectionHeader(title: 'محذوفة', count: deletedOrders.length, color: AppColors.error),
              const Gap(AppStyles.spacingSM),
              ...deletedOrders.map((order) => _OrderCard(
                    order: order,
                    isDeleted: true,
                    onTap: () => Navigator.pushNamed(
                      context,
                      OrderDetailsScreen.routeName,
                      arguments: order.id,
                    ),
                  )),
              const Gap(AppStyles.spacingLG),
            ],
            if (pendingOrders.isNotEmpty) ...[
              _SectionHeader(title: 'قيد الانتظار', count: pendingOrders.length, color: AppColors.statusPending),
              const Gap(AppStyles.spacingSM),
              ...pendingOrders.map((order) => _OrderCard(
                    order: order,
                    onTap: () => Navigator.pushNamed(
                      context,
                      OrderDetailsScreen.routeName,
                      arguments: order.id,
                    ),
                  )),
              const Gap(AppStyles.spacingLG),
            ],
            if (inProgressOrders.isNotEmpty) ...[
              _SectionHeader(title: 'قيد التنفيذ', count: inProgressOrders.length, color: AppColors.statusInProgress),
              const Gap(AppStyles.spacingSM),
              ...inProgressOrders.map((order) => _OrderCard(
                    order: order,
                    onTap: () => Navigator.pushNamed(
                      context,
                      OrderDetailsScreen.routeName,
                      arguments: order.id,
                    ),
                  )),
              const Gap(AppStyles.spacingLG),
            ],
            if (completedOrders.isNotEmpty) ...[
              _SectionHeader(title: 'مكتملة', count: completedOrders.length, color: AppColors.statusCompleted),
              const Gap(AppStyles.spacingSM),
              ...completedOrders.map((order) => _OrderCard(
                    order: order,
                    onTap: () => Navigator.pushNamed(
                      context,
                      OrderDetailsScreen.routeName,
                      arguments: order.id,
                    ),
                  )),
              const Gap(AppStyles.spacingLG),
            ],
            if (cancelledOrders.isNotEmpty) ...[
              _SectionHeader(title: 'ملغاة', count: cancelledOrders.length, color: AppColors.statusCancelled),
              const Gap(AppStyles.spacingSM),
              ...cancelledOrders.map((order) => _OrderCard(
                    order: order,
                    onTap: () => Navigator.pushNamed(
                      context,
                      OrderDetailsScreen.routeName,
                      arguments: order.id,
                    ),
                  )),
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppStyles.titleLarge,
        ),
        const Gap(AppStyles.spacingSM),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.spacingSM,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppStyles.radiusFull),
          ),
          child: Text(
            '$count',
            style: AppStyles.labelSmall.copyWith(
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final bool isDeleted;

  const _OrderCard({
    required this.order,
    required this.onTap,
    this.isDeleted = false,
  });

  Color get _statusColor {
    if (isDeleted) return AppColors.error;
    switch (order.status) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.inProgress:
        return AppColors.statusInProgress;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  IconData get _statusIcon {
    if (isDeleted) return Icons.delete_outline;
    switch (order.status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.inProgress:
        return Icons.build;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyles.spacingMD),
        padding: const EdgeInsets.all(AppStyles.spacingMD),
        decoration: AppStyles.cardDecoration.copyWith(
          color: isDeleted ? AppColors.error.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppStyles.spacingSM),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
              ),
              child: Icon(
                _statusIcon,
                color: _statusColor,
                size: 24,
              ),
            ),
            const Gap(AppStyles.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'طلب #${order.id.substring(0, 8)}',
                          style: AppStyles.titleMedium,
                        ),
                      ),
                      if (isDeleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                          ),
                          child: Text(
                            'محذوف',
                            style: AppStyles.labelSmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Gap(4),
                  Text(
                    order.serviceType,
                    style: AppStyles.bodySmall,
                  ),
                  const Gap(4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                    ),
                    child: Text(
                      isDeleted ? 'محذوف' : order.status.displayName,
                      style: AppStyles.labelSmall.copyWith(
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}


class _TechniciansTab extends StatefulWidget {
  const _TechniciansTab();

  @override
  State<_TechniciansTab> createState() => _TechniciansTabState();
}

class _TechniciansTabState extends State<_TechniciansTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(AppStyles.spacingMD),
          child: TextField(
            controller: _searchController,
            decoration: AppStyles.inputDecoration('ابحث عن فني...').copyWith(
              prefixIcon: const Icon(Icons.search_rounded),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'technician')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'حدث خطأ: ${snapshot.error}',
                    style: AppStyles.bodyMedium,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build_outlined,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const Gap(AppStyles.spacingMD),
                      Text(
                        'لا يوجد فنيون',
                        style: AppStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final allTechnicians = snapshot.data!.docs
                  .map((doc) => UserModel.fromFirestore(doc.data() as Map<String, dynamic>))
                  .toList();


              final searchQuery = _searchController.text.toLowerCase();
              final technicians = searchQuery.isEmpty
                  ? allTechnicians
                  : allTechnicians.where((tech) {
                      final name = tech.name?.toLowerCase() ?? '';
                      final email = tech.email.toLowerCase();
                      return name.contains(searchQuery) || email.contains(searchQuery);
                    }).toList();

              if (technicians.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const Gap(AppStyles.spacingMD),
                      Text(
                        'لا توجد نتائج',
                        style: AppStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingMD),
                children: technicians.map((tech) => _UserCard(
                      user: tech,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AdminUserDetailsScreen.routeName,
                        arguments: tech.id,
                      ),
                    )).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}


class _CustomersTab extends StatefulWidget {
  const _CustomersTab();

  @override
  State<_CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<_CustomersTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(AppStyles.spacingMD),
          child: TextField(
            controller: _searchController,
            decoration: AppStyles.inputDecoration('ابحث عن عميل...').copyWith(
              prefixIcon: const Icon(Icons.search_rounded),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'customer')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'حدث خطأ: ${snapshot.error}',
                    style: AppStyles.bodyMedium,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outlined,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const Gap(AppStyles.spacingMD),
                      Text(
                        'لا يوجد عملاء',
                        style: AppStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final allCustomers = snapshot.data!.docs
                  .map((doc) => UserModel.fromFirestore(doc.data() as Map<String, dynamic>))
                  .toList();


              final searchQuery = _searchController.text.toLowerCase();
              final customers = searchQuery.isEmpty
                  ? allCustomers
                  : allCustomers.where((customer) {
                      final name = customer.name?.toLowerCase() ?? '';
                      final email = customer.email.toLowerCase();
                      return name.contains(searchQuery) || email.contains(searchQuery);
                    }).toList();

              if (customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const Gap(AppStyles.spacingMD),
                      Text(
                        'لا توجد نتائج',
                        style: AppStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingMD),
                children: customers.map((customer) => _UserCard(
                      user: customer,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AdminUserDetailsScreen.routeName,
                        arguments: customer.id,
                      ),
                    )).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacingMD),
      decoration: AppStyles.cardDecoration.copyWith(
        color: user.isBlocked ? AppColors.error.withOpacity(0.05) : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spacingMD),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: user.isBlocked
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.primaryLight,
                child: Text(
                  user.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: AppStyles.bodyLarge.copyWith(
                    color: user.isBlocked ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
              const Gap(AppStyles.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name ?? 'غير محدد',
                            style: AppStyles.titleMedium,
                          ),
                        ),
                        if (user.isBlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                            ),
                            child: Text(
                              'محظور',
                              style: AppStyles.labelSmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      user.email,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (user.phone != null) ...[
                      const Gap(4),
                      Text(
                        user.phone!,
                        style: AppStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

