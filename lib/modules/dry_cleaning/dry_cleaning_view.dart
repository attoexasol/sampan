import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../modules/schedule/schedule_binding.dart';
import '../../modules/schedule/schedule_view.dart';
import '../../widgets/header_widget.dart';
import 'dry_cleaning_controller.dart';
import 'widgets/disclaimers_card.dart';
import 'widgets/estimator_card.dart';
import 'widgets/how_it_works_card.dart';
import 'widgets/order_summary_card.dart';
import 'widgets/pricing_info_card.dart';
import 'widgets/rush_service_card.dart';
import 'widgets/schedule_delivery_card.dart';
import 'widgets/services_section.dart';
import 'widgets/special_instructions_card.dart';
import 'widgets/upcharge_menu_card.dart';

class DryCleaningView extends StatelessWidget {
  const DryCleaningView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DryCleaningController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
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
                        const DryCleaningHowItWorksCard(),
                        SizedBox(height: AppSizes.md),
                        const DryCleaningServicesSection(),
                        SizedBox(height: AppSizes.md),
                        const RushServiceCard(),
                        SizedBox(height: AppSizes.md),
                        const EstimatorCard(),
                        SizedBox(height: AppSizes.md),
                        const DryCleaningSpecialInstructionsCard(),
                        SizedBox(height: AppSizes.md),
                        const DryCleaningOrderSummaryCard(),
                        SizedBox(height: AppSizes.lg),
                        _buildActionButtons(controller),
                        SizedBox(height: AppSizes.lg),
                        const ScheduleDeliveryCard(),
                        SizedBox(height: AppSizes.md),
                        const PricingInfoCard(),
                        SizedBox(height: AppSizes.md),
                        const UpchargeMenuCard(),
                        SizedBox(height: AppSizes.md),
                        const DisclaimersCard(),
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

  Widget _buildActionButtons(DryCleaningController controller) {
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
