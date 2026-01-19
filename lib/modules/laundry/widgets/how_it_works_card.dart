// lib/modules/laundry/widgets/how_it_works_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class HowItWorksCard extends StatelessWidget {
  const HowItWorksCard({super.key});

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
          Text(
            'Laundry',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'How It Works',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildStep(
                  icon: Icons.inventory_2_outlined,
                  title: 'Select',
                  subtitle: 'Pick a service',
                ),
              ),
              Expanded(
                child: _buildStep(
                  icon: Icons.calendar_today_outlined,
                  title: 'Schedule',
                  subtitle: 'Pick a time',
                ),
              ),
              Expanded(
                child: _buildStep(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Enjoy',
                  subtitle: 'Pick clean living',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: AppSizes.iconMd,
          ),
        ),
        SizedBox(height: AppSizes.sm),
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
          subtitle,
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
