import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../services/orders_service.dart';
import '../models/order_model.dart';
import 'technician_order_details_screen.dart';

class TechnicianOrdersScreen extends StatelessWidget {
  static const String routeName = '/technician-orders';
  const TechnicianOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('يرجى تسجيل الدخول'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
        stream: OrdersService.getTechnicianOrders(user.uid),
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


          final allOrders = snapshot.data?.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList() ?? [];

          final visibleOrders = allOrders.where((order) => !order.isDeleted).toList();

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty || visibleOrders.isEmpty) {
            return Center(
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
                        Icons.assignment_outlined,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Gap(AppStyles.spacingXL),
                    Text(
                      'لا يوجد طلبات لديك',
                      style: AppStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(AppStyles.spacingMD),
                    Text(
                      'لم يتم تعيين أي طلبات لك بعد',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final orders = visibleOrders;


          final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).toList();
          final inProgressOrders = orders.where((o) => o.status == OrderStatus.inProgress).toList();
          final completedOrders = orders.where((o) => o.status == OrderStatus.completed).toList();

          return ListView(
            padding: const EdgeInsets.all(AppStyles.spacingMD),
            children: [

              if (pendingOrders.isNotEmpty) ...[
                _SectionHeader(
                  title: 'طلبات جديدة',
                  count: pendingOrders.length,
                  color: AppColors.statusPending,
                ),
                const Gap(AppStyles.spacingSM),
                ...pendingOrders.map((order) => _TechnicianOrderCard(
                      order: order,
                      onTap: () => Navigator.pushNamed(
                        context,
                        TechnicianOrderDetailsScreen.routeName,
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
                ...inProgressOrders.map((order) => _TechnicianOrderCard(
                      order: order,
                      onTap: () => Navigator.pushNamed(
                        context,
                        TechnicianOrderDetailsScreen.routeName,
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
                ...completedOrders.map((order) => _TechnicianOrderCard(
                      order: order,
                      onTap: () => Navigator.pushNamed(
                        context,
                        TechnicianOrderDetailsScreen.routeName,
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
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(AppStyles.spacingSM),
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

class _TechnicianOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _TechnicianOrderCard({
    required this.order,
    required this.onTap,
  });

  Color get _statusColor {
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
        decoration: AppStyles.cardDecoration,
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
                  Text(
                    'طلب #${order.id.substring(0, 8)}',
                    style: AppStyles.titleMedium,
                  ),
                  const Gap(4),
                  Text(
                    order.serviceType,
                    style: AppStyles.bodySmall,
                  ),
                  const Gap(4),
                  Row(
                    children: [
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
                          order.status.displayName,
                          style: AppStyles.labelSmall.copyWith(
                            color: _statusColor,
                          ),
                        ),
                      ),
                      if (order.rating != null) ...[
                        const Gap(8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const Gap(4),
                            Text(
                              order.rating!.toStringAsFixed(1),
                              style: AppStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ],
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

