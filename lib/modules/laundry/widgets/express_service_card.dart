// lib/modules/laundry/widgets/express_service_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

/// Informational card explaining automatic express delivery policy.
/// Express delivery is automatically applied when delivery is scheduled
/// within 24 hours of pickup (5% fee). Minimum 4-hour gap required.
class ExpressServiceCard extends StatelessWidget {
  const ExpressServiceCard({super.key});

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bolt,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚡ Express Delivery',
                      style: GoogleFonts.outfit(
                        fontSize: AppSizes.fontXl,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    Text(
                      'Automatically applied when needed',
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
          SizedBox(height: AppSizes.md),
          Text(
            'Need it faster? Express delivery is automatically applied when you schedule delivery within 24 hours of pickup!',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.md),
          
          // Express policy info
          Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPolicyRow(
                  icon: Icons.bolt,
                  text: 'Delivery within 24 hours of pickup',
                ),
                SizedBox(height: AppSizes.sm),
                _buildPolicyRow(
                  icon: Icons.percent,
                  text: '5% express fee added automatically',
                ),
                SizedBox(height: AppSizes.sm),
                _buildPolicyRow(
                  icon: Icons.timer_outlined,
                  text: 'Minimum 4-hour turnaround required',
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppSizes.md),
          Text(
            'Express fee will be calculated and shown during checkout when you select your pickup and delivery times.',
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.mutedForeground,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.orange.shade700,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w500,
              color: Colors.orange.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
