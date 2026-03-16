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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/placeholder.png'),
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const HeaderWidget(),
                    Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HowItWorksCard(),
                          SizedBox(height: AppSizes.md),
                          const PremiumBagCard(),
                          SizedBox(height: AppSizes.md),
                          const SubscriptionCard(),
                          SizedBox(height: AppSizes.md),
                          // --- PAY AS YOU GO SECTION (DISABLED) START ---
                          // SizedBox(height: AppSizes.md),
                          // const PayAsYouGoCard(),
                          // SizedBox(height: AppSizes.md),
                          // --- PAY AS YOU GO SECTION (DISABLED) END ---
                          SizedBox(height: AppSizes.md),
                          const BulkyItemsSection(),
                          SizedBox(height: AppSizes.md),
                          const ExpressServiceCard(),
                          SizedBox(height: AppSizes.md),
                          Obx(() => SpecialInstructionsCard(
                            controller: controller.specialInstructionsController,
                            saveForFuture: controller.saveForFutureOrders.value,
                            onSaveForFutureChanged: (value) {
                              controller.saveForFutureOrders.value = value;
                            },
                          )),
                          SizedBox(height: AppSizes.md),
                          const OrderSummarySection(),
                          SizedBox(height: AppSizes.lg),
                          _buildActionButtons(controller),
                          SizedBox(height: AppSizes.lg),
                          const HowWeCareCard(),
                          SizedBox(height: AppSizes.md),
                          const MoreAboutServicesCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/placeholder.png',
                width: screenWidth,
                fit: BoxFit.fitWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(LaundryController controller) {
    return Column(
      children: [
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
        Obx(() => ElevatedButton(
          onPressed: controller.hasAnySelection
              ? () {
                  Get.to(
                    () => const ScheduleView(),
                    binding: ScheduleBinding(),
                    arguments: {
                      'serviceType': 'laundry',
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
