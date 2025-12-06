import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../models/notification_model.dart';
import '../services/notifications_service.dart';
import '../services/auth_service.dart';
import 'order_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'الإشعارات',
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(
          child: Text('يرجى تسجيل الدخول'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'الإشعارات',
          style: AppStyles.headlineSmall,
        ),
        actions: [
          StreamBuilder<int>(
            stream: NotificationsService.getUnreadCount(user.uid),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              if (unreadCount == 0) return const SizedBox.shrink();

              return TextButton.icon(
                onPressed: () async {
                  await NotificationsService.markAllAsRead(user.uid);
                },
                icon: const Icon(Icons.done_all, size: 18),
                label: Text('قراءة الكل ($unreadCount)'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: NotificationsService.getUserNotifications(user.uid),
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
                        Icons.notifications_none,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Gap(AppStyles.spacingXL),
                    Text(
                      'لا توجد إشعارات',
                      style: AppStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(AppStyles.spacingSM),
                    Text(
                      'ستظهر الإشعارات هنا عند وجود تحديثات',
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

          final notifications = snapshot.data!.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(AppStyles.spacingMD),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationCard(
                notification: notification,
                onTap: () async {

                  if (!notification.isRead) {
                    await NotificationsService.markAsRead(notification.id);
                  }


                  if (notification.orderId != null) {
                    if (mounted) {
                      Navigator.pushNamed(
                        context,
                        OrderDetailsScreen.routeName,
                        arguments: notification.orderId,
                      );
                    }
                  }
                },
                onDelete: () async {
                  await NotificationsService.deleteNotification(notification.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.newOrder:
        return Icons.add_circle_outline;
      case NotificationType.orderAccepted:
        return Icons.check_circle_outline;
      case NotificationType.orderRejected:
        return Icons.cancel_outlined;
      case NotificationType.orderCompleted:
        return Icons.done_all_outlined;
      case NotificationType.orderCancelled:
        return Icons.block_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.newOrder:
        return AppColors.primary;
      case NotificationType.orderAccepted:
        return AppColors.success;
      case NotificationType.orderRejected:
        return AppColors.error;
      case NotificationType.orderCompleted:
        return AppColors.success;
      case NotificationType.orderCancelled:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppStyles.spacingMD),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppStyles.spacingMD),
          padding: const EdgeInsets.all(AppStyles.spacingMD),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.background
                : AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.border
                  : AppColors.primary.withOpacity(0.3),
              width: notification.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.spacingSM),
                decoration: BoxDecoration(
                  color: _iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  color: _iconColor,
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
                            notification.title,
                            style: AppStyles.titleMedium.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      notification.body,
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _formatDate(notification.createdAt),
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return date.toString().substring(0, 10);
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}

