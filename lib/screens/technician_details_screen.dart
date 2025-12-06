import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_strings.dart';
import '../widgets/custom_button.dart';
import '../services/technicians_service.dart';
import '../services/orders_service.dart';
import '../models/user_model.dart';
import '../utils/image_helper.dart';
import 'new_request_screen.dart';
import 'technician_reviews_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TechnicianDetailsScreen extends StatefulWidget {
  static const String routeName = '/technician';
  const TechnicianDetailsScreen({super.key});

  @override
  State<TechnicianDetailsScreen> createState() => _TechnicianDetailsScreenState();
}

class _TechnicianDetailsScreenState extends State<TechnicianDetailsScreen> {
  UserModel? _technician;
  bool _loading = true;
  double? _realRating;
  int _realTotalOrders = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTechnicianData();
    });
  }

  Future<void> _loadTechnicianData() async {
    final technicianId = ModalRoute.of(context)?.settings.arguments as String?;
    if (technicianId != null) {
      try {
        final tech = await TechniciansService.getTechnicianById(technicianId);
        if (mounted) {
          setState(() {
            _technician = tech;
            _loading = false;
          });


          final realRating = await OrdersService.calculateTechnicianRating(technicianId);
          final realTotalOrders = await OrdersService.calculateTechnicianTotalOrders(technicianId);
          if (mounted) {
            setState(() {
              _realRating = realRating;
              _realTotalOrders = realTotalOrders;
            });
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


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppStrings.technicianDetailsTitle,
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_technician == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppStrings.technicianDetailsTitle,
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(
          child: Text('الفني غير موجود'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.technicianDetailsTitle,
          style: AppStyles.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                padding: const EdgeInsets.all(AppStyles.spacingMD),
                decoration: AppStyles.cardDecoration,
                child: Row(
                  children: [
                    _buildProfileImage(),
                    const Gap(AppStyles.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _technician!.name ?? 'فني',
                            style: AppStyles.headlineMedium,
                          ),
                          const Gap(4),
                          Text(
                            _technician!.specialties?.join(', ') ?? 'غير محدد',
                            style: AppStyles.bodyMedium,
                          ),
                          const Gap(8),
                          GestureDetector(
                            onTap: _realRating != null && _realRating! > 0
                                ? () {
                                    final technicianId = ModalRoute.of(context)?.settings.arguments as String?;
                                    if (technicianId != null) {
                                      Navigator.pushNamed(
                                        context,
                                        TechnicianReviewsScreen.routeName,
                                        arguments: technicianId,
                                      );
                                    }
                                  }
                                : null,
                            child: Row(
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
                                if (_realRating != null && _realRating! > 0) ...[
                                  const Gap(4),
                                  Icon(
                                    Icons.chevron_left_rounded,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppStyles.spacingXL),


              if (_technician!.bio != null && _technician!.bio!.isNotEmpty) ...[
                Text(
                  'نبذة',
                  style: AppStyles.titleLarge,
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingSM),
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingMD),
                  decoration: AppStyles.cardDecoration,
                  child: Text(
                    _technician!.bio!,
                    style: AppStyles.bodyLarge,
                    textAlign: TextAlign.right,
                  ),
                ),
                const Gap(AppStyles.spacingXL),
              ],


              if (_technician!.specialties != null && _technician!.specialties!.isNotEmpty) ...[
                Text(
                  'التخصصات',
                  style: AppStyles.titleLarge,
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingSM),
                Wrap(
                  spacing: AppStyles.spacingSM,
                  runSpacing: AppStyles.spacingSM,
                  children: _technician!.specialties!.map((specialty) {
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
                const Gap(AppStyles.spacingXL),
              ],


              if (_technician!.phone != null) ...[
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'رقم الجوال',
                  value: _technician!.phone!,
                ),
                const Gap(AppStyles.spacingMD),
              ],
              if (_technician!.address != null) ...[
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'العنوان',
                  value: _technician!.address!,
                ),
                const Gap(AppStyles.spacingXL),
              ],


              CustomButton(
                label: 'إنشاء طلب خدمة',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    NewRequestScreen.routeName,
                    arguments: {
                      'technicianId': _technician!.id,
                      'serviceType': _technician!.specialties?.first ?? '',
                    },
                  );
                },
              ),
              const Gap(AppStyles.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_technician!.profileImage != null &&
        _technician!.profileImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        child: SizedBox(
          width: 84,
          height: 84,
          child: ImageHelper.base64ToImage(_technician!.profileImage!),
        ),
      );
    }

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.technician.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
      ),
      child: Center(
        child: Text(
          _technician!.name?.substring(0, 1).toUpperCase() ?? 'T',
          style: AppStyles.headlineMedium.copyWith(
            color: AppColors.technician,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingMD),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const Gap(AppStyles.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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
