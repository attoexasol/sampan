import 'package:flutter/material.dart';

class AppColors {
  // SAMPAN Brand Colors (matching React HSL values)
  static const Color primary = Color(0xFF20B2AA); // hsl(168 76% 42%)
  static const Color primaryDark = Color(0xFF158F8A); // hsl(168 85% 35%)
  static const Color primaryLight = Color(0xFF6DD4CE); // hsl(168 65% 65%)
  static const Color primaryLighter = Color(0xFFE8F7F6); // hsl(168 30% 95%)
  static const Color primaryForeground = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFF5F7F9); // hsl(220 15% 97%)
  static const Color foreground = Color(0xFF1F2937); // hsl(220 20% 15%)

  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1F2937);

  static const Color secondary = Color(0xFFF1F2F4); // hsl(220 13% 95%)
  static const Color secondaryForeground = Color(0xFF1F2937);

  static const Color muted = Color(0xFFE8EAEC); // hsl(220 13% 92%)
  static const Color mutedForeground = Color(0xFF374151); // darker gray

  static const Color accent = Color(0xFF20B2AA);
  static const Color accentForeground = Color(0xFFFFFFFF);
  static const Color white = Colors.white;
  //static const Color sampangreen =  Color(0xFF0F172A);




  static const Color destructive = Color(0xFFEF4444); // hsl(0 84% 60%)
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFD1D5DB); // hsl(220 13% 87%)
  static const Color input = Color(0xFFD1D5DB);

  // Gradients
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF20B2AA), Color(0xFF158F8A)],
  );

  static const LinearGradient gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF20B2AA), Color(0xFF2DC9C1)],
  );
}
