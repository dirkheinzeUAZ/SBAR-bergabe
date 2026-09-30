import 'package:flutter/material.dart';

/// Zentrales Farb- und Design-System, angelehnt an das Layout der
/// "UKSH Akademie – Beatmungsleitlinie"-App: dunkles Klinik-Blau,
/// helle Akzentflächen, klare Karten mit runden Ecken.
class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF003366); // Header, Titel, aktive Elemente
  static const Color secondaryBlue = Color(0xFF0057A0); // Akzente, Buttons
  static const Color tertiaryBlue = Color(0xFF2E7FD1); // Fokus/Highlights
  static const Color lightBackground = Color(0xFFEAF3FB); // App-Hintergrund
  static const Color chipBackground = Color(0xFFEBF3FC); // Icon-Kacheln, Badges

  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFD7E6F5);

  // Status-/Score-Farben
  static const Color statusGreenBg = Color(0xFFDCF5E3);
  static const Color statusGreenText = Color(0xFF1A7A3D);
  static const Color statusRedBg = Color(0xFFFDE2E2);
  static const Color statusRedText = Color(0xFFB42318);
  static const Color statusAmberBg = Color(0xFFFFF3D6);
  static const Color statusAmberText = Color(0xFF92650A);
  static const Color statusOrangeBg = Color(0xFFFFE6D6);
  static const Color statusOrangeText = Color(0xFFB9540A);
  static const Color statusNeutralBg = Color(0xFFECEFF3);
  static const Color statusNeutralText = Color(0xFF4A5568);

  static const Color cardShadow = Color(0x0F000000);
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryBlue,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.08)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.tertiaryBlue, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        extendedTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 16),
        bodyMedium: const TextStyle(color: AppColors.textDark, fontSize: 14),
        bodySmall: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      dividerColor: AppColors.borderLight,
    );
  }
}
