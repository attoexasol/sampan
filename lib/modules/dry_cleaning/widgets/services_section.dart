import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../models/product_model.dart';
import '../dry_cleaning_controller.dart';

class DryCleaningServicesSection extends StatelessWidget {
  const DryCleaningServicesSection({super.key});

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
            'Dry Cleaning',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Professional and formal wear',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Obx(() {
            if (controller.isLoadingServices.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.xl),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            if (controller.services.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.xl),
                  child: Text(
                    'No services available',
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: AppSizes.fontMd,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: controller.services.map((product) {
                return _buildServiceCard(controller, product);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildServiceCard(DryCleaningController controller, Product product) {
    return Obx(() {
      final qty = controller.getServiceQuantity(product.id);

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
                  if (product.pieces > 1) ...[
                    SizedBox(height: 4),
                    Text(
                      '${product.pieces} piece(s)',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
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
                  onTap: () => controller.decrementService(product),
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
                  onTap: () => controller.incrementService(product),
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
