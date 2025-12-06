import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';
import '../services/dummy_data_service.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = false;

  Future<void> _createDummyData() async {
    setState(() => _loading = true);

    try {
      await DummyDataService.initializeDummyData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إنشاء البيانات التجريبية بنجاح!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إنشاء البيانات: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );
    } finally {
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
        title: Text(AppStrings.settingsTitle, style: AppStyles.headlineSmall),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppStyles.spacingMD),
        children: [
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'الإشعارات',
            onTap: () {},
          ),
          const Gap(AppStyles.spacingSM),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'اللغة',
            subtitle: 'العربية',
            onTap: () {},
          ),
          const Gap(AppStyles.spacingSM),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'المساعدة',
            onTap: () {},
          ),
          const Gap(AppStyles.spacingSM),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'عن التطبيق',
            onTap: () {},
          ),
          const Gap(AppStyles.spacingXL),


          Container(
            padding: const EdgeInsets.all(AppStyles.spacingMD),
            decoration: AppTheme.glassCard(borderRadius: AppStyles.radiusLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'البيانات التجريبية',
                  style: AppStyles.titleMedium,
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingSM),
                Text(
                  'إنشاء بيانات تجريبية للفنيين والطلبات للاختبار',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingMD),
                _loading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                    : ElevatedButton.icon(
                      onPressed: _createDummyData,
                      icon: const Icon(Icons.data_object_rounded),
                      label: const Text('إنشاء البيانات التجريبية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppStyles.spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusMedium,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
      child: Container(
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
                  Text(title, style: AppStyles.bodyLarge),
                  if (subtitle != null) ...[
                    const Gap(4),
                    Text(subtitle!, style: AppStyles.bodySmall),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
