import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_strings.dart';
import '../widgets/custom_button.dart';
import '../services/orders_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingScreen extends StatefulWidget {
  static const String routeName = '/rating';
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _commentController = TextEditingController();
  double _rating = 4.0;
  bool _loading = false;
  String? _error;
  String? _orderId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        setState(() {
          _orderId = args['orderId'] as String?;
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_orderId == null) {
      setState(() => _error = 'خطأ: معرف الطلب غير موجود');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {

      final success = await OrdersService.submitRating(
        orderId: _orderId!,
        rating: _rating,
        review: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
      );

      if (!success) {
        setState(() => _error = 'فشل إرسال التقييم');
        return;
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('شكراً لك! تم إرسال تقييمك بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'حدث خطأ: ${AppStrings.cleanErrorMessage(e)}');
      }
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
        title: Text(
          AppStrings.ratingTitle,
          style: AppStyles.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(AppStyles.spacingXL),

              Text(
                'ما تقييمك للخدمة؟',
                style: AppStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const Gap(AppStyles.spacingXL),

              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  allowHalfRating: true,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemSize: 48,
                  onRatingUpdate: (v) => setState(() => _rating = v),
                ),
              ),
              const Gap(AppStyles.spacingXL),

              Text(
                'اكتب رأيك',
                style: AppStyles.labelLarge,
                textAlign: TextAlign.right,
              ),
              const Gap(AppStyles.spacingSM),
              TextFormField(
                controller: _commentController,
                textAlign: TextAlign.right,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: AppStyles.inputDecoration('أكتب رأيك... (اختياري)').copyWith(
                  contentPadding: const EdgeInsets.all(AppStyles.spacingMD),
                ),
                style: AppStyles.bodyLarge,
              ),
              const Gap(AppStyles.spacingXL),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingMD),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const Gap(AppStyles.spacingSM),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppStyles.spacingMD),
              ],

              _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : CustomButton(
                      label: 'إرسال التقييم',
                      onPressed: _submitRating,
                    ),
              const Gap(AppStyles.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}
