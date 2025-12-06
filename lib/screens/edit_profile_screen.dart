import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/image_helper.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  UserModel? _userData;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _selectedImageBase64;
  List<String> _selectedSpecialties = [];

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = AuthService.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);
      }
      return;
    }

    try {
      final userData = await AuthService.getUserData(user.uid);
      if (mounted && userData != null) {
        setState(() {
          _userData = userData;
          _nameController.text = userData.name ?? '';
          _phoneController.text = userData.phone ?? '';
          _addressController.text = userData.address ?? '';
          _bioController.text = userData.bio ?? '';
          _selectedSpecialties = userData.specialties ?? [];
          _selectedImageBase64 = userData.profileImage;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickImage() async {

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppStyles.radiusXLarge),
          ),
        ),
        padding: const EdgeInsets.all(AppStyles.spacingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppStyles.spacingLG),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                'من المعرض',
                style: AppStyles.titleMedium,
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.accent,
                ),
              ),
              title: Text(
                'من الكاميرا',
                style: AppStyles.titleMedium,
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const Gap(AppStyles.spacingMD),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final image = await ImageHelper.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final base64 = await ImageHelper.compressAndConvertToBase64(
          image.path,
          quality: 85,
        );

        if (mounted && base64 != null) {
          setState(() => _selectedImageBase64 = base64);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصورة: ${AppStrings.cleanErrorMessage(e)}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;


    if (_userData!.role == UserRole.technician && _selectedSpecialties.isEmpty) {
      setState(() => _error = 'يرجى اختيار تخصص واحد على الأقل');
      return;
    }

    final user = AuthService.currentUser;
    if (user == null || _userData == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (_userData!.role == UserRole.technician) {

        await AuthService.completeTechnicianProfile(
          userId: user.uid,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          specialties: _selectedSpecialties,
          bio: _bioController.text.trim(),
          profileImageBase64: _selectedImageBase64,
        );
      } else {

        await AuthService.updateUserProfile(
          userId: user.uid,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );


        if (_selectedImageBase64 != null) {
          await AuthService.updateProfileImage(
            userId: user.uid,
            imageBase64: _selectedImageBase64!,
          );
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ التعديلات بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = AppStrings.cleanErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
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
            'تعديل الملف الشخصي',
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'تعديل الملف الشخصي',
            style: AppStyles.headlineSmall,
          ),
        ),
        body: const Center(child: Text('لا توجد بيانات')),
      );
    }

    final isTechnician = _userData!.role == UserRole.technician;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'تعديل الملف الشخصي',
          style: AppStyles.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.spacingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(AppStyles.spacingLG),


                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: AppTheme.softShadow,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipOval(
                          child: _selectedImageBase64 != null
                              ? ImageHelper.base64ToImage(_selectedImageBase64!)
                              : Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _nameController.text.isNotEmpty
                                          ? _nameController.text[0].toUpperCase()
                                          : 'U',
                                      style: AppStyles.headlineLarge.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 3,
                              ),
                              boxShadow: AppTheme.glowShadow,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
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


                if (isTechnician) ...[

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
                          color: isSelected ? AppColors.technician : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      );
                    }).toList(),
                  ),
                  if (_userData!.role == UserRole.technician && _selectedSpecialties.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppStyles.spacingSM),
                      child: Text(
                        'يرجى اختيار تخصص واحد على الأقل',
                        style: AppStyles.bodySmall.copyWith(color: AppColors.error),
                        textAlign: TextAlign.right,
                      ),
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
                    decoration: AppStyles.inputDecoration(
                      'اكتب نبذة مختصرة عن خبرتك ومهاراتك...',
                    ).copyWith(
                      contentPadding: const EdgeInsets.all(AppStyles.spacingMD),
                    ),
                    style: AppStyles.bodyLarge,
                  ),
                  const Gap(AppStyles.spacingMD),
                ],


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


                _saving
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                    : CustomButton(
                        label: 'حفظ التعديلات',
                        onPressed: _saveProfile,
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

