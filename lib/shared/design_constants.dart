import 'package:flutter/material.dart';

class DesignColors {
  static const Color background = Color(0xFFF8FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F0);
  static const Color primary = Color(0xFF28D339);
  static const Color primaryDark = Color(0xFF1B9E26);
  static const Color primaryLight = Color(0xFF4AE056);
  static const Color secondary = Color(0xFFE8E8E8);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color accent = Color(0xFF44FF44);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  
  static const Color gradientStart = Color(0xFF28D339);
  static const Color gradientEnd = Color(0xFF1B9E26);
  
  static const Color cardShadow = Color(0x1A000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Soft Palette for Category Tiles (Premium Grocery Look)
  static const Color mintBackground = Color(0xFFBCE2D3);
  static const Color mintTileUnselected = Color(0xFFC7E8D9);
  static const Color softBlue = Color(0xFFE3F2FD);
  static const Color softOrange = Color(0xFFFFF3E0);
  static const Color softPurple = Color(0xFFF3E5F5);
  static const Color softRed = Color(0xFFFFEBEE);
  static const Color softTeal = Color(0xFFE0F2F1);
  static const Color softYellow = Color(0xFFFFFDE7);
  static const Color dullLightGreen = Color(0xFFEAF4EA);
  static const Color filterBackground = Color(0xFFD5ECD5);
}

class DesignGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [DesignColors.primary, DesignColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4AE056), DesignColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1B2E1D), Color(0xFF0F1A12)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class DesignSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;
}

class DesignRadius {
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double full = 100.0;
}

class DesignShadows {
  static List<BoxShadow> get small => [
    BoxShadow(
      color: DesignColors.cardShadow,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: DesignColors.cardShadow,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get large => [
    BoxShadow(
      color: DesignColors.cardShadow.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get glow => [
    BoxShadow(
      color: DesignColors.primary.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}
