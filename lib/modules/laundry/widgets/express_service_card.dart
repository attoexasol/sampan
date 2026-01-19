// lib/modules/laundry/widgets/express_service_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../laundry_controller.dart';

class ExpressServiceCard extends StatelessWidget {
  const ExpressServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LaundryController>();

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
              Text(
                'Want It Sooner?',
                style: GoogleFonts.outfit(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'Get your laundry back faster',
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
                        'Express Service',
                        style: TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '24-hour turnaround',
                        style: TextStyle(
                          fontSize: AppSizes.fontSm,
                          color: Colors.red.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '+\$${LaundryController.expressServicePrice.toStringAsFixed(2)}',
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
                  onTap: () => controller.toggleExpressService(),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      color: controller.isExpressServiceSelected.value
                          ? Colors.red.shade700
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(
                        color: Colors.red.shade700,
                      ),
                    ),
                    child: Text(
                      controller.isExpressServiceSelected.value ? 'Added' : 'Add',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w700,
                        color: controller.isExpressServiceSelected.value
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
