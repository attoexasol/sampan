import 'package:flutter_screenutil/flutter_screenutil.dart';

/// AppSizes — responsive spacing, fonts, radii, and icons
/// that automatically adapt to the user's screen size.
class AppSizes {
  // 📏 Margins & Paddings (responsive to width)
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;

  // 🔤 Font Sizes (responsive to pixel density)
  static double get fontXs => 10.sp;
  static double get fontSm => 12.sp;
  static double get fontMd => 14.sp;
  static double get fontLg => 16.sp;
  static double get fontXl => 20.sp;
  static double get fontXxl => 24.sp;
  static double get fontHuge => 32.sp;

  // 🟢 Border Radius (responsive)
  static double get radiusSm => 6.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 20.r;
  static double get radiusXl => 28.r;
  static double get radiusFull => 100.r;

  // ☁️ Elevation (fixed, doesn’t depend on screen size)
  static double get elevationSm => 2;
  static double get elevationMd => 6;
  static double get elevationLg => 12;

  // 🧩 Icon Sizes (responsive)
  static double get iconSm => 16.sp;
  static double get iconMd => 24.sp;
  static double get iconLg => 32.sp;

  // 📱 Screen Sizes (for full-width or height usage)
  static double get screenWidth => 1.sw;
  static double get screenHeight => 1.sh;
}
