import 'package:flutter/material.dart';
import '../theme/colors.dart';

class TechTag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSecondary;

  const TechTag({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? (isSecondary ? PremiumTheme.secondaryNeon : PremiumTheme.primaryNeon);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: themeColor,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: themeColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
