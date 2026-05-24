import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppStyles {
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.44,
        color: AppColors.text,
      );

  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.36,
        color: AppColors.text,
      );

  static TextStyle get h3 => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.16,
        color: AppColors.text,
      );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.14,
        color: AppColors.text,
      );

  static TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.24,
        color: AppColors.textMuted,
      );

  static TextStyle get meta => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get numeric => GoogleFonts.plusJakartaSans(
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  static BoxShadow get shadowSm => BoxShadow(
        color: const Color(0xFF0F1B33).withValues(alpha: 0.04),
        blurRadius: 2,
        offset: const Offset(0, 1),
      );

  static BoxShadow get shadow => BoxShadow(
        color: const Color(0xFF0F1B33).withValues(alpha: 0.06),
        blurRadius: 14,
        offset: const Offset(0, 4),
      );

  static BoxShadow get shadowLg => BoxShadow(
        color: const Color(0xFF0F1B33).withValues(alpha: 0.10),
        blurRadius: 32,
        offset: const Offset(0, 14),
      );

  static const double rSm = 10;
  static const double r = 14;
  static const double rLg = 20;
  static const double rXl = 28;
}
