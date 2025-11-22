import 'package:flutter/material.dart';

// Color constants
class AppColors {
  static const Color primaryColor = Color(0xFFD49649); // Gold/Amber color
  static const Color textColor = Color(0xFF2D3142); // Dark text color
  static const Color backgroundColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFF8A8A8A);
  static const Color inputBackground = Color(0xFFF5F5F5);
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  
  // Primary color scheme
  colorScheme: ColorScheme.light(
    primary: const Color(0xFFD49649), // Gold/Amber color
    secondary: const Color(0xFF2D3142), // Dark text color
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFF2D3142),
  ),
  
  // Scaffold
  scaffoldBackgroundColor: Colors.white,
  
  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF2D3142),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2D3142),
    ),
  ),
  
  // Text Theme
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2D3142),
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2D3142),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color(0xFF2D3142),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF8A8A8A),
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      color: Color(0xFF8A8A8A),
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    hintStyle: const TextStyle(
      color: Color(0xFFAAAAAA),
      fontSize: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFFD49649),
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 1,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 1.5,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
  ),
  
  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFD49649),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  ),
  
  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFD49649),
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),
  ),
  
  // Icon Theme
  iconTheme: const IconThemeData(
    color: Color(0xFFD49649),
    size: 24,
  ),
);

