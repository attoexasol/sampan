// lib/modules/laundry/widgets/subscription_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../data/service/utils.dart';
import '../laundry_controller.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LaundryController>();
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
                'Subscriptions',
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
            'A predictable laundry bill, 24-hour freshness — subscription simplicity meets spotless results.',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.foreground,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSizes.md),
          _buildBullet('One bag for everything — linens, delicates, all items.'),
          _buildBullet('Huge savings!'),
          _buildStrikethroughBullet('\$10.99', 'Free Pickup & Delivery'),
          _buildBullet('Unlimited rollover of bag credits'),
          SizedBox(height: AppSizes.lg),
          _buildDreamBigPlanBlock(context, controller),
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
                        _buildPlainBullet('Free up your time for bigger things'),
                        _buildPlainBullet('24 hour turnaround'),
                        _buildPlainBullet('Bags provided at pickup'),
                        _buildPlainBullet('Priority Pickup & Delivery Windows'),
                        _buildPlainBullet('Discounted add-ons'),
                        _buildPlainBullet('Discounted bulky items'),
                        _buildPlainBullet('Cancel anytime (30-day)'),
                        _buildPlainBullet('Easy Budgeting'),
                        _buildPlainBullet('Delicates processed gently if you separate'),
                        _buildPlainBullet('22×28" standard bag — typically 22–28 lb'),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          )),
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

  /// Dream Big plan block: Obx wraps the entire plan so button text is derived from reactive state.
  /// Tapping "Add" simply toggles the plan as a line item in the Order Summary
  /// (compounds with Bulky Items). Login / payment are deferred to the global
  /// "Continue to Pay" checkout step.
  Widget _buildDreamBigPlanBlock(BuildContext context, LaundryController controller) {
    return Obx(() {
      final subState = controller.dreamBigSubscription.value;
      final processing = controller.isSubscriptionProcessing.value;
      final isActive = subState != null &&
          subState.isActive &&
          subState.activatedAt != null &&
          subState.expiresAt != null &&
          !DateTime.now().isAfter(subState.expiresAt!);
      // Track summary membership reactively
      final inSummary = controller.orderCtrl.items.containsKey('dream_big_plan');
      final String buttonText;
      if (isActive) {
        buttonText = 'Active';
      } else if (inSummary) {
        buttonText = 'Added';
      } else {
        buttonText = 'Add';
      }
      return _buildSubscriptionPlan(
        buttonText: buttonText,
        isActive: isActive,
        isLoading: processing,
        onTap: () => _onDreamBigPlanTap(context, controller, isActive),
      );
    });
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Tap "Add" / "Added": toggle the Dream Big Plan as a line item in the
  /// Order Summary (no login/payment required here — those are enforced at
  /// the global "Continue to Pay" checkout step).
  /// If the plan is already active (paid), just show an info snackbar.
  Future<void> _onDreamBigPlanTap(
    BuildContext context,
    LaundryController controller,
    bool isActive,
  ) async {
    if (controller.isSubscriptionProcessing.value) return;
    if (isActive) {
      final state = controller.dreamBigSubscription.value;
      final dateStr = state?.expiresAt != null
          ? DateFormat.yMMMd().format(state!.expiresAt!)
          : '—';
      _showSnackBar(
        context,
        'Your Dream Big Plan is already active until $dateStr.',
        isError: false,
      );
      return;
    }
    controller.toggleDreamBigPlanInSummary();
  }

  Widget _buildSubscriptionPlan({
    required String buttonText,
    required bool isActive,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(bottom: AppSizes.xs),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'MOST POPULAR',
                        style: TextStyle(
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Dream Big Plan – \$${SubscriptionConfig.dreamBigPlanPrice.toStringAsFixed(0)} per bag',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '4 bags per month',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.mutedForeground,
                ),
              ),
              SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: AppSizes.fontSm,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
