// lib/modules/laundry/widgets/pay_as_you_go_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../laundry_controller.dart';

class PayAsYouGoCard extends StatelessWidget {
  const PayAsYouGoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LaundryController>();
    final isExpanded = false.obs;

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
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Pay As You Go',
                style: GoogleFonts.outfit(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                '(per pound)',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'Try Pay As You Go — \$2.25 per pound, 24–48 hour delivery, and the freedom to upgrade anytime for more perks.',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.foreground,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSizes.md),
          _buildStrikethroughBullet('\$10.99', 'Pickup & Delivery'),
          _buildBullet('24 to 48 h turnaround'),
          _buildBullet('20 lb minimum'),
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
                  'Pay Per Pound – \$2.25/lb',
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                _buildPlainBullet('Wash, Dry & Fold \$2.25/lb (by default)'),
                _buildPlainBullet('Wash & Dry Only \$1.75/lb (on request)'),
                _buildPlainBullet('Baby Items \$3.50/lb (where applicable)'),
                SizedBox(height: AppSizes.md),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.togglePayAsYouGo(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                    ),
                    child: Text(
                      controller.isPayAsYouGoSelected.value ? 'Added' : 'Add',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: AppSizes.md),
          GestureDetector(
            onTap: () => isExpanded.value = !isExpanded.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Learn more about benefits',
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4),
                Obx(() => AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded.value ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.primary,
                  ),
                )),
              ],
            ),
          ),
          Obx(() => AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: isExpanded.value
                ? Padding(
                    padding: EdgeInsets.only(top: AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlainBullet('Fill in bags of your choice'),
                        _buildPlainBullet('Limited Pickup & Delivery Windows'),
                        _buildPlainBullet('Standard pricing on add-ons'),
                        _buildPlainBullet('No rollovers'),
                        _buildPlainBullet('Perfect for occasional needs'),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          )),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSizes.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrikethroughBullet(String strikethroughText, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSizes.xs),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.foreground,
                ),
                children: [
                  TextSpan(
                    text: strikethroughText,
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  TextSpan(text: ' $text'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlainBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4, right: AppSizes.xs),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedForeground,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
