import 'package:flutter/material.dart';

class PremiumTheme {
  // Dark Theme Palette
  static const Color darkBg = Color(0xFF0A0C10);
  static const Color darkSurface = Color(0xFF131722);
  static const Color darkSurfaceCard = Color(0xFF1B2030);
  static const Color darkBorder = Color(0xFF2A314A);
  
  static const Color primaryNeon = Color(0xFF00E5FF); // Electric Cyan
  static const Color secondaryNeon = Color(0xFF7C4DFF); // Vivid Purple
  static const Color accentGold = Color(0xFFFFB300); // Premium Gold
  
  static const Color successGreen = Color(0xFF00E676);
  static const Color errorRed = Color(0xFFFF1744);
  
  static const Color textPrimary = Color(0xFFF5F6FA);
  static const Color textSecondary = Color(0xFF8F9BB3);
  static const Color textMuted = Color(0xFF5E6982);

  // Gradient styles
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNeon, secondaryNeon],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF171B26), Color(0xFF0F111A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGoldGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphic shadow style
  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primaryNeon.withValues(alpha: 0.04),
      blurRadius: 24,
      offset: const Offset(0, 0),
    ),
  ];

  static ThemeData getThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryNeon,
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: secondaryNeon,
        surface: darkSurface,
        onSurface: textPrimary,
        error: errorRed,
      ),
      cardColor: darkSurfaceCard,
      dividerColor: darkBorder,
      // Default icon theme
      iconTheme: const IconThemeData(color: textPrimary),
    );
  }
}
