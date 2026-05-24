import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

enum PillType { ok, warn, due }

class StatusPill extends StatelessWidget {
  final String label;
  final PillType type;

  const StatusPill({
    super.key,
    required this.label,
    required this.type,
  });

  Color get _bg {
    switch (type) {
      case PillType.ok:
        return AppColors.tintMintBg;
      case PillType.warn:
        return AppColors.tintAmberBg;
      case PillType.due:
        return AppColors.tintRoseBg;
    }
  }

  Color get _fg {
    switch (type) {
      case PillType.ok:
        return AppColors.tintMintFg;
      case PillType.warn:
        return AppColors.tintAmberFg;
      case PillType.due:
        return AppColors.tintRoseFg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _fg,
            ),
          ),
        ],
      ),
    );
  }
}
