import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {



  static const Color primaryBlue = Color(0xFF2D9CDB);
  static const Color turquoise = Color(0xFF00C896);
  static const Color darkNavy = Color(0xFF0B0F17);
  static const Color gold = Color(0xFFD4AF37);
  static const Color surfaceLight = Color(0xFFF5F7FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F1115);
  static const Color textSecondary = Color(0xFF5A6570);
  static const Color textTertiary = Color(0xFF8B95A5);




  static LinearGradient get primaryGradient => LinearGradient(
        colors: [primaryBlue, turquoise],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get goldGradient => LinearGradient(
        colors: [gold, Color(0xFFFFD700)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get glassGradient => LinearGradient(
        colors: [
          white.withOpacity(0.9),
          white.withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );




  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 30,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primaryBlue.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 0),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get neumorphismShadow => [
        BoxShadow(
          color: Colors.white,
          blurRadius: 20,
          offset: const Offset(-8, -8),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(8, 8),
          spreadRadius: 0,
        ),
      ];




  static const double radiusSmall = 16.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 28.0;
  static const double radiusFull = 9999.0;




  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;




  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: white,
        primaryColor: primaryBlue,




        colorScheme: ColorScheme.light(
          primary: primaryBlue,
          secondary: turquoise,
          tertiary: gold,
          surface: white,
          error: const Color(0xFFEF4444),
          onPrimary: white,
          onSecondary: white,
          onTertiary: white,
          onSurface: textPrimary,
          onError: white,
        ),




        textTheme: TextTheme(

          displayLarge: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            height: 1.2,
            letterSpacing: -1,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            height: 1.2,
            letterSpacing: -0.8,
          ),
          displaySmall: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            height: 1.3,
            letterSpacing: -0.5,
          ),


          headlineLarge: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            height: 1.3,
            letterSpacing: -0.3,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.3,
          ),
          headlineSmall: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.4,
          ),


          titleLarge: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.4,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.4,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.4,
          ),


          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.6,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.6,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.6,
          ),


          labelLarge: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.4,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.4,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            height: 1.4,
          ),
        ),




        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return textTertiary.withOpacity(0.3);
              }
              return primaryBlue;
            }),
            foregroundColor: const WidgetStatePropertyAll(white),
            textStyle: WidgetStatePropertyAll(
              GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusMedium),
              ),
            ),
            elevation: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return 2;
              }
              return 6;
            }),
            shadowColor: WidgetStatePropertyAll(
              primaryBlue.withOpacity(0.3),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(primaryBlue),
            side: WidgetStatePropertyAll(
              BorderSide(color: primaryBlue, width: 2),
            ),
            textStyle: WidgetStatePropertyAll(
              GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusMedium),
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(primaryBlue),
            textStyle: WidgetStatePropertyAll(
              GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusSmall),
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),




        cardTheme: CardThemeData(
          color: white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
            side: BorderSide(
              color: Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: spacingMD,
            vertical: spacingSM,
          ),
        ),




        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceLight,
          prefixIconColor: primaryBlue,
          suffixIconColor: textTertiary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 15,
            color: textTertiary,
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(
              color: primaryBlue.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(
              color: primaryBlue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
        ),




        iconTheme: const IconThemeData(
          color: textPrimary,
          size: 24,
        ),




        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: textPrimary,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          iconTheme: const IconThemeData(
            color: textPrimary,
            size: 24,
          ),
        ),




        shadowColor: Colors.black.withOpacity(0.15),




        dividerTheme: DividerThemeData(
          color: Colors.black.withOpacity(0.08),
          thickness: 1,
          space: 1,
        ),




        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: white,
          selectedItemColor: primaryBlue,
          unselectedItemColor: textTertiary,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );






  static BoxDecoration glassCard({
    Color? color,
    double? borderRadius,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: (color ?? white).withOpacity(0.9),
      borderRadius: BorderRadius.circular(borderRadius ?? radiusLarge),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: shadows ?? softShadow,
    );
  }


  static BoxDecoration gradientButton({
    Gradient? gradient,
    double? borderRadius,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
      boxShadow: shadows ?? [
        ...softShadow,
        ...glowShadow,
      ],
    );
  }


  static BoxDecoration neumorphismCard({
    Color? color,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? surfaceLight,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusLarge),
      boxShadow: neumorphismShadow,
    );
  }
}

