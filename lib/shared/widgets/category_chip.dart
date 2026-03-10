import 'package:flutter/material.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;

  const CategoryChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.l,
          vertical: DesignSpacing.s + 2,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? DesignGradients.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.xxl),
          border: Border.all(
            color: isSelected ? Colors.transparent : DesignColors.secondary,
            width: 1.5,
          ),
          boxShadow: isSelected ? DesignShadows.glow : DesignShadows.small,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: width != null ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : DesignColors.primaryDark,
              ),
              const SizedBox(width: DesignSpacing.s),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : DesignColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
