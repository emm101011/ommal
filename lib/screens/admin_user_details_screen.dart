import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/orders_service.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../utils/image_helper.dart';
import 'order_details_screen.dart';
import 'admin_reviews_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AdminUserDetailsScreen extends StatefulWidget {
  static const String routeName = '/admin-user-details';
  const AdminUserDetailsScreen({super.key});

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  UserModel? _user;
  bool _loading = true;
  bool _updating = false;
  double? _realRating;
  int _realTotalOrders = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final userId = ModalRoute.of(context)?.settings.arguments as String?;
    if (userId != null) {
      try {
        final user = await AuthService.getUserData(userId);
        if (mounted) {
          setState(() {
            _user = user;
            _loading = false;
          });


          if (user != null && user.role == UserRole.technician) {
            final realRating = await OrdersService.calculateTechnicianRating(userId);
            final realTotalOrders = await OrdersService.calculateTechnicianTotalOrders(userId);
            if (mounted) {
              setState(() {
                _realRating = realRating;
                _realTotalOrders = realTotalOrders;
              });
            }
          } else if (user != null && user.role == UserRole.customer) {
            final realTotalOrders = await OrdersService.calculateCustomerTotalOrders(userId);
            if (mounted) {
              setState(() {
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

  Future<void> _deleteReview(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرأي'),
        content: const Text('هل أنت متأكد من حذف هذا الرأي؟\nسيتم حذف النص المكتوب فقط، وسيبقى التقييم بالنجوم.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _updating = true);

    try {
      final success = await OrdersService.deleteReview(orderId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم حذف الرأي بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('فشل حذف الرأي'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  Future<void> _toggleBlock() async {
    if (_user == null) return;

    final action = _user!.isBlocked ? 'إلغاء الحظر' : 'حظر';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: Text(
          _user!.isBlocked
              ? 'هل أنت متأكد من إلغاء حظر هذا المستخدم؟'
              : 'هل أنت متأكد من حظر هذا المستخدم؟\nلن يتمكن من استخدام التطبيق.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: _user!.isBlocked ? AppColors.success : AppColors.error,
            ),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _updating = true);

    try {
      final success = await AuthService.toggleUserBlock(_user!.id, !_user!.isBlocked);

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل ${action} المستخدم'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم ${action} المستخدم بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );

      _loadUserData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updating = false);
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
            'تفاصيل المستخدم',
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'تفاصيل المستخدم',
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(
          child: Text('المستخدم غير موجود'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'تفاصيل المستخدم',
          style: AppStyles.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Container(
                padding: const EdgeInsets.all(AppStyles.spacingMD),
                decoration: AppTheme.glassCard(
                  borderRadius: AppStyles.radiusLarge,
                ),
                child: Column(
                  children: [
                    _buildProfileImage(),
                    const Gap(AppStyles.spacingMD),
                    Text(
                      _user!.name ?? 'غير محدد',
                      style: AppStyles.headlineSmall,
                    ),
                    const Gap(4),
                    Text(
                      _user!.email,
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_user!.role == UserRole.technician && _user!.specialties != null && _user!.specialties!.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        _user!.specialties!.join(', '),
                        style: AppStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (_user!.role == UserRole.technician) ...[
                      const Gap(AppStyles.spacingSM),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_realRating != null && _realRating! > 0) ...[
                            RatingBarIndicator(
                              rating: _realRating!,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              itemSize: 16,
                            ),
                            const Gap(4),
                            Text(
                              _realRating!.toStringAsFixed(1),
                              style: AppStyles.bodySmall,
                            ),
                          ] else ...[
                            Text(
                              'لا يوجد تقييم بعد',
                              style: AppStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const Gap(8),
                          Text(
                            '($_realTotalOrders طلب)',
                            style: AppStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                    if (_user!.isBlocked) ...[
                      const Gap(AppStyles.spacingMD),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppStyles.spacingMD,
                          vertical: AppStyles.spacingSM,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                          border: Border.all(
                            color: AppColors.error,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.block_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const Gap(AppStyles.spacingSM),
                            Text(
                              'حساب محظور',
                              style: AppStyles.labelMedium.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(AppStyles.spacingXL),


              Text(
                'معلومات المستخدم',
                style: AppStyles.titleLarge,
                textAlign: TextAlign.right,
              ),
              const Gap(AppStyles.spacingMD),


              _InfoCard(
                icon: Icons.person_outline_rounded,
                title: 'الدور',
                value: _user!.role.displayName,
              ),
              const Gap(AppStyles.spacingMD),


              if (_user!.phone != null) ...[
                _InfoCard(
                  icon: Icons.phone_outlined,
                  title: 'رقم الجوال',
                  value: _user!.phone!,
                ),
                const Gap(AppStyles.spacingMD),
              ],


              if (_user!.address != null) ...[
                _InfoCard(
                  icon: Icons.location_on_outlined,
                  title: 'العنوان',
                  value: _user!.address!,
                ),
                const Gap(AppStyles.spacingMD),
              ],


              _InfoCard(
                icon: _user!.isProfileComplete ? Icons.check_circle_outline : Icons.pending_outlined,
                title: 'حالة الحساب',
                value: _user!.isProfileComplete ? 'مكتمل' : 'غير مكتمل',
              ),
              const Gap(AppStyles.spacingMD),


              _InfoCard(
                icon: Icons.calendar_today_outlined,
                title: 'تاريخ التسجيل',
                value: _user!.createdAt.toString().substring(0, 16),
              ),
              if (_user!.updatedAt != null) ...[
                const Gap(AppStyles.spacingMD),
                _InfoCard(
                  icon: Icons.update_outlined,
                  title: 'آخر تحديث',
                  value: _user!.updatedAt!.toString().substring(0, 16),
                ),
              ],


              if (_user!.role == UserRole.technician) ...[
                const Gap(AppStyles.spacingXL),
                Text(
                  'معلومات الفني',
                  style: AppStyles.titleLarge,
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingMD),


                if (_user!.specialties != null && _user!.specialties!.isNotEmpty) ...[
                  Text(
                    'التخصصات',
                    style: AppStyles.labelLarge,
                    textAlign: TextAlign.right,
                  ),
                  const Gap(AppStyles.spacingSM),
                  Wrap(
                    spacing: AppStyles.spacingSM,
                    runSpacing: AppStyles.spacingSM,
                    children: _user!.specialties!.map((specialty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppStyles.spacingMD,
                          vertical: AppStyles.spacingSM,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.technician.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                          border: Border.all(
                            color: AppColors.technician,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          specialty,
                          style: AppStyles.labelSmall.copyWith(
                            color: AppColors.technician,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Gap(AppStyles.spacingMD),
                ],


                if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
                  Text(
                    'نبذة',
                    style: AppStyles.labelLarge,
                    textAlign: TextAlign.right,
                  ),
                  const Gap(AppStyles.spacingSM),
                  Container(
                    padding: const EdgeInsets.all(AppStyles.spacingMD),
                    decoration: AppStyles.cardDecoration,
                    child: Text(
                      _user!.bio!,
                      style: AppStyles.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const Gap(AppStyles.spacingMD),
                ],


                _InfoCard(
                  icon: _user!.isVerified == true ? Icons.verified_outlined : Icons.verified_user_outlined,
                  title: 'حالة التحقق',
                  value: _user!.isVerified == true ? 'موثق' : 'غير موثق',
                ),
              ],

              const Gap(AppStyles.spacingXL),


              ElevatedButton.icon(
                onPressed: _updating ? null : _toggleBlock,
                icon: Icon(_user!.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded),
                label: Text(_user!.isBlocked ? 'إلغاء الحظر' : 'حظر الحساب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _user!.isBlocked ? AppColors.success : AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppStyles.spacingMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  ),
                  elevation: 6,
                  shadowColor: (_user!.isBlocked ? AppColors.success : AppColors.error)
                      .withOpacity(0.3),
                ),
              ),
              const Gap(AppStyles.spacingXL),


              if (_user!.role == UserRole.technician) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقييمات والآراء',
                      style: AppStyles.titleLarge,
                      textAlign: TextAlign.right,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AdminReviewsScreen.routeName,
                          arguments: _user!.id,
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      label: const Text('عرض جميع الآراء'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Gap(AppStyles.spacingMD),
                StreamBuilder<QuerySnapshot>(
                  stream: OrdersService.getTechnicianOrders(_user!.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppStyles.spacingMD),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ: ${snapshot.error}',
                          style: AppStyles.bodyMedium,
                        ),
                      );
                    }

                    final allOrders = snapshot.data?.docs
                            .map((doc) => OrderModel.fromFirestore(doc))
                            .toList() ??
                        [];

                    final reviews = allOrders
                        .where((order) =>
                            order.status == OrderStatus.completed &&
                            order.rating != null &&
                            order.review != null &&
                            order.review!.isNotEmpty)
                        .toList();

                    if (reviews.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(AppStyles.spacingMD),
                        decoration: AppStyles.cardDecoration,
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const Gap(AppStyles.spacingSM),
                            Text(
                              'لا توجد آراء مكتوبة بعد',
                              style: AppStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ...reviews.take(3).map((order) => _AdminReviewCard(
                              order: order,
                              onDelete: () => _deleteReview(order.id),
                            )),
                        if (reviews.length > 3) ...[
                          const Gap(AppStyles.spacingSM),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AdminReviewsScreen.routeName,
                                arguments: _user!.id,
                              );
                            },
                            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                            label: Text('عرض جميع الآراء (${reviews.length})'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const Gap(AppStyles.spacingXL),
              ],


              Text(
                'الطلبات',
                style: AppStyles.titleLarge,
                textAlign: TextAlign.right,
              ),
              const Gap(AppStyles.spacingMD),
              StreamBuilder<QuerySnapshot>(
                stream: _user!.role == UserRole.technician
                    ? OrdersService.getTechnicianOrders(_user!.id)
                    : OrdersService.getUserOrders(_user!.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppStyles.spacingXL),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'حدث خطأ: ${snapshot.error}',
                        style: AppStyles.bodyMedium,
                      ),
                    );
                  }

                  final allOrders = snapshot.data?.docs
                          .map((doc) => OrderModel.fromFirestore(doc))
                          .toList() ??
                      [];


                  final orders = allOrders;

                  if (orders.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppStyles.spacingXL),
                        child: Column(
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
                      ),
                    );
                  }


                  final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).toList();
                  final inProgressOrders =
                      orders.where((o) => o.status == OrderStatus.inProgress).toList();
                  final completedOrders =
                      orders.where((o) => o.status == OrderStatus.completed).toList();
                  final cancelledOrders =
                      orders.where((o) => o.status == OrderStatus.cancelled).toList();
                  final deletedOrders = orders.where((o) => o.isDeleted).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Container(
                        padding: const EdgeInsets.all(AppStyles.spacingMD),
                        decoration: AppTheme.glassCard(
                          borderRadius: AppStyles.radiusLarge,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _OrderCountItem(
                              label: 'إجمالي',
                              count: orders.length,
                              color: AppColors.primary,
                            ),
                            _OrderCountItem(
                              label: 'قيد الانتظار',
                              count: pendingOrders.length,
                              color: AppColors.statusPending,
                            ),
                            _OrderCountItem(
                              label: 'قيد التنفيذ',
                              count: inProgressOrders.length,
                              color: AppColors.statusInProgress,
                            ),
                            _OrderCountItem(
                              label: 'مكتملة',
                              count: completedOrders.length,
                              color: AppColors.statusCompleted,
                            ),
                          ],
                        ),
                      ),
                      const Gap(AppStyles.spacingXL),


                      if (deletedOrders.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'محذوفة',
                          count: deletedOrders.length,
                          color: AppColors.error,
                        ),
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
                        _SectionHeader(
                          title: 'قيد الانتظار',
                          count: pendingOrders.length,
                          color: AppColors.statusPending,
                        ),
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
                        _SectionHeader(
                          title: 'قيد التنفيذ',
                          count: inProgressOrders.length,
                          color: AppColors.statusInProgress,
                        ),
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
                        _SectionHeader(
                          title: 'مكتملة',
                          count: completedOrders.length,
                          color: AppColors.statusCompleted,
                        ),
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
                        _SectionHeader(
                          title: 'ملغاة',
                          count: cancelledOrders.length,
                          color: AppColors.statusCancelled,
                        ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_user!.profileImage != null && _user!.profileImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        child: SizedBox(
          width: 80,
          height: 80,
          child: ImageHelper.base64ToImage(_user!.profileImage!),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _user!.isBlocked
            ? AppColors.error.withOpacity(0.1)
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
      ),
      child: Center(
        child: Text(
          _user!.name?.substring(0, 1).toUpperCase() ?? 'U',
          style: AppStyles.headlineMedium.copyWith(
            color: _user!.isBlocked ? AppColors.error : AppColors.primary,
          ),
        ),
      ),
    );
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
                  style: AppStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Gap(4),
                Text(
                  value,
                  style: AppStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminReviewCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onDelete;

  const _AdminReviewCard({
    required this.order,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacingMD),
      padding: const EdgeInsets.all(AppStyles.spacingMD),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                              i < (order.rating?.round() ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            )),
                        const Gap(8),
                        if (order.rating != null)
                          Text(
                            order.rating!.toStringAsFixed(1),
                            style: AppStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    if (order.review != null && order.review!.isNotEmpty) ...[
                      const Gap(AppStyles.spacingSM),
                      Text(
                        order.review!,
                        style: AppStyles.bodyMedium,
                      ),
                    ],
                    const Gap(4),
                    Text(
                      order.createdAt.toString().substring(0, 10),
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                onPressed: onDelete,
                tooltip: 'حذف الرأي',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderCountItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _OrderCountItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: AppStyles.headlineMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: AppStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
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

