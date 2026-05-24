import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Widget? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double width;
  final double height;
  final double borderRadius;
  final double fontSize;
  final bool disabled;

  const Button.filled({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.borderColor,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 14,
    this.fontSize = 14,
    this.disabled = false,
  });

  const Button.ghost({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.surface,
    this.textColor = AppColors.text,
    this.borderColor = AppColors.border,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 14,
    this.fontSize = 14,
    this.disabled = false,
  });

  const Button.soft({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.primarySoft,
    this.textColor = AppColors.primaryStrong,
    this.borderColor,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 14,
    this.fontSize = 14,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: disabled ? AppColors.border : backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: borderColor != null
                  ? Border.all(color: borderColor!)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: disabled ? AppColors.textMuted : textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
