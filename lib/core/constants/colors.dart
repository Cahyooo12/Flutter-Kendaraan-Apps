import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3D6BF5);
  static const Color primaryStrong = Color(0xFF2A52D8);
  static const Color primarySoft = Color(0xFFE8EEFE);
  static const Color primarySofter = Color(0xFFF2F5FF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color bg = Color(0xFFF5F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF8FAFD);

  static const Color heroTop = Color(0xFF4A7BF7);
  static const Color heroBottom = Color(0xFF6B95FA);

  static const Color text = Color(0xFF0F1B33);
  static const Color textMuted = Color(0xFF6B7689);
  static const Color textSoft = Color(0xFF97A0B3);
  static const Color divider = Color(0xFFECEFF5);
  static const Color border = Color(0xFFE5E9F2);

  // Tints
  static const Color tintBlueBg = Color(0xFFE8EEFE);
  static const Color tintBlueFg = Color(0xFF2A52D8);
  static const Color tintMintBg = Color(0xFFE1F4EC);
  static const Color tintMintFg = Color(0xFF1F8F66);
  static const Color tintPeachBg = Color(0xFFFCE9DC);
  static const Color tintPeachFg = Color(0xFFC75F22);
  static const Color tintLavenderBg = Color(0xFFECE8FB);
  static const Color tintLavenderFg = Color(0xFF6B49C8);
  static const Color tintRoseBg = Color(0xFFFBE5EC);
  static const Color tintRoseFg = Color(0xFFC73D6A);
  static const Color tintAmberBg = Color(0xFFFBF1D8);
  static const Color tintAmberFg = Color(0xFF9B7A1F);

  // Status
  static const Color success = Color(0xFF1F8F66);
  static const Color warning = Color(0xFFC7841F);
  static const Color danger = Color(0xFFD2475A);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A7BF7), Color(0xFF6B95FA)],
  );

  static const LinearGradient heroGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4A7BF7), Color(0xFF6B95FA)],
  );
}
