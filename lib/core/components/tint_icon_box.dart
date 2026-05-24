import 'package:flutter/material.dart';

class TintIconBox extends StatelessWidget {
  final Widget icon;
  final Color backgroundColor;
  final double size;
  final double borderRadius;

  const TintIconBox({
    super.key,
    required this.icon,
    required this.backgroundColor,
    this.size = 42,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(child: icon),
    );
  }
}
