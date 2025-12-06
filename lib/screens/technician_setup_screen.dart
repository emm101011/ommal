import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_strings.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class TechnicianSetupScreen extends StatefulWidget {
  static const String routeName = '/technician-setup';
  const TechnicianSetupScreen({super.key});

  @override
  State<TechnicianSetupScreen> createState() => _TechnicianSetupScreenState();
}

class _TechnicianSetupScreenState extends State<TechnicianSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  final List<String> _selectedSpecialties = [];
  bool _loading = false;
  String? _userId;

  final List<String> _availableSpecialties = [
    'سباكة',
    'كهرباء',
    'تكييف',
    'تنظيف',
    'نجارة',
    'مكافحة حشرات',
    'دهان',
    'بلاط',
    'حدادة',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ModalRoute.of(context)?.settings.arguments as String?;
      if (userId != null) {
        setState(() => _userId = userId);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى اختيار تخصص واحد على الأقل'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ: معرف المستخدم غير موجود'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {

      await AuthService.completeTechnicianProfile(
        userId: _userId!,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        specialties: _selectedSpecialties,
        bio: _bioController.text.trim(),
      );

      if (!mounted) return;


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ الملف الشخصي بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );


      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${AppStrings.cleanErrorMessage(e)}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
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
          'إكمال الملف الشخصي',
          style: AppStyles.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(AppStyles.spacingLG),


                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingMD),
                  decoration: BoxDecoration(
                    color: AppColors.technician.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                    border: Border.all(
                      color: AppColors.technician.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.technician,
                        size: 24,
                      ),
                      const Gap(AppStyles.spacingMD),
                      Expanded(
                        child: Text(
                          'يجب إكمال ملفك الشخصي لتفعيل حسابك',
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.technician,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppStyles.spacingXL),


                Text(
                  'الاسم الكامل',
                  style: AppStyles.labelLarge,
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingSM),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: AppStyles.inputDecoration('أدخل اسمك الكامل'),
                  style: AppStyles.bodyLarge,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال الاسم';
                    }
                    return null;
                  },
                ),
                const Gap(AppStyles.spacingMD),


                Text(
                  'رقم الجوال',
                  style: AppStyles.labelLarge,
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingSM),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: AppStyles.inputDecoration('05xxxxxxxx'),
                  style: AppStyles.bodyLarge,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال رقم الجوال';
                    }
                    if (value.length < 10) {
                      return 'رقم الجوال غير صحيح';
                    }
                    return null;
                  },
                ),
                const Gap(AppStyles.spacingMD),


                Text(
                  'العنوان',
                  style: AppStyles.labelLarge,
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingSM),
                TextFormField(
                  controller: _addressController,
                  textInputAction: TextInputAction.next,
                  decoration: AppStyles.inputDecoration('المدينة - الحي - الشارع'),
                  style: AppStyles.bodyLarge,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال العنوان';
                    }
                    return null;
                  },
                ),
                const Gap(AppStyles.spacingMD),


                Text(
                  'التخصصات',
                  style: AppStyles.labelLarge,
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingSM),
                Wrap(
                  spacing: AppStyles.spacingSM,
                  runSpacing: AppStyles.spacingSM,
                  children: _availableSpecialties.map((specialty) {
                    final isSelected = _selectedSpecialties.contains(specialty);
                    return FilterChip(
                      label: Text(specialty),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSpecialties.add(specialty);
                          } else {
                            _selectedSpecialties.remove(specialty);
                          }
                        });
                      },
                      selectedColor: AppColors.technician.withOpacity(0.2),
                      checkmarkColor: AppColors.technician,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.technician
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    );
                  }).toList(),
                ),
                const Gap(AppStyles.spacingMD),


                Text(
                  'نبذة عنك',
                  style: AppStyles.labelLarge,
                  textAlign: TextAlign.right,
                ),
                const Gap(AppStyles.spacingSM),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: AppStyles.inputDecoration(
                    'اكتب نبذة مختصرة عن خبرتك ومهاراتك...',
                  ).copyWith(
                    contentPadding: const EdgeInsets.all(AppStyles.spacingMD),
                  ),
                  style: AppStyles.bodyLarge,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى كتابة نبذة عنك';
                    }
                    if (value.length < 20) {
                      return 'النبذة يجب أن تكون 20 حرف على الأقل';
                    }
                    return null;
                  },
                ),
                const Gap(AppStyles.spacingXL),


                _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.technician,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submitProfile,
                        style: AppStyles.primaryButton.copyWith(
                          backgroundColor: WidgetStateProperty.all(
                            AppColors.technician,
                          ),
                        ),
                        child: const Text('حفظ وإكمال التسجيل'),
                      ),
                const Gap(AppStyles.spacingXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

