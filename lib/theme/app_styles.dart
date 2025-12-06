import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_theme.dart';

class AppStyles {

  static const double radiusSmall = AppTheme.radiusSmall;
  static const double radiusMedium = AppTheme.radiusMedium;
  static const double radiusLarge = AppTheme.radiusLarge;
  static const double radiusXLarge = AppTheme.radiusXLarge;
  static const double radiusFull = AppTheme.radiusFull;


  static const double spacingXS = AppTheme.spacingXS;
  static const double spacingSM = AppTheme.spacingSM;
  static const double spacingMD = AppTheme.spacingMD;
  static const double spacingLG = AppTheme.spacingLG;
  static const double spacingXL = AppTheme.spacingXL;
  static const double spacingXXL = AppTheme.spacingXXL;
  static const double spacingXXXL = AppTheme.spacingXXXL;


  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -1,
  );

  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );


  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 6,
    shadowColor: AppColors.primary.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    textStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  ).copyWith(
    overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
  );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    textStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle get textButton => TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    textStyle: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );


  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(
      color: Colors.black.withOpacity(0.05),
      width: 1,
    ),
    boxShadow: AppTheme.softShadow,
  );


  static InputDecoration inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(
      fontSize: 15,
      color: AppColors.textTertiary,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: AppColors.backgroundSecondary,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: BorderSide(
        color: AppColors.primary.withOpacity(0.2),
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1.5,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 2,
      ),
    ),
  );
}
