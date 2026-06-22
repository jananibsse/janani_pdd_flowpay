import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const background = Color(0xFF050816);
  static const surface = Color(0xFF0D1224);
  static const surfaceElevated = Color(0xFF11182C);
  static const cyanAccent = Colors.cyanAccent;
  static const purpleAccent = Colors.purpleAccent;
  static const error = Colors.redAccent;
}

abstract final class AppTheme {
  static ThemeData flowPayTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.cyanAccent,
        secondary: AppColors.purpleAccent,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }

  static BoxDecoration glowCard({
    Color accent = AppColors.cyanAccent,
    double radius = 20,
  }) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: accent.withValues(alpha: 0.35)),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.12),
          blurRadius: 28,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: AppColors.purpleAccent.withValues(alpha: 0.06),
          blurRadius: 40,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration panel({double radius = 16}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white12),
    );
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  }

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) {
      return 960;
    }
    if (width >= 900) {
      return 820;
    }
    return width;
  }
}
