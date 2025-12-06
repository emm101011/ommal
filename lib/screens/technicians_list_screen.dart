import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../widgets/technician_card.dart';
import '../theme/app_strings.dart';
import '../services/technicians_service.dart';
import '../services/orders_service.dart';
import '../models/user_model.dart';
import 'technician_details_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TechniciansListScreen extends StatelessWidget {
  static const String routeName = '/technicians';
  const TechniciansListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final specialty = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          specialty != null ? specialty : AppStrings.techniciansTitle,
          style: AppStyles.headlineSmall,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: specialty != null && specialty != 'الكل'
            ? TechniciansService.getTechniciansBySpecialty(specialty)
            : TechniciansService.getTechnicians(),
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
                    'لا يوجد فنيون متاحون',
                    style: AppStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final technicians = snapshot.data!.docs
              .map((doc) => UserModel.fromFirestore(doc.data() as Map<String, dynamic>))
              .toList();

          return RefreshIndicator(
            onRefresh: () async => await Future.delayed(
              const Duration(milliseconds: 800),
            ),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppStyles.spacingMD),
              itemCount: technicians.length,
              separatorBuilder: (_, __) => const Gap(AppStyles.spacingMD),
              itemBuilder: (_, i) {
                final tech = technicians[i];
                return FutureBuilder<Map<String, dynamic>>(
                  future: _getTechnicianStats(tech.id),
                  builder: (context, statsSnapshot) {

                    final realRating = statsSnapshot.data?['rating'] ?? 0.0;
                    final card = TechnicianCard(
                      name: tech.name ?? 'فني',
                      specialty: tech.specialties?.join(', ') ?? 'غير محدد',
                      rating: realRating,
                      imageUrl: tech.profileImage,
                      onTap: () => Navigator.pushNamed(
                        context,
                        TechnicianDetailsScreen.routeName,
                        arguments: tech.id,
                      ),
                    );
                    return Slidable(
                      key: ValueKey('tech_${tech.id}'),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) {},
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            icon: Icons.call,
                            label: 'اتصال',
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(AppStyles.radiusLarge),
                              bottomRight: Radius.circular(AppStyles.radiusLarge),
                            ),
                          ),
                          SlidableAction(
                            onPressed: (_) {},
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            icon: Icons.message,
                            label: 'رسالة',
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(AppStyles.radiusLarge),
                              bottomRight: Radius.circular(AppStyles.radiusLarge),
                            ),
                          ),
                        ],
                      ),
                      child: card,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFilter(context, specialty),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.filter_list, color: Colors.white),
        label: Text(
          'فلترة',
          style: AppStyles.labelMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> _getTechnicianStats(String technicianId) async {
  final rating = await OrdersService.calculateTechnicianRating(technicianId);
  final totalOrders = await OrdersService.calculateTechnicianTotalOrders(technicianId);
  return {
    'rating': rating ?? 0.0,
    'totalOrders': totalOrders,
  };
}

void _openFilter(BuildContext context, String? currentSpecialty) {
  showCupertinoModalBottomSheet(
    context: context,
    builder: (ctx) {
      int selected = 0;
      final options = const ['الكل', 'سباكة', 'كهرباء', 'تكييف', 'تنظيف', 'نجارة', 'مكافحة حشرات'];


      if (currentSpecialty != null) {
        selected = options.indexOf(currentSpecialty);
        if (selected == -1) selected = 0;
      }

      return Material(
        color: AppColors.background,
        child: SafeArea(
          top: false,
          child: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.all(AppStyles.spacingLG),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'فلترة حسب التخصص',
                    style: AppStyles.headlineSmall,
                    textAlign: TextAlign.right,
                  ),
                  const Gap(AppStyles.spacingMD),
                  Wrap(
                    spacing: AppStyles.spacingSM,
                    runSpacing: AppStyles.spacingSM,
                    children: List.generate(options.length, (i) {
                      final isSel = i == selected;
                      return FilterChip(
                        label: Text(
                          options[i],
                          style: AppStyles.labelMedium.copyWith(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        selected: isSel,
                        onSelected: (_) => setState(() => selected = i),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.backgroundSecondary,
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: isSel ? AppColors.primary : AppColors.border,
                          width: isSel ? 2 : 1,
                        ),
                        elevation: isSel ? 4 : 0,
                        shadowColor: isSel ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppStyles.spacingMD,
                          vertical: AppStyles.spacingSM,
                        ),
                      );
                    }),
                  ),
                  const Gap(AppStyles.spacingLG),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (selected > 0) {
                        Navigator.pushReplacementNamed(
                          context,
                          TechniciansListScreen.routeName,
                          arguments: options[selected],
                        );
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          TechniciansListScreen.routeName,
                        );
                      }
                    },
                    style: AppStyles.primaryButton,
                    child: const Text('تطبيق'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
