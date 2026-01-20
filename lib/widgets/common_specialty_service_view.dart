import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../controller/order_summary_controller.dart';
import '../models/product_model.dart';
import '../modules/schedule/schedule_binding.dart';
import '../modules/schedule/schedule_view.dart';
import '../widgets/order_summary_card_widget.dart';
import '../widgets/header_widget.dart';
import '../widgets/specialty_how_it_works_card.dart';
import 'specialty_estimator_card.dart';
import 'specialty_rush_service_card.dart';
import 'specialty_special_instructions_card.dart';
import 'specialty_schedule_delivery_card.dart';
import 'specialty_disclaimers_card.dart';

class CommonSpecialtyServiceView extends StatelessWidget {
  final String serviceTitle;
  final String? serviceSubtitle;
  final String estimatorHintText;
  final String orderSummaryEmptyText;
  final List<Product> products;
  final OrderSummaryController orderController;

  const CommonSpecialtyServiceView({
    super.key,
    required this.serviceTitle,
    this.serviceSubtitle,
    required this.estimatorHintText,
    required this.orderSummaryEmptyText,
    required this.products,
    required this.orderController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderWidget(subtitle: 'Alterations / Steaming / Shoe Care'),
          Padding(
            padding: EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SpecialtyHowItWorksCard(),
          SizedBox(height: AppSizes.xl),

          if (products.isEmpty)
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
            ...products.map((product) => _buildProductCard(product, orderController)),

          SizedBox(height: AppSizes.xl),

          const SpecialtyRushServiceCard(),
          SizedBox(height: AppSizes.md),

          SpecialtyEstimatorCard(hintText: estimatorHintText),
          SizedBox(height: AppSizes.md),

          const SpecialtySpecialInstructionsCard(),
          SizedBox(height: AppSizes.md),

          Obx(() {
            if (!orderController.hasAnySelection) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  orderSummaryEmptyText,
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
              );
            }
            return OrderSummaryCard(
              items: orderController.items.values
                  .map((item) => item.toJson())
                  .toList(),
              subTotal: orderController.subTotal,
              deliveryFee: orderController.deliveryFee,
              tax: orderController.tax,
              grandTotal: orderController.grandTotal,
            );
          }),

          SizedBox(height: AppSizes.lg),

          _buildActionButtons(orderController),

          SizedBox(height: AppSizes.lg),

          const SpecialtyScheduleDeliveryCard(),
          SizedBox(height: AppSizes.md),

                const SpecialtyDisclaimersCard(),
              ],
            ),
          ),
        ],
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

  Widget _buildActionButtons(OrderSummaryController orderCtrl) {
    return Column(
      children: [
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Back to Other Services'),
        ),
        SizedBox(height: AppSizes.sm),
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
