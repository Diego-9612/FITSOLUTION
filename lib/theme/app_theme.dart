import 'package:flutter/material.dart';

class AppTheme {
  static const Color brand = Color(0xFFFFB703);    
  static const Color brandDark = Color(0xFFFB8500); 
  static const Color ink = Color(0xFF1F2937);
  static const Color bg = Color(0xFFFFFAF0);

  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        primary: brand,
        secondary: brandDark,
        background: bg,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),

      
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        surfaceTintColor: Colors.transparent, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.all(8),
      ),
    );
  }
}
