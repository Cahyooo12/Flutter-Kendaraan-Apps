import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double size;
  final double borderRadius;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.size = 40,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor ?? AppColors.border),
        ),
        child: Center(child: icon),
      ),
    );
  }
}
