import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppColors {
  // === MÀU TỪ FIGMA ===
  // Màu chủ đạo (neon)
  static const Color primary = Color(0xFFBAFF29); 
  
  // Màu nền cho Light Mode
  static const Color lightBackground = Color(0xFFFDFDFD); 
  
  // Màu nền cho Dark Mode
  static const Color darkBackground = Color(0xFF000000);
  
  // Màu cho Card/Surface trong Dark Mode
  static const Color darkSurface = Color(0xFF252525);
  // (Màu #252525D9 là màu 252525 với 85% opacity, 
  // chúng ta sẽ dùng màu #252525 đặc)

  
  // === BỘ MÀU LIGHT MODE ===
  static const Color lightPrimary = primary;
  static const Color lightSecondary = primary; // Dùng 1 màu chủ đạo
  static const Color lightTextPrimary = Color(0xFF212121); // Chữ gần đen
  static const Color lightTextSecondary = Color(0xFF757575); // Chữ xám

  // === BỘ MÀU DARK MODE ===
  static const Color darkPrimary = primary;
  static const Color darkSecondary = primary; // Dùng 1 màu chủ đạo
  static const Color darkTextPrimary = Color(0xFFFDFDFD); // Chữ gần trắng
  static const Color darkTextSecondary = Color(0xFFBDBDBD);

  static var lightSurface; // Chữ xám nhạt
}