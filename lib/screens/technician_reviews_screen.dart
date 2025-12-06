import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../models/order_model.dart';
import '../services/orders_service.dart';

class TechnicianReviewsScreen extends StatefulWidget {
  static const String routeName = '/technician-reviews';
  const TechnicianReviewsScreen({super.key});

  @override
  State<TechnicianReviewsScreen> createState() => _TechnicianReviewsScreenState();
}

class _TechnicianReviewsScreenState extends State<TechnicianReviewsScreen> {
  List<OrderModel> _reviews = [];
  bool _loading = true;
  String? _technicianId;
  double? _averageRating;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _technicianId = args;
    } else if (args is Map) {
      _technicianId = args['technicianId'] as String?;
    }

    if (_technicianId == null) {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);
      }
      return;
    }

    setState(() => _loading = true);

    try {

      final rating = await OrdersService.calculateTechnicianRating(_technicianId!);


      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('technicianId', isEqualTo: _technicianId)
          .where('status', isEqualTo: 'completed')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      if (mounted) {
        final allOrders = snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList();

        final reviewsWithRating = allOrders
            .where((order) => order.rating != null)
            .toList();

        final reviewsWithText = allOrders
            .where((order) => 
                order.rating != null && 
                order.review != null && 
                order.review!.isNotEmpty)
            .toList();

        setState(() {
          _averageRating = rating;
          _totalReviews = reviewsWithRating.length;
          _reviews = reviewsWithText;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
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
          'التقييمات والآراء',
          style: AppStyles.headlineSmall,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
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
                            Icons.star_outline,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Gap(AppStyles.spacingXL),
                        Text(
                          'لا توجد آراء مكتوبة بعد',
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppStyles.spacingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Container(
                        padding: const EdgeInsets.all(AppStyles.spacingLG),
                        decoration: AppStyles.cardDecoration,
                        child: Column(
                          children: [
                            if (_averageRating != null && _averageRating! > 0) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...List.generate(5, (i) => Icon(
                                        i < _averageRating!.round()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 32,
                                      )),
                                  const Gap(8),
                                  Text(
                                    _averageRating!.toStringAsFixed(1),
                                    style: AppStyles.headlineMedium,
                                  ),
                                ],
                              ),
                              const Gap(AppStyles.spacingSM),
                            ],
                            Text(
                              '$_totalReviews تقييم',
                              style: AppStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (_reviews.isNotEmpty) ...[
                              const Gap(4),
                              Text(
                                '${_reviews.length} رأي مكتوب',
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Gap(AppStyles.spacingXL),


                      Text(
                        'الآراء المكتوبة',
                        style: AppStyles.titleLarge,
                        textAlign: TextAlign.right,
                      ),
                      const Gap(AppStyles.spacingMD),
                      ..._reviews.map((order) => _ReviewCard(order: order)),
                    ],
                  ),
                ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final OrderModel order;

  const _ReviewCard({
    required this.order,
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
              const Spacer(),
              Text(
                order.createdAt.toString().substring(0, 10),
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
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
        ],
      ),
    );
  }
}

