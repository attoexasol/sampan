import 'package:flutter/material.dart';
import 'package:sampan/constants/colors.dart';
import 'package:sampan/constants/sizes.dart';

class OrderHistoryCard extends StatelessWidget {
  final VoidCallback onTap;

  const OrderHistoryCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        //horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.lg),
          child: Row(
            children: [
              // 📦 Leading Icon
              Container(
                padding: EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  size: AppSizes.iconLg,
                ),
              ),

              SizedBox(width: AppSizes.md),

              // 📝 Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Order History',
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      'View past orders and receipts',
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),

              // ➡️ Trailing Arrow
              Icon(
                Icons.chevron_right,
                color: AppColors.mutedForeground,
                size: AppSizes.iconLg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
