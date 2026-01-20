import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class SpecialtyHowItWorksCard extends StatelessWidget {
  const SpecialtyHowItWorksCard({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Alterations / Steaming /',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                Text(
                  'Shoe Care',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              'How It Works',
              style: GoogleFonts.outfit(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          _buildStep(
            number: '1',
            title: 'Select Items / Services',
            description: 'Choose services based on your garment or shoe needs.\n(Ex: Marked 4 shirts but send a pant, coat, jacket, or shoes — we\'ll fix it.)',
          ),
          SizedBox(height: AppSizes.md),
          _buildStep(
            number: '2',
            title: 'Expert Care & Assessment',
            description: 'Our specialists inspect, clean, sanitize, alter, or restore items\nusing appropriate methods for each material.',
          ),
          SizedBox(height: AppSizes.md),
          _buildStep(
            number: '3',
            title: 'Professional Service',
            description: 'Items are carefully steamed, altered, or polished to ensure\nthe best fit, finish, and appearance.',
          ),
          SizedBox(height: AppSizes.md),
          _buildStep(
            number: '4',
            title: 'Pickup & Return',
            description: 'We pick up your items and return them refreshed,\npressed, polished, or perfectly fitted.',
          ),
          SizedBox(height: AppSizes.md),
          _buildStep(
            number: '5',
            title: 'Billing',
            description: 'Minimum charged upfront. Final cost adjusted if needed\nbased on condition, complexity, or material.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w700,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
