import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';
import '../services/orders_service.dart';
import '../services/technicians_service.dart';
import '../services/notifications_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'my_orders_screen.dart';
import 'home_screen.dart';

class NewRequestScreen extends StatefulWidget {
  static const String routeName = '/new-request';
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _problemTypeController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _selectedTechnicianId;
  UserModel? _selectedTechnician;
  int _currentStep = 0;
  String? _selectedSpecialty;
  bool _isCustomServiceType = false;

  @override
  void initState() {
    super.initState();



    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Map) {
        final technicianId = args['technicianId'] as String?;
        final serviceType = args['serviceType'] as String?;

        if (technicianId == null || technicianId.isEmpty) {

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يجب اختيار فني أولاً'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        _selectedTechnicianId = technicianId;
        _loadTechnicianData(technicianId);



        if (serviceType != null && serviceType.isNotEmpty) {
          _selectedSpecialty = serviceType;
          _problemTypeController.text = serviceType;
        }
      } else {

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب اختيار فني أولاً'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  Future<void> _loadTechnicianData(String technicianId) async {
    try {
      final tech = await TechniciansService.getTechnicianById(technicianId);
      if (mounted) {
        setState(() => _selectedTechnician = tech);
      }
    } catch (e) {

    }
  }

  @override
  void dispose() {
    _problemTypeController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return _problemTypeController.text.trim().isNotEmpty;
      case 1:
        return _addressController.text.trim().isNotEmpty;
      case 2:
        return _descriptionController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateStep(_currentStep)) {
      setState(() {
        _currentStep++;
        _error = null;
      });
    } else {
      setState(() {
        _error = 'يرجى إكمال جميع الحقول المطلوبة';
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _error = null;
      });
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'يرجى تسجيل الدخول أولاً');
      return;
    }


    if (_selectedTechnicianId == null || _selectedTechnicianId!.isEmpty || _selectedTechnician == null) {
      setState(() => _error = 'يجب اختيار فني أولاً - لا يمكن إنشاء طلب بدون فني');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب اختيار فني أولاً - لا يمكن إنشاء طلب بدون فني'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final orderId = await OrdersService.createOrder(
        userId: user.uid,
        serviceType: _problemTypeController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        technicianId: _selectedTechnicianId!,
      );

      if (orderId == null) {
        setState(() => _error = 'فشل إنشاء الطلب');
        return;
      }


      if (_selectedTechnicianId != null) {
        final userData = await AuthService.getUserData(user.uid);
        final customerName = userData?.name ?? 'عميل';
        final technician = await TechniciansService.getTechnicianById(_selectedTechnicianId!);
        final technicianName = technician?.name ?? 'فني';


        await NotificationsService.notifyNewOrder(
          technicianId: _selectedTechnicianId!,
          orderId: orderId,
          customerName: customerName,
          serviceType: _problemTypeController.text.trim(),
        );


        await NotificationsService.notifyAdminsNewOrder(
          customerName: customerName,
          technicianName: technicianName,
          orderId: orderId,
          serviceType: _problemTypeController.text.trim(),
        );
      }

