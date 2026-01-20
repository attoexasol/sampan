import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart'; // update path if needed
import '../constants/sizes.dart'; // your AppSizes file

class HeaderWidget extends StatelessWidget {
  final String? subtitle;
  
  const HeaderWidget({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.screenWidth,
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.lg,
        horizontal: AppSizes.md,
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/sampan-logo.png',
            width: AppSizes.screenWidth * 0.25,
            height: AppSizes.screenWidth * 0.25,
          ),
          SizedBox(height: AppSizes.md),

          Text(
            'SAMPAN',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontHuge,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSizes.sm),

          Text(
            subtitle ?? 'Laundry & Dry Cleaning',
            style: TextStyle(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSizes.xs),

          // 🌿 Subtitle
          Text(
            'Eco Conscious and Cleanliness Obsessed',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
