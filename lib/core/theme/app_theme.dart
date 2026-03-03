import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFFEF4444); // Fire Red
  static const secondaryColor = Color(0xFF6366F1); // Indigo
  static const accentColor = Color(0xFFF59E0B); // Amber
  static const backgroundColor = Color(0xFF020617); // Extra Dark Blue
  static const sidebarColor = Color(0xFF000000); 
  static const cardColor = Color(0xFF0F172A); // Dark Slate Blue
  static const textColor = Color(0xFFF8FAFC);
  static const mutedTextColor = Color(0xFF94A3B8);

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.03),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withOpacity(0.08)),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        surface: cardColor,
        onSurface: Colors.white,
        secondary: secondaryColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12, color: mutedTextColor, letterSpacing: 1),
        dataTextStyle: GoogleFonts.outfit(fontSize: 14, color: textColor),
        headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
        dividerThickness: 1,
        horizontalMargin: 24,
        columnSpacing: 24,
      ),
    );
  }
}
