import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/app_styles.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.rLg),
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: [AppStyles.shadowSm],
      ),
      child: child,
    );
  }
}
