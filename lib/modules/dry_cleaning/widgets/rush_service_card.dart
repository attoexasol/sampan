import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../dry_cleaning_controller.dart';

class RushServiceCard extends StatelessWidget {
  const RushServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DryCleaningController>();

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
            'Want it sooner?',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'Get your items back faster',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Obx(() => Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rush Service',
                        style: TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '12 hour turnaround',
                        style: TextStyle(
                          fontSize: AppSizes.fontSm,
                          color: Colors.red.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '+50%',
                        style: TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => controller.toggleRushService(),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      color: controller.isRushServiceSelected.value
                          ? Colors.red.shade700
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(
                        color: Colors.red.shade700,
                      ),
                    ),
                    child: Text(
                      controller.isRushServiceSelected.value ? 'Added' : 'Add',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w700,
                        color: controller.isRushServiceSelected.value
                            ? Colors.white
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
