import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../services/orders_service.dart';
import '../services/auth_service.dart';
import '../utils/image_helper.dart';

class AdminReviewsScreen extends StatefulWidget {
  static const String routeName = '/admin-reviews';
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  String? _selectedTechnicianId;
  List<OrderModel> _allReviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _selectedTechnicianId = args;
      }
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    setState(() => _loading = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'completed')
          .where('rating', isNotEqualTo: null)
          .orderBy('rating', descending: false)
          .orderBy('createdAt', descending: true)
          .limit(500);


      if (_selectedTechnicianId != null && _selectedTechnicianId!.isNotEmpty) {
        query = query.where('technicianId', isEqualTo: _selectedTechnicianId);
      }

      final snapshot = await query.get();

      if (mounted) {
        setState(() {
          _allReviews = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .where((order) =>
                  order.review != null && order.review!.isNotEmpty)
              .toList();
          _loading = false;
        });
      }
    } catch (e) {

      try {
        Query query = FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'completed')
            .orderBy('createdAt', descending: true)
            .limit(500);

        if (_selectedTechnicianId != null && _selectedTechnicianId!.isNotEmpty) {
          query = query.where('technicianId', isEqualTo: _selectedTechnicianId);
        }

        final snapshot = await query.get();

        if (mounted) {
          setState(() {
            _allReviews = snapshot.docs
                .map((doc) => OrderModel.fromFirestore(doc))
                .where((order) =>
                    order.rating != null &&
                    order.review != null &&
                    order.review!.isNotEmpty)
                .toList();
            _loading = false;
          });
        }
      } catch (e2) {
        if (mounted) {
          setState(() => _loading = false);
        }
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
          _loadReviews();
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
    }
  }

  Future<void> _blockUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حظر المستخدم'),
        content: const Text('هل أنت متأكد من حظر هذا المستخدم؟\nلن يتمكن من استخدام التطبيق.'),
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
            child: const Text('حظر'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AuthService.toggleUserBlock(userId, true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم حظر المستخدم بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            ),
          ),
        );
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'جميع الآراء',
          style: AppStyles.headlineSmall,
        ),
        actions: [

          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showTechnicianFilter(),
            tooltip: 'فلترة حسب الفني',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _allReviews.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppStyles.spacingXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppStyles.spacingXL),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.reviews_outlined,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Gap(AppStyles.spacingXL),
                        Text(
                          'لا توجد آراء مكتوبة',
                          style: AppStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(AppStyles.spacingSM),
                        Text(
                          'لم يقم أي عميل بكتابة رأي بعد',
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [

                    Container(
                      margin: const EdgeInsets.all(AppStyles.spacingMD),
                      padding: const EdgeInsets.all(AppStyles.spacingMD),
                      decoration: AppStyles.cardDecoration,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${_allReviews.length}',
                                style: AppStyles.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'إجمالي الآراء',
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (_selectedTechnicianId != null) ...[
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.border,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _selectedTechnicianId = null);
                                _loadReviews();
                              },
                              child: const Text('إلغاء الفلترة'),
                            ),
                          ],
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppStyles.spacingMD),
                        itemCount: _allReviews.length,
                        itemBuilder: (context, index) {
                          return _ReviewCard(
                            order: _allReviews[index],
                            onDelete: () => _deleteReview(_allReviews[index].id),
                            onBlockUser: () => _blockUser(_allReviews[index].userId),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _showTechnicianFilter() async {

    final techniciansSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'technician')
        .get();

    final technicians = techniciansSnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data()))
        .toList();

    if (technicians.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يوجد فنيين'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر الفني'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: technicians.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('الكل'),
                  leading: const Icon(Icons.all_inclusive),
                  onTap: () => Navigator.pop(context, null),
                );
              }
              final tech = technicians[index - 1];
              return ListTile(
                title: Text(tech.name ?? 'فني'),
                subtitle: Text(tech.email),
                onTap: () => Navigator.pop(context, tech.id),
              );
            },
          ),
        ),
      ),
    );

    if (selected != _selectedTechnicianId) {
      setState(() => _selectedTechnicianId = selected);
      _loadReviews();
    }
  }
}

class _ReviewCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onDelete;
  final VoidCallback onBlockUser;

  const _ReviewCard({
    required this.order,
    required this.onDelete,
    required this.onBlockUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacingMD),
      padding: const EdgeInsets.all(AppStyles.spacingMD),
      decoration: AppStyles.cardDecoration,
      child: FutureBuilder<UserModel?>(
        future: AuthService.getUserData(order.userId),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.customer.withOpacity(0.1),
                    child: user?.profileImage != null && user!.profileImage!.isNotEmpty
                        ? ClipOval(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: ImageHelper.base64ToImage(user.profileImage!),
                            ),
                          )
                        : Text(
                            user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                            style: AppStyles.bodyMedium.copyWith(
                              color: AppColors.customer,
                            ),
                          ),
                  ),
                  const Gap(AppStyles.spacingSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'مستخدم',
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user?.email ?? order.userId.substring(0, 8),
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(AppStyles.spacingMD),
              const Divider(),
              const Gap(AppStyles.spacingMD),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Gap(AppStyles.spacingSM),

                        if (order.review != null && order.review!.isNotEmpty)
                          Text(
                            order.review!,
                            style: AppStyles.bodyMedium,
                          ),
                        const Gap(AppStyles.spacingSM),

                        Text(
                          order.createdAt.toString().substring(0, 10),
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.error,
                        onPressed: onDelete,
                        tooltip: 'حذف الرأي',
                      ),
                      IconButton(
                        icon: const Icon(Icons.block),
                        color: AppColors.error,
                        onPressed: onBlockUser,
                        tooltip: 'حظر كاتب الرأي',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

