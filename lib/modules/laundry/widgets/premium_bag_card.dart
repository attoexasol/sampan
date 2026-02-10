// lib/modules/laundry/widgets/premium_bag_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../controller/products_controller.dart';
import '../laundry_controller.dart';

class PremiumBagCard extends StatelessWidget {
  const PremiumBagCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LaundryController>();
    final productsCtrl = Get.find<ProductsController>();
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
                'Premium Bag Service',
                style: GoogleFonts.outfit(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                '(per bag)',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'When life gets messy, our Premium Bag gets it all done in 12 hours — picked up, washed, folded, and back at your door.',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.foreground,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSizes.md),
          _buildStrikethroughBullet('\$10.99', 'Free Pickup & Delivery'),
          _buildBullet('Same-day (12h) turnaround'),
          _buildBullet('Priority Pickup & Delivery Windows'),
          SizedBox(height: AppSizes.lg),
          Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Obx(() {
                  final price = productsCtrl.eliteExpressBagPrice.value;
                  final label = price > 0
                      ? 'Elite Express Bag – \$${price.toStringAsFixed(0)} per bag'
                      : 'Elite Express Bag – \$109 per bag';
                  return Text(
                    label,
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
                SizedBox(height: AppSizes.md),
                Obx(() {
                  final price = productsCtrl.eliteExpressBagPrice.value;
                  final available = price > 0 && productsCtrl.eliteExpressBag.value != null;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: available
                          ? () => controller.togglePremiumBag(productsCtrl)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isPremiumBagSelected.value
                            ? AppColors.primary
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                      ),
                      child: Text(
                        controller.isPremiumBagSelected.value ? 'Added' : 'Add',
                        style: TextStyle(
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }),
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
                        _buildPlainBullet('Bags provided at pickup'),
                        _buildPlainBullet('Discounted add-ons'),
                        _buildPlainBullet('Discounted bulky items'),
                        _buildPlainBullet('Concierge access'),
                        _buildPlainBullet('22×28" standard bag – typically 22–28 lb'),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          )),
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

