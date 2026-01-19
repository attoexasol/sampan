// lib/modules/laundry/widgets/order_summary_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../controller/order_summary_controller.dart';
import '../../../widgets/order_summary_card_widget.dart';

class OrderSummarySection extends StatelessWidget {
  const OrderSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Get.find<OrderSummaryController>();

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
            'Order Summary',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Obx(() {
            if (!orderCtrl.hasAnySelection) {
              return Padding(
                padding: EdgeInsets.only(top: AppSizes.xs),
                child: Text(
                  'Select your services above to see order details',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontStyle: FontStyle.italic,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
              );
            }

            return OrderSummaryCard(
              items: orderCtrl.items.values
                  .map((item) => item.toJson())
                  .toList(),
              subTotal: orderCtrl.subTotal,
              deliveryFee: orderCtrl.deliveryFee,
              tax: orderCtrl.tax,
              grandTotal: orderCtrl.grandTotal,
              showBorder: false,
            );
          }),
        ],
      ),
    );
  }
}
