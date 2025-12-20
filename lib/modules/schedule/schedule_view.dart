import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../controller/order_summary_controller.dart';
import '../../widgets/order_summary_card_widget.dart';
import '../../widgets/header_widget.dart';
import '../login/login_binding.dart';
import '../login/login_view.dart';
import '../signup/signup_controller.dart';
import '../signup/signup_view.dart';
import 'schedule_controller.dart';
import '../../data/service/network_caller.dart';
import '../../data/service/local_store.dart';
import '../../data/service/utils.dart';

/// ✅ UPDATED: OrderSummaryCard now shows pickup/delivery date and time
class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderWidget(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSizes.lg),

                    // Title
                    Text(
                      'Schedule Your Service',
                      style: GoogleFonts.outfit(
                        fontSize: AppSizes.fontXxl,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    SizedBox(height: AppSizes.sm),
                    Text(
                      'Select pickup & delivery dates and times',
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    SizedBox(height: AppSizes.lg),

                    // Service Type Display (if available)
                    Obx(() {
                      final serviceType = controller.serviceType.value;
                      if (serviceType.isEmpty) return const SizedBox();

                      return Card(
                        color: const Color(0xFF2DD4BF).withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Color(0xFF2DD4BF)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Service: $serviceType',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: AppSizes.md),

                    // Schedule Card
                    _buildScheduleCard(context),
                    SizedBox(height: AppSizes.xl),

                    // Account Card
                    Center(
                      child: SizedBox(
                        width: AppSizes.screenWidth * .95,
                        child: _buildAccountCard(
                          onLogin: () {
                            Get.to(() => const LoginView(),
                                binding: LoginBinding());
                          },
                          onCreateAccount: () {
                            Get.put(SignupController());
                            Get.to(() => const SignupView());
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.xl),

                    // Order Summary Section
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Your Order Summary',
                        style: TextStyle(
                          fontSize: AppSizes.fontXl,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.lg),

                    Center(
                      child: Container(
                        width: AppSizes.screenWidth * .95,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        // ✅ UPDATED: Now shows pickup/delivery dates in OrderSummaryCard
                        child: _buildOrderSummarySection(),
                      ),
                    ),

                    SizedBox(height: AppSizes.xl),

                    // Confirm Schedule Button
                    _buildSubmitButton(context),
                    SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.lg),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.calendarDays,
                      color: AppColors.primary, size: AppSizes.iconMd),
                  SizedBox(width: AppSizes.sm),
                  Text(
                    'Schedule Dates',
                    style: TextStyle(
                      fontSize: AppSizes.fontXl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.lg),

              // Pickup Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pickup Date *',
                    style: TextStyle(
                        fontSize: AppSizes.fontMd, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Obx(() {
                    final pickupDate = controller.selectedPickupDate.value;
                    return OutlinedButton.icon(
                      onPressed: () => controller.selectPickupDate(context),
                      icon: Icon(Icons.calendar_today, size: AppSizes.iconSm),
                      label: Text(
                        pickupDate == null
                            ? 'Select date'
                            : DateFormat('MMMM d, yyyy').format(pickupDate),
                        style: TextStyle(fontSize: AppSizes.fontMd),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, AppSizes.xl),
                        alignment: Alignment.centerLeft,
                        side: BorderSide(color: AppColors.border),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: AppSizes.md),

              // Pickup Time Slots
              Obx(() {
                final pickupDate = controller.selectedPickupDate.value;
                if (pickupDate == null) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Time Slot *',
                      style: TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: AppSizes.sm),
                    ...controller.timeSlots.map(
                          (slot) => Obx(() => RadioListTile<String>(
                        title: Text(
                          slot,
                          style: TextStyle(fontSize: AppSizes.fontMd),
                        ),
                        value: slot,
                        groupValue: controller.selectedPickupTimeSlot.value,
                        onChanged: (v) {
                          controller.selectedPickupTimeSlot.value = v ?? '';
                        },
                        contentPadding: EdgeInsets.zero,
                      )),
                    ),
                  ],
                );
              }),
              SizedBox(height: AppSizes.lg),

              // Delivery Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Date *',
                    style: TextStyle(
                        fontSize: AppSizes.fontMd, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Obx(() {
                    final pickupDate = controller.selectedPickupDate.value;
                    final deliveryDate = controller.selectedDeliveryDate.value;

                    return OutlinedButton.icon(
                      onPressed: pickupDate != null
                          ? () => controller.selectDeliveryDate(context)
                          : null,
                      icon: Icon(Icons.calendar_today, size: AppSizes.iconSm),
                      label: Text(
                        deliveryDate == null
                            ? 'Select date'
                            : DateFormat('MMMM d, yyyy').format(deliveryDate),
                        style: TextStyle(fontSize: AppSizes.fontMd),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, AppSizes.xl),
                        alignment: Alignment.centerLeft,
                        side: BorderSide(color: AppColors.border),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: AppSizes.md),

              // Delivery Time Slots
              Obx(() {
                final deliveryDate = controller.selectedDeliveryDate.value;
                if (deliveryDate == null) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Time Slot *',
                      style: TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: AppSizes.sm),
                    ...controller.timeSlots.map(
                          (slot) => Obx(() {
                        final isAvailable =
                        controller.isDeliveryTimeSlotAvailable(slot);
                        return RadioListTile<String>(
                          title: Text(
                            slot,
                            style: TextStyle(
                              fontSize: AppSizes.fontMd,
                              color: isAvailable ? Colors.black : Colors.grey,
                            ),
                          ),
                          value: slot,
                          groupValue:
                          controller.selectedDeliveryTimeSlot.value,
                          onChanged: isAvailable
                              ? (v) {
                            controller.selectedDeliveryTimeSlot.value =
                                v ?? '';
                          }
                              : null,
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                    ),
                  ],
                );
              }),
              SizedBox(height: AppSizes.md),

              // Turnaround Note
              Obx(() {
                final pickupDate = controller.selectedPickupDate.value;
                if (pickupDate == null) return const SizedBox();

                return Container(
                  padding: EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        color: AppColors.mutedForeground,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Note: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                        ),
                        TextSpan(
                          text:
                          'Minimum turnaround: ${controller.getTurnaroundDays()} days',
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required VoidCallback onLogin,
    required VoidCallback onCreateAccount,
  }) {
    return _buildStandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.user,
                  color: AppColors.primary, size: AppSizes.iconLg),
              SizedBox(width: AppSizes.sm),
              Text(
                'Account',
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'Create an account or login to save your preferences and track your orders.',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onLogin,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: onCreateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  /// ✅ UPDATED: Handles order summary with pickup/delivery dates displayed in real-time
  Widget _buildOrderSummarySection() {
    return Obx(() {
      // Get pickup/delivery dates from controller (reactive)
      final pickupDate = controller.selectedPickupDate.value;
      final pickupTimeSlot = controller.selectedPickupTimeSlot.value;
      final deliveryDate = controller.selectedDeliveryDate.value;
      final deliveryTimeSlot = controller.selectedDeliveryTimeSlot.value;

      // Format dates for display
      final pickupDateStr = pickupDate != null
          ? DateFormat('MMMM d, yyyy').format(pickupDate)
          : null;
      final deliveryDateStr = deliveryDate != null
          ? DateFormat('MMMM d, yyyy').format(deliveryDate)
          : null;

      // First, try to get data from ScheduleController (passed via arguments)
      final orderData = controller.orderSummaryData;

      if (orderData.isNotEmpty) {
        final items = controller.orderItems;
        final totals = controller.orderTotals;

        if (items.isNotEmpty) {
          return OrderSummaryCard(
            items: items,
            subTotal: (totals['subTotal'] as num?)?.toDouble() ?? 0.0,
            deliveryFee: (totals['deliveryFee'] as num?)?.toDouble() ?? 0.0,
            tax: (totals['tax'] as num?)?.toDouble() ?? 0.0,
            grandTotal: (totals['grandTotal'] as num?)?.toDouble() ?? 0.0,
            showBorder: false,
            // ✅ NEW: Pass pickup/delivery info for display
            pickupDate: pickupDateStr,
            pickupTimeSlot: pickupTimeSlot.isNotEmpty ? pickupTimeSlot : null,
            deliveryDate: deliveryDateStr,
            deliveryTimeSlot: deliveryTimeSlot.isNotEmpty ? deliveryTimeSlot : null,
          );
        }
      }

      // Second, try to get data from OrderSummaryController if registered
      if (Get.isRegistered<OrderSummaryController>()) {
        try {
          final orderCtrl = Get.find<OrderSummaryController>();

          // Check if controller has any items
          if (orderCtrl.hasAnySelection) {
            return OrderSummaryCard(
              items: orderCtrl.items.values
                  .map((item) => item.toJson())
                  .toList(),
              subTotal: orderCtrl.subTotal,
              deliveryFee: orderCtrl.deliveryFee,
              tax: orderCtrl.tax,
              grandTotal: orderCtrl.grandTotal,
              showBorder: false,
              // ✅ NEW: Pass pickup/delivery info for display
              pickupDate: pickupDateStr,
              pickupTimeSlot: pickupTimeSlot.isNotEmpty ? pickupTimeSlot : null,
              deliveryDate: deliveryDateStr,
              deliveryTimeSlot: deliveryTimeSlot.isNotEmpty ? deliveryTimeSlot : null,
            );
          }
        } catch (e) {
          debugPrint('Warning: Error accessing OrderSummaryController: $e');
        }
      }

      // Third, show empty state
      return _buildEmptyOrderSummary();
    });
  }

  Widget _buildEmptyOrderSummary() {
    return _buildStandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: AppSizes.lg),
          Icon(LucideIcons.package, size: 50.w, color: Colors.grey.shade400),
          SizedBox(height: AppSizes.md),
          Text(
            'No items selected yet',
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'Start booking to see your order summary',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      // Check if there's any order data available
      bool hasOrderData = controller.orderSummaryData.isNotEmpty;

      if (!hasOrderData && Get.isRegistered<OrderSummaryController>()) {
        try {
          hasOrderData = Get.find<OrderSummaryController>().hasAnySelection;
        } catch (_) {}
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : (hasOrderData
              ? () => _showPaymentBottomSheet(context)
              : () => _navigateToBookScreen()),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            backgroundColor: hasOrderData ? AppColors.primary : Colors.grey.shade600,
            disabledBackgroundColor: Colors.grey.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
          child: isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!hasOrderData) ...[
                Icon(Icons.shopping_bag_outlined, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSizes.sm),
              ],
              Text(
                hasOrderData ? 'Continue to Pay' : 'Select Services First',
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              if (hasOrderData) ...[
                SizedBox(width: AppSizes.sm),
                Icon(Icons.arrow_forward, color: Colors.white, size: AppSizes.iconSm),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// Navigate to BookScreen (first tab in HomeScreen)
  void _navigateToBookScreen() {
    Get.offAllNamed('/');
  }

  /// Show Payment Bottom Sheet
  void _showPaymentBottomSheet(BuildContext context) {
    // Get order totals
    double grandTotal = 0.0;

    if (controller.orderSummaryData.isNotEmpty) {
      grandTotal = controller.grandTotal;
    } else if (Get.isRegistered<OrderSummaryController>()) {
      try {
        grandTotal = Get.find<OrderSummaryController>().grandTotal;
      } catch (_) {}
    }

    // Get pickup/delivery dates
    final pickupDate = controller.selectedPickupDate.value;
    final pickupTimeSlot = controller.selectedPickupTimeSlot.value;
    final deliveryDate = controller.selectedDeliveryDate.value;
    final deliveryTimeSlot = controller.selectedDeliveryTimeSlot.value;

    final pickupDateStr = pickupDate != null
        ? DateFormat('MMMM d, yyyy').format(pickupDate)
        : 'Not selected';
    final deliveryDateStr = deliveryDate != null
        ? DateFormat('MMMM d, yyyy').format(deliveryDate)
        : 'Not selected';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentBottomSheetContent(
        grandTotal: grandTotal,
        pickupDateStr: pickupDateStr,
        pickupTimeSlot: pickupTimeSlot,
        deliveryDateStr: deliveryDateStr,
        deliveryTimeSlot: deliveryTimeSlot,
        controller: controller,
      ),
    );
  }

  /// Build Payment Option Tile
  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLighter : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: AppSizes.iconMd,
              ),
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: AppSizes.iconMd),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.all(AppSizes.sm),
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Payment Bottom Sheet Content with Stripe Integration
class _PaymentBottomSheetContent extends StatefulWidget {
  final double grandTotal;
  final String pickupDateStr;
  final String pickupTimeSlot;
  final String deliveryDateStr;
  final String deliveryTimeSlot;
  final ScheduleController controller;

  const _PaymentBottomSheetContent({
    required this.grandTotal,
    required this.pickupDateStr,
    required this.pickupTimeSlot,
    required this.deliveryDateStr,
    required this.deliveryTimeSlot,
    required this.controller,
  });

  @override
  State<_PaymentBottomSheetContent> createState() => _PaymentBottomSheetContentState();
}

class _PaymentBottomSheetContentState extends State<_PaymentBottomSheetContent> {
  bool _isProcessingPayment = false;
  CardFieldInputDetails? _cardFieldDetails;
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusLg),
            topRight: Radius.circular(AppSizes.radiusLg),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: AppSizes.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Complete Payment',
                      style: TextStyle(
                        fontSize: AppSizes.fontXxl,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    SizedBox(height: AppSizes.sm),
                    Text(
                      'Review your order and complete payment',
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    SizedBox(height: AppSizes.xl),

                    // Schedule Summary
                    Container(
                      padding: EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.truck,
                                  size: AppSizes.iconSm, color: AppColors.primary),
                              SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pickup',
                                      style: TextStyle(
                                        fontSize: AppSizes.fontSm,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                    Text(
                                    '${widget.pickupDateStr}${widget.pickupTimeSlot.isNotEmpty ? ' • ${widget.pickupTimeSlot}' : ''}',
                                      style: TextStyle(
                                        fontSize: AppSizes.fontMd,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                            child: Divider(color: AppColors.border),
                          ),
                          Row(
                            children: [
                              Icon(LucideIcons.home,
                                  size: AppSizes.iconSm, color: Colors.green),
                              SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Delivery',
                                      style: TextStyle(
                                        fontSize: AppSizes.fontSm,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                    Text(
                                    '${widget.deliveryDateStr}${widget.deliveryTimeSlot.isNotEmpty ? ' • ${widget.deliveryTimeSlot}' : ''}',
                                      style: TextStyle(
                                        fontSize: AppSizes.fontMd,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.lg),

                    // Total Amount
                    Container(
                      padding: EdgeInsets.all(AppSizes.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: AppSizes.fontLg,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground,
                            ),
                          ),
                          Text(
                          '\$${widget.grandTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: AppSizes.fontXxl,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.xl),

                    // Stripe Card Field
                    Container(
                      padding: EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.credit_card, 
                                  color: AppColors.primary, 
                                  size: AppSizes.iconMd),
                              SizedBox(width: AppSizes.sm),
                              Text(
                                'Card Details',
                                style: TextStyle(
                                  fontSize: AppSizes.fontMd,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foreground,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizes.lg),
                          
                          // Stripe CardField - handles all card input securely
                          CardField(
                            onCardChanged: (cardFieldInputDetails) {
                              setState(() {
                                _cardFieldDetails = cardFieldInputDetails;
                              });
                            },
                            enablePostalCode: false,
                            style: TextStyle(
                              fontSize: AppSizes.fontMd,
                              color: AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.xl),

                    // Secure Payment Note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Secured by Stripe',
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Pay Now Button
            Container(
              padding: EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isProcessingPayment || 
                                _cardFieldDetails == null || 
                                !_cardFieldDetails!.complete) 
                        ? null 
                        : _handlePayment,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: _isProcessingPayment
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Pay \$${widget.grandTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: AppSizes.fontLg,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    // Validate card field is complete
    if (_cardFieldDetails == null || !_cardFieldDetails!.complete) {
      Get.snackbar(
        'Error',
        'Please enter complete card details',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Get customer ID - try multiple methods
      String? customerId = await LocalStore.instance.getCustomerId();
      debugPrint('🔍 Payment: Retrieved customer ID from getCustomerId(): $customerId');
      
      // If not found, try to get from last API response
      if (customerId == null || customerId.isEmpty) {
        final lastResponse = await LocalStore.instance.getLastApiResponse();
        debugPrint('🔍 Payment: Last API response: $lastResponse');
        
        if (lastResponse != null) {
          debugPrint('🔍 Payment: Last API response keys: ${lastResponse.keys.toList()}');
          
          // Try comprehensive key search (same as saveCustomerIdFromResponse)
          final keysToTry = [
            'CustomerID', 'customerID', 'customer_id', 'customerId', 'CustomerId',
            'cid', 'CID', 'Cid',
            'id', 'ID', 'Id',
            'customerID', 'Customer_ID',
          ];
          
          for (final key in keysToTry) {
            if (lastResponse.containsKey(key) && lastResponse[key] != null) {
              final value = lastResponse[key];
              if (value is String && value.isNotEmpty) {
                customerId = value.trim();
                debugPrint('🔍 Payment: Found customer ID (string) in response with key "$key": $customerId');
                break;
              } else if (value is num) {
                customerId = value.toString().trim();
                debugPrint('🔍 Payment: Found customer ID (numeric) in response with key "$key": $customerId');
                break;
              } else if (value != null) {
                final strValue = value.toString().trim();
                if (strValue.isNotEmpty) {
                  customerId = strValue;
                  debugPrint('🔍 Payment: Found customer ID (converted) in response with key "$key": $customerId');
                  break;
                }
              }
            }
          }
          
          // If still not found, try case-insensitive search
          if (customerId == null || customerId.isEmpty) {
            for (final responseKey in lastResponse.keys) {
              final lowerKey = responseKey.toString().toLowerCase();
              if (lowerKey.contains('customer') && lowerKey.contains('id')) {
                final value = lastResponse[responseKey];
                if (value != null) {
                  if (value is String && value.isNotEmpty) {
                    customerId = value.trim();
                    debugPrint('🔍 Payment: Found customer ID (case-insensitive) with key "$responseKey": $customerId');
                    break;
                  } else if (value is num) {
                    customerId = value.toString().trim();
                    debugPrint('🔍 Payment: Found customer ID (case-insensitive, numeric) with key "$responseKey": $customerId');
                    break;
                  }
                }
              }
            }
          }
          
          // Save it for future use if found
          if (customerId != null && customerId.isNotEmpty) {
            await LocalStore.instance.saveCustomerId(customerId);
            debugPrint('✅ Payment: Customer ID saved for future use: $customerId');
          }
        }
      }
      
      // Final check
      if (customerId == null || customerId.isEmpty) {
        // Check if user is logged in
        final isLoggedIn = await LocalStore.instance.isLoggedIn();
        debugPrint('🔍 Payment: Is logged in: $isLoggedIn');
        
        if (!isLoggedIn) {
          throw Exception('Please login first');
        } else {
          // User is logged in but customer ID is missing
          throw Exception('Customer ID not found. Please login again.');
        }
      }
      
      debugPrint('✅ Payment: Using customer ID: $customerId');

      // Convert amount to cents (Stripe uses cents)
      final amountInCents = (widget.grandTotal * 100).toInt();

      // 1. Create PaymentIntent
      final paymentIntentResponse = await NetworkCaller.postRequest(
        url: Urls.StripePayment,
        body: {
          'amount': amountInCents,
          'customerID': int.tryParse(customerId) ?? 0,
        },
      );

      if (!paymentIntentResponse.isSuccess || paymentIntentResponse.body == null) {
        throw Exception(
          paymentIntentResponse.errorMessage ?? 'Failed to create payment intent',
        );
      }

      // Extract clientSecret from response
      final clientSecret = paymentIntentResponse.body!['clientSecret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Client secret not found in response');
      }

      // 2. Confirm payment with Stripe using CardField
      // CardField automatically handles card data securely - no manual card data handling needed
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // 3. Check payment status
      final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
      
      final status = paymentIntent.status.toString().toLowerCase();
      if (status.contains('succeeded')) {
        // Payment successful
        if (mounted) {
          Navigator.pop(context);
        }
        Get.snackbar(
          'Success',
          'Payment completed successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else if (status.contains('requiresaction') || status.contains('requires_action')) {
        // Payment requires additional action (3D Secure, etc.)
        if (mounted) {
          Navigator.pop(context);
        }
        Get.snackbar(
          'Pending',
          'Payment is being processed. Please complete any additional verification.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } else if (status.contains('requirespaymentmethod') || status.contains('requires_payment_method')) {
        // Payment failed - card was declined
        throw Exception('Payment failed. Please try a different payment method.');
      } else {
        // Other status (processing, canceled, etc.)
        throw Exception('Payment status: $status');
      }
    } on StripeException catch (e) {
      // Stripe-specific errors
      final errorMessage = e.error?.message ?? 'Payment failed. Please try again.';
      Get.snackbar(
        'Payment Failed',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      // General errors
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }
}
