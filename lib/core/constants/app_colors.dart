import 'package:flutter/material.dart';

class AppColors {
  // Brand colors (Yeni Tasarım: Çini Mavisi & Firuze)
  static const Color primary = Color(0xFF1C4E80); // Çini Mavisi
  static const Color primaryLight = Color(0xFF8FB8E8);
  static const Color primaryDark = Color(0xFF0B2A47);
  
  static const Color accent = Color(0xFF0F8B8D); // Firuze
  static const Color accentLight = Color(0xFF5CC4C6);
  static const Color accentDark = Color(0xFF053B3C);

  // Status colors (Yeni Durum Paleti)
  static const Color statusPending = Color(0xFFB7791F); // Bekliyor
  static const Color statusInReview = Color(0xFF1B4DA0); // İnceleniyor
  static const Color statusResolved = Color(0xFF1F7A45); // Çözüldü
  static const Color statusRejected = Color(0xFFB3261E); // Reddedildi
  static const Color danger = Color(0xFFB3261E);

  // Light Mode Neutrals
  static const Color backgroundLight = Color(0xFFF5F7F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF141B22);
  static const Color textSecondaryLight = Color(0xFF56636F);
  static const Color borderLight = Color(0xFFDCE2E8);

  // Dark Mode Neutrals
  static const Color backgroundDark = Color(0xFF0E141B);
  static const Color surfaceDark = Color(0xFF171F28);
  static const Color textPrimaryDark = Color(0xFFE6EBF0);
  static const Color textSecondaryDark = Color(0xFF9AA7B4);
  static const Color borderDark = Color(0xFF26313C);

  // Transparency Score Indicator Colors
  static Color scoreColor(num score) {
    if (score >= 70) return const Color(0xFF1F7A45);
    if (score >= 40) return const Color(0xFFB7791F);
    return const Color(0xFFB3261E);
  }
}