      if (!mounted) return;
      _showSuccessDialog(context);
    } catch (e) {
      if (mounted) {
        setState(() => _error = AppStrings.cleanErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXLarge),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppStyles.spacingXL),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyles.radiusXLarge),
            gradient: AppTheme.glassGradient,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const Gap(AppStyles.spacingXL),
              Text(
                'تم إنشاء الطلب بنجاح!',
                style: AppStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const Gap(AppStyles.spacingSM),
              Text(
                'تم إرسال طلبك بنجاح وسيتم التواصل معك قريباً',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(AppStyles.spacingXL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          HomeScreen.routeName,
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppStyles.spacingMD,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home_rounded, size: 20),
                          const Gap(AppStyles.spacingSM),
                          Text(
                            'الرئيسية',
                            style: AppStyles.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(AppStyles.spacingMD),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(
                          context,
                          MyOrdersScreen.routeName,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppStyles.spacingMD,
                        ),
                        elevation: 6,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment_rounded, size: 20),
                          const Gap(AppStyles.spacingSM),
                          Text(
                            'طلباتي',
                            style: AppStyles.labelLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'طلب خدمة جديد',
          style: AppStyles.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              _buildProgressSteps(),


              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppStyles.spacingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Gap(AppStyles.spacingLG),


                      if (_selectedTechnician != null) ...[
                        _buildTechnicianCard(),
                        const Gap(AppStyles.spacingXL),
                      ],


                      _buildStepContent(),

                      const Gap(AppStyles.spacingXL),


                      if (_error != null) ...[
                        _buildErrorMessage(),
                        const Gap(AppStyles.spacingMD),
                      ],


                      _buildNavigationButtons(),

                      const Gap(AppStyles.spacingXL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    final steps = ['نوع الخدمة', 'العنوان', 'التفاصيل'];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingLG,
        vertical: AppStyles.spacingMD,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: isActive || isCompleted
                              ? AppTheme.primaryGradient
                              : null,
                          color: isActive || isCompleted
                              ? null
                              : AppColors.backgroundSecondary,
                          shape: BoxShape.circle,
                          boxShadow: isActive
                              ? AppTheme.glowShadow
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: AppStyles.labelMedium.copyWith(
                                    color: isActive || isCompleted
                                        ? Colors.white
                                        : AppColors.textTertiary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const Gap(AppStyles.spacingSM),
                      Text(
                        steps[index],
                        style: AppStyles.labelSmall.copyWith(
                          color: isActive || isCompleted
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppStyles.spacingSM,
                      ),
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? AppTheme.primaryGradient
                            : null,
                        color: isCompleted
                            ? null
                            : AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTechnicianCard() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingMD),
      decoration: AppTheme.glassCard(
        borderRadius: AppStyles.radiusLarge,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.spacingMD),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const Gap(AppStyles.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الفني المختار',
                  style: AppStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Gap(4),
                Text(
                  _selectedTechnician!.name ?? 'فني',
                  style: AppStyles.titleMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            color: AppColors.textTertiary,
            onPressed: () {

              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeScreen.routeName,
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إلغاء الطلب - يجب اختيار فني أولاً'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildServiceTypeStep();
      case 1:
        return _buildAddressStep();
      case 2:
        return _buildDescriptionStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildServiceTypeStep() {
    final specialties = _selectedTechnician?.specialties ?? [];
    final hasMultipleSpecialties = specialties.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
              ),
              child: const Icon(
                Icons.build_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const Gap(AppStyles.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ما نوع الخدمة المطلوبة؟',
                    style: AppStyles.headlineSmall,
                  ),
                  const Gap(4),
                  Text(
                    hasMultipleSpecialties
                        ? 'اختر أحد تخصصات الفني أو اكتب نوع خدمة آخر'
                        : 'اختر نوع المشكلة التي تحتاج إلى إصلاح',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(AppStyles.spacingXL),


        if (hasMultipleSpecialties) ...[
          Text(
            'تخصصات الفني المتاحة:',
            style: AppStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(AppStyles.spacingMD),
          Wrap(
            spacing: AppStyles.spacingSM,
            runSpacing: AppStyles.spacingSM,
            children: [
              ...specialties.map((specialty) {
                final isSelected = _selectedSpecialty == specialty && !_isCustomServiceType;
                return FilterChip(
                  label: Text(
                    specialty,
                    style: AppStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSpecialty = specialty;
                        _isCustomServiceType = false;
                        _problemTypeController.text = specialty;
                      } else {
                        _selectedSpecialty = null;
                        _problemTypeController.clear();
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.backgroundSecondary,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  elevation: isSelected ? 4 : 0,
                  shadowColor: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spacingMD,
                    vertical: AppStyles.spacingSM,
                  ),
                );
              }),

              FilterChip(
                label: Text(
                  'أخرى',
                  style: AppStyles.labelMedium.copyWith(
                    color: _isCustomServiceType ? Colors.white : AppColors.textPrimary,
                    fontWeight: _isCustomServiceType ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: _isCustomServiceType,
                onSelected: (selected) {
                  setState(() {
                    _isCustomServiceType = selected;
                    if (selected) {
                      _selectedSpecialty = null;
                      _problemTypeController.clear();
                    } else {
                      _problemTypeController.clear();
                    }
                  });
                },
                selectedColor: AppColors.accent,
                backgroundColor: AppColors.backgroundSecondary,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: _isCustomServiceType ? AppColors.accent : AppColors.border,
                  width: _isCustomServiceType ? 2 : 1,
                ),
                elevation: _isCustomServiceType ? 4 : 0,
                shadowColor: _isCustomServiceType ? AppColors.accent.withOpacity(0.3) : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.spacingMD,
                  vertical: AppStyles.spacingSM,
                ),
              ),
            ],
          ),
          const Gap(AppStyles.spacingXL),
        ],


        TextFormField(
          controller: _problemTypeController,
          textInputAction: TextInputAction.next,
          enabled: !hasMultipleSpecialties || _isCustomServiceType || _selectedSpecialty == null,
          decoration: AppStyles.inputDecoration(
            hasMultipleSpecialties && !_isCustomServiceType && _selectedSpecialty == null
                ? 'اختر تخصصاً من القائمة أعلاه'
                : 'مثال: سباكة، كهرباء، تكييف...',
          ),
          style: AppStyles.bodyLarge,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال نوع الخدمة';
            }
            return null;
          },
          onChanged: (value) {

            if (hasMultipleSpecialties && value.isNotEmpty && _selectedSpecialty != value) {
              setState(() {
                _isCustomServiceType = true;
                _selectedSpecialty = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accent.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const Gap(AppStyles.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أين موقع المشكلة؟',
                    style: AppStyles.headlineSmall,
                  ),
                  const Gap(4),
                  Text(
                    'أدخل العنوان الكامل للموقع',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(AppStyles.spacingXL),
        TextFormField(
          controller: _addressController,
          textInputAction: TextInputAction.next,
          decoration: AppStyles.inputDecoration('المدينة - الحي - الشارع - رقم المبنى'),
          style: AppStyles.bodyLarge,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال العنوان';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold,
                    AppColors.gold.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const Gap(AppStyles.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وصف المشكلة',
                    style: AppStyles.headlineSmall,
                  ),
                  const Gap(4),
                  Text(
                    'اكتب تفاصيل المشكلة بشكل واضح',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(AppStyles.spacingXL),
        TextFormField(
          controller: _descriptionController,
          maxLines: 6,
          textInputAction: TextInputAction.newline,
          decoration: AppStyles.inputDecoration(
            'اكتب وصفاً مفصلاً عن المشكلة...',
          ).copyWith(
            contentPadding: const EdgeInsets.all(AppStyles.spacingMD),
          ),
          style: AppStyles.bodyLarge,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال وصف المشكلة';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const Gap(AppStyles.spacingSM),
          Expanded(
            child: Text(
              _error!,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (_currentStep == 2) {
      return _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: _submitOrder,
              icon: const Icon(Icons.send_rounded),
              label: const Text('إرسال الطلب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.spacingLG,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                ),
                elevation: 6,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
            );
    }

    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('السابق'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.spacingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const Gap(AppStyles.spacingMD),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _nextStep,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('التالي'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppStyles.spacingMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
              ),
              elevation: 6,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }
}
