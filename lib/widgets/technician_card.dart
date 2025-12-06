import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../utils/image_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TechnicianCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String? imageUrl;
  final VoidCallback? onTap;

  const TechnicianCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        child: Container(
          decoration: AppTheme.glassCard(
            borderRadius: AppStyles.radiusLarge,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.spacingMD),
            child: Row(
              children: [

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                    child: _buildProfileImage(),
                  ),
                ),
                const Gap(AppStyles.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppStyles.titleMedium,
                      ),
                      const Gap(4),
                      Text(
                        specialty,
                        style: AppStyles.bodySmall,
                      ),
                      const Gap(8),
                      if (rating > 0) ...[
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: rating,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 18,
                              ),
                              itemSize: 18,
                            ),
                            const Gap(4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: AppStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'لا يوجد تقييم',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {

    final isBase64 = imageUrl != null &&
        imageUrl!.isNotEmpty &&
        (imageUrl!.length > 100 || imageUrl!.startsWith('data:'));

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (isBase64) {

        return SizedBox(
          width: 64,
          height: 64,
          child: ImageHelper.base64ToImage(imageUrl!),
        );
      } else {

        return CachedNetworkImage(
          imageUrl: imageUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: AppColors.backgroundSecondary,
            highlightColor: AppColors.surface,
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.backgroundSecondary,
            ),
          ),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        );
      }
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.technician.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      ),
      child: Icon(
        Icons.person,
        color: AppColors.technician,
        size: 32,
      ),
    );
  }
}
