import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF1E3A8A); // Lacivert / Mavi (Güven & Kurumsallık)
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF172554);
  
  static const Color accent = Color(0xFF10B981); // Şeffaflık Yeşil / Zümrüt
  static const Color accentLight = Color(0xFF34D399);
  static const Color accentDark = Color(0xFF047857);

  // Status colors
  static const Color statusPending = Color(0xFFF59E0B); // Amber / Bekliyor
  static const Color statusInReview = Color(0xFF3B82F6); // Mavi / İnceleniyor
  static const Color statusResolved = Color(0xFF10B981); // Yeşil / Çözüldü
  static const Color statusRejected = Color(0xFFEF4444); // Kırmızı / Reddedildi

  // Light Mode Neutrals
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Mode Neutrals
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Transparency Score Indicator Colors
  static Color scoreColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF84CC16);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
