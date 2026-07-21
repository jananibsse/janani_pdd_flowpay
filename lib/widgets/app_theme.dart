import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  // Base palette
  static const background = Color(0xFF030712);
  static const surface = Color(0xFF0A0F1E);
  static const surfaceElevated = Color(0xFF0F1629);
  static const surfaceGlass = Color(0x1A6C63FF);

  // Accent palette
  static const cyanAccent = Color(0xFF00F5FF);
  static const purpleAccent = Color(0xFF8B5CF6);
  static const indigoAccent = Color(0xFF6366F1);
  static const pinkAccent = Color(0xFFEC4899);
  static const emeraldAccent = Color(0xFF10B981);
  static const error = Colors.redAccent;

  // Aurora orb colors
  static const auroraBlue = Color(0xFF1E3A5F);
  static const auroraPurple = Color(0xFF2D1B69);
  static const auroraCyan = Color(0xFF0E4D5F);
  static const auroraIndigo = Color(0xFF1A1040);

  // Glass layer
  static const glassWhite = Color(0x0DFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const glassShadow = Color(0x40000000);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.inter(color: Colors.white54),
        filled: true,
        fillColor: AppColors.surfaceGlass,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cyanAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }

  /// Classic glow card — kept for backward compat
  static BoxDecoration glowCard({
    Color accent = AppColors.cyanAccent,
    double radius = 20,
  }) {
    return BoxDecoration(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: accent.withValues(alpha: 0.25)),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.15),
          blurRadius: 32,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: AppColors.purpleAccent.withValues(alpha: 0.08),
          blurRadius: 48,
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// Glassmorphism decoration — use inside ClipRRect
  static BoxDecoration glass({
    Color tint = AppColors.glassWhite,
    Color borderColor = AppColors.glassBorder,
    double radius = 20,
    Color glowColor = AppColors.cyanAccent,
    double glowStrength = 0.12,
  }) {
    return BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1.0),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: glowStrength),
          blurRadius: 30,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: AppColors.glassShadow,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration panel({double radius = 16}) {
    return BoxDecoration(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
    if (width >= 1200) return 960;
    if (width >= 900) return 820;
    return width;
  }

  /// Shimmer gradient for loading states
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-2, 0),
    end: Alignment(2, 0),
    colors: [
      Color(0xFF0F1629),
      Color(0xFF1E2A45),
      Color(0xFF2A3558),
      Color(0xFF1E2A45),
      Color(0xFF0F1629),
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  /// Neon gradient for buttons
  static const LinearGradient neonGradient = LinearGradient(
    colors: [AppColors.cyanAccent, AppColors.indigoAccent, AppColors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Primary button gradient  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.purpleAccent, AppColors.indigoAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cyan button gradient
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [AppColors.cyanAccent, Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
