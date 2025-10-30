import 'package:flutter/material.dart';
import 'app_colors.dart'; 

class AppTheme {
  
  // === LIGHT THEME ===
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    
    // ColorScheme định nghĩa bộ màu cho các component của Flutter
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: Colors.white,
      onPrimary: Colors.white, // Màu chữ/icon trên nền Primary
      onSecondary: Colors.black, // Màu chữ/icon trên nền Secondary
      onSurface: AppColors.lightTextPrimary, // Màu chữ/icon trên nền Surface
    ),
    
    // Cấu hình text
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24, 
        fontWeight: FontWeight.bold, 
        color: AppColors.lightTextPrimary
      ),
      bodyLarge: TextStyle(
        fontSize: 16, 
        color: AppColors.lightTextPrimary
      ),
      bodyMedium: TextStyle(
        fontSize: 14, 
        color: AppColors.lightTextSecondary
      ),
    ),
    
    // Cấu hình nút
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white, // Màu chữ của nút
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    
    // Cấu hình ô nhập liệu
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.lightPrimary, 
          width: 2
        ),
      ),
    ),
  );

  // === DARK THEME ===
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      onPrimary: Colors.black, // Màu chữ/icon trên nền Primary
      onSecondary: Colors.black, // Màu chữ/icon trên nền Secondary
      onSurface: AppColors.darkTextPrimary, // Màu chữ/icon trên nền Surface
    ),

    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24, 
        fontWeight: FontWeight.bold, 
        color: AppColors.darkTextPrimary
      ),
      bodyLarge: TextStyle(
        fontSize: 16, 
        color: AppColors.darkTextPrimary
      ),
      bodyMedium: TextStyle(
        fontSize: 14, 
        color: AppColors.darkTextSecondary
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.black, // Màu chữ của nút
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.darkPrimary, 
          width: 2
        ),
      ),
    ),
  );
}