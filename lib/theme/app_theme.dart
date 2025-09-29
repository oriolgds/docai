import 'package:flutter/material.dart';

class AppTheme {
  // Green color palette for health/medical theme
  static const Color primaryGreen = Color(0xFF2E7D32); // Medical green
  static const Color lightGreen = Color(0xFF4CAF50); // Lighter green for accent
  static const Color darkGreen = Color(0xFF1B5E20); // Darker green for contrast
  static const Color softGreen = Color(0xFF81C784); // Soft green for backgrounds
  static const Color paleGreen = Color(0xFFE8F5E8); // Very light green for surfaces
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        onPrimary: Colors.white,
        secondary: softGreen,
        onSecondary: Colors.white,
        tertiary: lightGreen,
        surface: Colors.white,
        onSurface: darkGreen,
        error: Color(0xFFE53E3E),
        onError: Colors.white,
        outline: Color(0xFFB0BEC5),
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: darkGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryGreen),
        actionsIconTheme: IconThemeData(color: primaryGreen),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: primaryGreen,
        elevation: 8,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: softGreen,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: primaryGreen,
      ),
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53E3E)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2),
        ),
        filled: true,
        fillColor: paleGreen,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: paleGreen,
        labelStyle: const TextStyle(color: darkGreen),
        selectedColor: lightGreen,
        secondarySelectedColor: softGreen,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
        linearTrackColor: paleGreen,
        circularTrackColor: paleGreen,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.grey[300];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen;
          }
          return Colors.grey[400];
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen;
          }
          return Colors.grey[600];
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryGreen,
        inactiveTrackColor: paleGreen,
        thumbColor: primaryGreen,
        overlayColor: softGreen.withOpacity(0.2),
      ),
    );
  }
}