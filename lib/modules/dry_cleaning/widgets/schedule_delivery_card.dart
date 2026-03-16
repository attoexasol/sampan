import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class ScheduleDeliveryCard extends StatelessWidget {
  const ScheduleDeliveryCard({super.key});

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
            'Service Schedule & Delivery',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Timing and delivery options',
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
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turnaround Time',
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                _buildBullet('Standard: 3 business days'),
                _buildBullet('Rush Dry Cleaning: Choose a delivery slot within 24 hours of pickup → 2× price (⚡ on schedule)'),
                _buildBullet('For rush dry cleaning, please confirm timing with us before placing the order.'),
              ],
            ),
          ),
          SizedBox(height: AppSizes.md),
          Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup & Delivery Fee',
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                Text(
                  '\$10.99 per trip. Minimum order: \$45',
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
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

  Widget _buildBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(width: AppSizes.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
