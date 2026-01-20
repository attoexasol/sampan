// lib/screens/service_products_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../controller/products_controller.dart';
import '../controller/order_summary_controller.dart';
import '../data/service/products_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/common_specialty_service_view.dart';

class ServiceProductsScreen extends StatelessWidget {
  final ProductCategory category;

  const ServiceProductsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final productsCtrl = Get.find<ProductsController>();

    final orderCtrl = Get.isRegistered<OrderSummaryController>()
        ? Get.find<OrderSummaryController>()
        : Get.put(OrderSummaryController());

    final filteredProducts = productsCtrl.getProductsByCategory(category);

    if (category == ProductCategory.alterations) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CommonSpecialtyServiceView(
            serviceTitle: 'Alterations / Steaming / Shoe Care',
            estimatorHintText: 'Select your services above to see order details',
            orderSummaryEmptyText: 'Select your services above to see order summary',
            products: filteredProducts,
            orderController: orderCtrl,
          ),
        ),
      );
    }

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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}