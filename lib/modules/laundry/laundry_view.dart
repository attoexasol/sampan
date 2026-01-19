// lib/modules/laundry/laundry_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../modules/schedule/schedule_binding.dart';
import '../../modules/schedule/schedule_view.dart';
import '../../widgets/header_widget.dart';
import 'laundry_controller.dart';
import 'widgets/bulky_items_section.dart';
import 'widgets/express_service_card.dart';
import 'widgets/how_it_works_card.dart';
import 'widgets/how_we_care_card.dart';
import 'widgets/more_about_services_card.dart';
import 'widgets/order_summary_section.dart';
import 'widgets/pay_as_you_go_card.dart';
import 'widgets/premium_bag_card.dart';
import 'widgets/special_instructions_card.dart';
import 'widgets/subscription_card.dart';

class LaundryView extends StatelessWidget {
  const LaundryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LaundryController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                image: DecorationImage(
                  image: AssetImage('assets/images/laundry-background-pattern.png'),
                  repeat: ImageRepeat.repeat,
                  fit: BoxFit.none,
                  opacity: 0.06,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const HeaderWidget(),
                  Padding(
                    padding: EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Laundry How It Works
                        const HowItWorksCard(),
                        SizedBox(height: AppSizes.md),

                        // 2. Premium Bag Service
                        const PremiumBagCard(),
                        SizedBox(height: AppSizes.md),

                        // 3. Subscriptions
                        const SubscriptionCard(),
                        SizedBox(height: AppSizes.md),

                        // 4. Pay As You Go
                        const PayAsYouGoCard(),
                        SizedBox(height: AppSizes.md),

                        // 5. Bulky Items (API-driven)
                        const BulkyItemsSection(),
                        SizedBox(height: AppSizes.md),

                        // 6. Express Service (Want It Sooner)
                        const ExpressServiceCard(),
                        SizedBox(height: AppSizes.md),

                        // 7. Special Instructions
                        Obx(() => SpecialInstructionsCard(
                          controller: controller.specialInstructionsController,
                          saveForFuture: controller.saveForFutureOrders.value,
                          onSaveForFutureChanged: (value) {
                            controller.saveForFutureOrders.value = value;
                          },
                        )),
                        SizedBox(height: AppSizes.md),

                        // 8. Order Summary
                        const OrderSummarySection(),
                        SizedBox(height: AppSizes.lg),

                        // Action Buttons
                        _buildActionButtons(controller),
                        SizedBox(height: AppSizes.lg),

                        // 9. How We Care For Your Clothes
                        const HowWeCareCard(),
                        SizedBox(height: AppSizes.md),

                        // 10. More About Our Services
                        const MoreAboutServicesCard(),
                        SizedBox(height: AppSizes.xl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(LaundryController controller) {
    return Column(
      children: [
        // Back Button
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.border),
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, size: 18, color: AppColors.foreground),
              SizedBox(width: AppSizes.xs),
              const Text('Back to Other Services'),
            ],
          ),
        ),
        SizedBox(height: AppSizes.sm),

        // Continue Button
        Obx(() => ElevatedButton(
          onPressed: controller.hasAnySelection
              ? () {
                  Get.to(
                    () => const ScheduleView(),
                    binding: ScheduleBinding(),
                    arguments: {
                      'orderSummary': controller.getOrderSummarySnapshot(),
                    },
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.muted,
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Continue to Schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Icon(Icons.arrow_forward, size: 18, color: Colors.white),
            ],
          ),
        )),
      ],
    );
  }
}
