import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class SpecialtyDisclaimersCard extends StatelessWidget {
  const SpecialtyDisclaimersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Important Disclaimers',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Please read before service.',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Disclaimer',
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'No guarantee of complete restoration or alteration results. Priority is preserving item safety and quality.',
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
