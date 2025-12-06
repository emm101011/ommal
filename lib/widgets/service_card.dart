import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? color;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final serviceColor = color ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        onTap: onTap,
        child: Container(
          decoration: AppTheme.glassCard(
            borderRadius: AppStyles.radiusLarge,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.spacingMD),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingSM),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        serviceColor.withOpacity(0.2),
                        serviceColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: serviceColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: serviceColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingSM),
                Flexible(
                  child: Text(
                    title,
                    style: AppStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
