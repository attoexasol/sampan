// lib/screens/service_products_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../controller/products_controller.dart';
import '../controller/order_summary_controller.dart';
import '../data/service/products_service.dart';
import '../models/product_model.dart';
import '../modules/schedule/schedule_binding.dart';
import '../modules/schedule/schedule_view.dart';
import '../widgets/header_widget.dart';
import '../widgets/order_summary_card_widget.dart';

class ServiceProductsScreen extends StatelessWidget {
  final ProductCategory category;

  const ServiceProductsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final productsCtrl = Get.find<ProductsController>();

    // ✅ Use findOrPut to ensure we get existing instance or create new one
    // This allows the controller to persist when navigating to ScheduleView
    final orderCtrl = Get.isRegistered<OrderSummaryController>()
        ? Get.find<OrderSummaryController>()
        : Get.put(OrderSummaryController());

    final filteredProducts = productsCtrl.getProductsByCategory(category);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Title
                    Text(
                      category.displayName,
                      style: GoogleFonts.outfit(
                        fontSize: AppSizes.fontXxl,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    SizedBox(height: AppSizes.sm),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    SizedBox(height: AppSizes.xl),

                    // Products List
                    if (filteredProducts.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.xl),
                          child: Text(
                            'No products available',
                            style: TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: AppSizes.fontLg,
                            ),
                          ),
                        ),
                      )
                    else
                      ...filteredProducts.map((product) =>
                          _buildProductCard(product, orderCtrl)),

                    SizedBox(height: AppSizes.xl),

                    // Order Summary
                    Obx(() {
                      if (!orderCtrl.hasAnySelection) {
                        return const EmptyOrderSummaryCard();
                      }
                      return OrderSummaryCard(
                        items: orderCtrl.items.values
                            .map((item) => item.toJson())
                            .toList(),
                        subTotal: orderCtrl.subTotal,
                        deliveryFee: orderCtrl.deliveryFee,
                        tax: orderCtrl.tax,
                        grandTotal: orderCtrl.grandTotal,
                      );
                    }),

                    SizedBox(height: AppSizes.xl),

                    // Action Buttons
                    _buildActionButtons(context, orderCtrl),

                    SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, OrderSummaryController orderCtrl) {
    return Obx(() {
      final qty = orderCtrl.getItemQty(product.id);

      return Container(
        margin: EdgeInsets.only(bottom: AppSizes.md),
        padding: EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: qty > 0 ? AppColors.primary : AppColors.border,
            width: qty > 0 ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image (if available)
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              Container(
                width: 60,
                height: 60,
                margin: EdgeInsets.only(right: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://cleancloudapp.com/uploads/${product.imageUrl}',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                margin: EdgeInsets.only(right: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  Icons.local_laundry_service,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              ),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w700,
                      color: AppColors.foreground,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  if (product.extraDays > 0)
                    Text(
                      '+${product.extraDays} days',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                ],
              ),
            ),

            // Quantity Controls
            Row(
              children: [
                IconButton(
                  onPressed: () => orderCtrl.decrementItem(product.id),
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: qty > 0 ? AppColors.primary : AppColors.mutedForeground,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: qty > 0
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.muted,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    '$qty',
                    style: TextStyle(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.bold,
                      color: qty > 0 ? AppColors.primary : AppColors.foreground,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => orderCtrl.incrementItem(
                    key: product.id,
                    title: product.name,
                    subtitle: '${product.pieces} piece(s)',
                    price: product.price,
                  ),
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButtons(BuildContext context, OrderSummaryController orderCtrl) {
    return Column(
      children: [
        // Back Button
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Back to Services'),
        ),

        SizedBox(height: AppSizes.sm),

        // Continue Button
        Obx(() => ElevatedButton(
          onPressed: orderCtrl.hasAnySelection
              ? () {
            Get.to(
                  () => const ScheduleView(),
              binding: ScheduleBinding(),
              arguments: {'orderSummary': orderCtrl.snapshot()},
            );
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
          child: const Text(
            'Continue to Schedule',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        )),
      ],
    );
  }
}