import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_strings.dart';
import '../models/order_model.dart';
import '../services/orders_service.dart';
import '../services/auth_service.dart';
import '../services/notifications_service.dart';
import '../models/user_model.dart';
import '../widgets/custom_button.dart';

class TechnicianOrderDetailsScreen extends StatefulWidget {
  static const String routeName = '/technician-order-details';
  const TechnicianOrderDetailsScreen({super.key});

  @override
  State<TechnicianOrderDetailsScreen> createState() => _TechnicianOrderDetailsScreenState();
}

class _TechnicianOrderDetailsScreenState extends State<TechnicianOrderDetailsScreen> {
  OrderModel? _order;
  UserModel? _customer;
  bool _loading = true;
  bool _updating = false;

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


          if (order.userId.isNotEmpty) {
            final customer = await AuthService.getUserData(order.userId);
            if (mounted) {
              setState(() => _customer = customer);
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

  Future<void> _acceptOrder() async {
    if (_order == null) return;

    setState(() => _updating = true);

    try {
      final success = await OrdersService.updateOrderStatus(
        _order!.id,
        OrderStatus.inProgress.firestoreValue,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل قبول الطلب'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }


      if (_order!.userId.isNotEmpty && _customer != null) {
        final technician = await AuthService.getUserData(AuthService.currentUser!.uid);
        final technicianName = technician?.name ?? 'فني';
        final customerName = _customer!.name ?? 'عميل';


        await NotificationsService.notifyOrderAccepted(
          customerId: _order!.userId,
          orderId: _order!.id,
          technicianName: technicianName,
        );


        await NotificationsService.notifyAdminsOrderAccepted(
          technicianName: technicianName,
          customerName: customerName,
          orderId: _order!.id,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم قبول الطلب بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );

      _loadOrderData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${AppStrings.cleanErrorMessage(e)}'),
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

  Future<void> _rejectOrder() async {
    if (_order == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: const Text('هل أنت متأكد من رفض هذا الطلب؟'),
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
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _updating = true);

    try {
        final success = await OrdersService.updateOrderStatus(
          _order!.id,
          OrderStatus.cancelled.firestoreValue,
          cancelledBy: 'technician',
        );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل رفض الطلب'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }


      if (_order!.userId.isNotEmpty) {
        final technician = await AuthService.getUserData(AuthService.currentUser!.uid);
        final technicianName = technician?.name ?? 'فني';
        final customer = _customer ?? await AuthService.getUserData(_order!.userId);
        final customerName = customer?.name ?? 'عميل';


        await NotificationsService.notifyOrderRejected(
          customerId: _order!.userId,
          orderId: _order!.id,
          technicianName: technicianName,
        );


        await NotificationsService.notifyAdminsOrderRejected(
          technicianName: technicianName,
          customerName: customerName,
          orderId: _order!.id,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم رفض الطلب'),
          backgroundColor: AppColors.warning,
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
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  Future<void> _completeOrder() async {
    if (_order == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إكمال الطلب'),
        content: const Text('هل أنت متأكد من إكمال هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.success,
            ),
            child: const Text('إكمال'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _updating = true);

    try {
      final success = await OrdersService.updateOrderStatus(
        _order!.id,
        OrderStatus.completed.firestoreValue,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل إكمال الطلب'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }


      if (_order!.userId.isNotEmpty) {
        final technician = await AuthService.getUserData(AuthService.currentUser!.uid);
        final technicianName = technician?.name ?? 'فني';
        final customer = _customer ?? await AuthService.getUserData(_order!.userId);
        final customerName = customer?.name ?? 'عميل';


        await NotificationsService.notifyOrderCompleted(
          customerId: _order!.userId,
          orderId: _order!.id,
          technicianName: technicianName,
        );


        await NotificationsService.notifyAdminsOrderCompleted(
          technicianName: technicianName,
          customerName: customerName,
          orderId: _order!.id,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إكمال الطلب بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );

      _loadOrderData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${AppStrings.cleanErrorMessage(e)}'),
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
                                  ? 'العميل ألغى الطلب'
                                  : _order!.cancelledBy == 'technician'
                                      ? 'لقد قمت برفض الطلب'
                                      : 'تم إلغاء الطلب',
                              style: AppStyles.titleMedium.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              _order!.cancelledBy == 'customer'
                                  ? 'تم إلغاء هذا الطلب من قبل العميل'
                                  : _order!.cancelledBy == 'technician'
                                      ? 'تم رفض هذا الطلب من قبلك'
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


              if (_customer != null) ...[
                Text(
                  'معلومات العميل',
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
                        backgroundColor: AppColors.customer.withOpacity(0.1),
                        child: Text(
                          _customer!.name?.substring(0, 1).toUpperCase() ?? 'C',
                          style: AppStyles.bodyLarge.copyWith(
                            color: AppColors.customer,
                          ),
                        ),
                      ),
                      const Gap(AppStyles.spacingMD),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customer!.name ?? 'عميل',
                              style: AppStyles.titleMedium,
                            ),
                            if (_customer!.phone != null) ...[
                              const Gap(4),
                              Text(
                                _customer!.phone!,
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


              if (_order!.rating != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingMD),
                  decoration: AppStyles.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تقييم العميل',
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


              if (_order!.status == OrderStatus.pending) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _updating ? null : _rejectOrder,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                          ),
                        ),
                        child: const Text('رفض'),
                      ),
                    ),
                    const Gap(AppStyles.spacingMD),
                    Expanded(
                      child: CustomButton(
                        label: 'قبول',
                        onPressed: _updating ? null : _acceptOrder,
                      ),
                    ),
                  ],
                ),
              ] else if (_order!.status == OrderStatus.inProgress) ...[
                CustomButton(
                  label: 'إكمال الطلب',
                  onPressed: _updating ? null : _completeOrder,
                ),
              ],
              const Gap(AppStyles.spacingXL),
            ],
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

