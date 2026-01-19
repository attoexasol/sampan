// lib/modules/laundry/widgets/bulky_items_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../models/product_model.dart';
import '../laundry_controller.dart';

class BulkyItemsSection extends StatelessWidget {
  const BulkyItemsSection({super.key});

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
                'Bulky Items',
                style: GoogleFonts.outfit(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                '(per piece)',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'We clean all types of bulky items. Prices are per item and include wash, dry & fold.',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Obx(() {
            if (controller.isLoadingBulkyItems.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.xl),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            if (controller.bulkyItems.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.xl),
                  child: Text(
                    'No bulky items available',
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: AppSizes.fontMd,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: controller.bulkyItems.map((product) {
                return _buildBulkyItemCard(controller, product);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBulkyItemCard(LaundryController controller, Product product) {
    return Obx(() {
      final qty = controller.getBulkyItemQuantity(product.id);

      return Container(
        margin: EdgeInsets.only(bottom: AppSizes.md),
        padding: EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w700,
                      color: AppColors.foreground,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () => controller.decrementBulkyItem(product),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: qty > 0 ? AppColors.primary : AppColors.muted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.remove,
                      color: qty > 0 ? Colors.white : AppColors.mutedForeground,
                      size: 20,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$qty',
                    style: TextStyle(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.bold,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => controller.incrementBulkyItem(product),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
