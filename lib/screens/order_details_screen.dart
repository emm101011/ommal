import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_strings.dart';
import '../models/order_model.dart';
import '../services/orders_service.dart';
import '../services/technicians_service.dart';
import '../models/user_model.dart';
import '../widgets/custom_button.dart';
import 'rating_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  static const String routeName = '/order-details';
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  OrderModel? _order;
  UserModel? _technician;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderData();
    });
  }

  Future<void> _loadOrderData() async {
    final orderId = ModalRoute.of(context)?.settings.arguments as String?;
    if (orderId == null) {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);
      }
      return;
    }

    try {
      final doc = await OrdersService.getOrderById(orderId);
      if (doc != null && doc.exists) {
        final order = OrderModel.fromFirestore(doc);

        if (mounted) {
          setState(() => _order = order);


          if (order.technicianId != null) {
            final tech = await TechniciansService.getTechnicianById(order.technicianId!);
            if (mounted) {
              setState(() => _technician = tech);
            }
          }

          setState(() => _loading = false);
        }
      } else {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'تفاصيل الطلب',
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'تفاصيل الطلب',
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(child: Text('الطلب غير موجود')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'تفاصيل الطلب',
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
                decoration: BoxDecoration(
                  color: _getStatusColor(_order!.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                  border: Border.all(
                    color: _getStatusColor(_order!.status),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _order!.status == OrderStatus.completed
                          ? Icons.check_circle
                          : _order!.status == OrderStatus.cancelled
                              ? Icons.cancel
                              : Icons.access_time,
                      color: _getStatusColor(_order!.status),
                      size: 24,
                    ),
                    const Gap(AppStyles.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حالة الطلب',
                            style: AppStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            _order!.status.displayName,
                            style: AppStyles.titleMedium.copyWith(
                              color: _getStatusColor(_order!.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppStyles.spacingXL),


              if (_order!.status == OrderStatus.cancelled) ...[
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingMD),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.spacingSM),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: AppColors.error,
                          size: 24,
                        ),
                      ),
                      const Gap(AppStyles.spacingMD),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _order!.cancelledBy == 'customer'
                                  ? 'لقد قمت بإلغاء هذا الطلب'
                                  : _order!.cancelledBy == 'technician'
                                      ? 'الفني رفض الطلب'
                                      : 'تم إلغاء الطلب',
                              style: AppStyles.titleMedium.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              _order!.cancelledBy == 'customer'
                                  ? 'تم إلغاء هذا الطلب من قبلك'
                                  : _order!.cancelledBy == 'technician'
                                      ? 'تم رفض هذا الطلب من قبل الفني المختار'
                                      : 'تم إلغاء هذا الطلب',
                              style: AppStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppStyles.spacingXL),
              ],


              Text(
                'معلومات الطلب',
                style: AppStyles.titleLarge,
                textAlign: TextAlign.right,
              ),
              const Gap(AppStyles.spacingMD),

              _InfoCard(
                icon: Icons.build_outlined,
                title: 'نوع الخدمة',
                value: _order!.serviceType,
              ),
              const Gap(AppStyles.spacingMD),

              _InfoCard(
                icon: Icons.location_on_outlined,
                title: 'العنوان',
                value: _order!.address,
              ),
              const Gap(AppStyles.spacingMD),

              _InfoCard(
                icon: Icons.description_outlined,
                title: 'الوصف',
                value: _order!.description,
              ),
              const Gap(AppStyles.spacingMD),

              _InfoCard(
                icon: Icons.calendar_today_outlined,
                title: 'تاريخ الإنشاء',
                value: _order!.createdAt.toString().substring(0, 16),
              ),
              const Gap(AppStyles.spacingXL),


              if (_technician != null) ...[
                Text(
                  _order!.status == OrderStatus.cancelled
                      ? 'الفني الذي رفض الطلب'
                      : 'معلومات الفني',
                  style: AppStyles.titleLarge,
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingMD),
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingMD),
                  decoration: AppStyles.cardDecoration,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.technician.withOpacity(0.1),
                        child: Text(
                          _technician!.name?.substring(0, 1).toUpperCase() ?? 'T',
                          style: AppStyles.bodyLarge.copyWith(
                            color: AppColors.technician,
                          ),
                        ),
                      ),
                      const Gap(AppStyles.spacingMD),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _technician!.name ?? 'فني',
                              style: AppStyles.titleMedium,
                            ),
                            if (_technician!.phone != null) ...[
                              const Gap(4),
                              Text(
                                _technician!.phone!,
                                style: AppStyles.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppStyles.spacingXL),
              ],


              if (_order!.status == OrderStatus.completed &&
                  _order!.rating == null &&
                  _technician != null) ...[
                CustomButton(
                  label: 'تقييم الفني',
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      RatingScreen.routeName,
                      arguments: {
                        'orderId': _order!.id,
                        'technicianId': _technician!.id,
                      },
                    );
                    if (result == true) {
                      _loadOrderData();
                    }
                  },
                ),
                const Gap(AppStyles.spacingXL),
              ],


              if (_order!.rating != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingMD),
                  decoration: AppStyles.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تقييمك',
                        style: AppStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                                i < _order!.rating!.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              )),
                          const Gap(8),
                          Text(
                            _order!.rating!.toStringAsFixed(1),
                            style: AppStyles.titleMedium,
                          ),
                        ],
                      ),
                      if (_order!.review != null && _order!.review!.isNotEmpty) ...[
                        const Gap(8),
                        Text(
                          _order!.review!,
                          style: AppStyles.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(AppStyles.spacingXL),
              ],


              if (_order!.status != OrderStatus.cancelled &&
                  _order!.status != OrderStatus.completed) ...[
                OutlinedButton.icon(
                  onPressed: () => _cancelOrder(context),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('إلغاء الطلب'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusCancelled,
                    side: const BorderSide(color: AppColors.statusCancelled),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppStyles.spacingMD,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                    ),
                  ),
                ),
                const Gap(AppStyles.spacingMD),
              ],


              OutlinedButton.icon(
                onPressed: () => _deleteOrder(context),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('حذف الطلب'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppStyles.spacingMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  ),
                ),
              ),
              const Gap(AppStyles.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context) async {
    if (_order == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟\nسيتم إعلام الفني بإلغاء الطلب.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.statusCancelled,
            ),
            child: const Text('إلغاء الطلب'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await OrdersService.cancelOrderByCustomer(_order!.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم إلغاء الطلب بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
              ),
            ),
          );
          _loadOrderData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('فشل إلغاء الطلب'),
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

  Future<void> _deleteOrder(BuildContext context) async {
    if (_order == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الطلب'),
        content: const Text('هل أنت متأكد من حذف هذا الطلب؟\nسيتم إخفاؤه من قائمة طلباتك.'),
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
      final success = await OrdersService.deleteOrder(_order!.id);

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل حذف الطلب'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حذف الطلب بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );


      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${AppStrings.cleanErrorMessage(e)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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

