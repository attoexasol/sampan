import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
import '../../data/service/customer_session_helper.dart';
import '../../data/service/utils.dart';
import '../../data/service/express_delivery_service.dart';
import '../../data/service/rush_order_service.dart';

/// ✅ UPDATED: OrderSummaryCard now shows pickup/delivery date and time
class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSizes.lg),

                    // Title
                    Text(
                      'Schedule Your Service',
                          style: TextStyle(
                            fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    SizedBox(height: AppSizes.sm),
                    Text(
                          'Choose your pickup and delivery times, enter your address, and create an account to complete your booking.',
                      style: TextStyle(
                            fontSize: 14,
                        color: AppColors.mutedForeground,
                            height: 1.5,
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
                        _buildAccountCard(
                          onLogin: () {
                            Get.to(() => const LoginView(),
                                binding: LoginBinding());
                          },
                          onCreateAccount: () {
                            Get.put(SignupController());
                            Get.to(() => const SignupView());
                          },
                    ),
                    SizedBox(height: AppSizes.xl),

                    // Order Summary Section
                        Text(
                        'Your Order Summary',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                      ),
                    ),
                    SizedBox(height: AppSizes.lg),

                        // ✅ UPDATED: Now shows pickup/delivery dates in OrderSummaryCard
                        _buildOrderSummarySection(),

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
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time,
                      color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Schedule Dates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pickup Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pickup Date *',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final pickupDate = controller.selectedPickupDate.value;
                    return OutlinedButton.icon(
                      onPressed: () => controller.selectPickupDate(context),
                      icon: Icon(Icons.calendar_today, size: 20),
                      label: Text(
                        pickupDate == null
                            ? 'Select pickup date'
                            : DateFormat('MMMM d, yyyy').format(pickupDate),
                        style: TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        alignment: Alignment.centerLeft,
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // Pickup Time Slots
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Time Slot *',
                      style: TextStyle(
                        fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 12),
                    ...controller.timeSlots.map(
                          (slot) => Obx(() => RadioListTile<String>(
                        title: Text(
                          slot,
                        style: TextStyle(fontSize: 14),
                        ),
                        value: slot,
                        groupValue: controller.selectedPickupTimeSlot.value,
                        onChanged: (v) {
                          controller.setPickupTimeSlot(v ?? '');
                        },
                        contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      activeColor: AppColors.primary,
                      selectedTileColor: Colors.transparent,
                      )),
                    ),
                  ],
              ),
              const SizedBox(height: 20),

              // Delivery Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Date *',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final pickupDate = controller.selectedPickupDate.value;
                    final deliveryDate = controller.selectedDeliveryDate.value;

                    return OutlinedButton.icon(
                      onPressed: pickupDate != null
                          ? () => controller.selectDeliveryDate(context)
                          : null,
                      icon: Icon(Icons.calendar_today, size: 20),
                      label: Text(
                        deliveryDate == null
                            ? 'Select delivery date'
                            : DateFormat('MMMM d, yyyy').format(deliveryDate),
                        style: TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        alignment: Alignment.centerLeft,
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // Delivery Time Slots - wrapped in Obx to ensure reactive rebuilds
              Obx(() {
                // Force reactive dependency on all relevant values
                final pickupDate = controller.selectedPickupDate.value;
                final pickupSlot = controller.selectedPickupTimeSlot.value;
                final deliveryDate = controller.selectedDeliveryDate.value;
                final selectedDeliverySlot = controller.selectedDeliveryTimeSlot.value;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Time Slot *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    ...controller.timeSlots.map((slot) {
                      final isAvailable = controller.isDeliveryTimeSlotAvailable(slot);
                      final isSelected = selectedDeliverySlot == slot;
                      final supportsRush = RushOrderService.instance.supportsRush(controller.rushServiceType.value);
                      final isRushSlot = supportsRush && isAvailable && controller.isDeliverySlotRush(slot);
                      final wouldBeExpress = !isRushSlot && isAvailable &&
                          pickupDate != null && deliveryDate != null && pickupSlot.isNotEmpty &&
                          ExpressDeliveryService.instance.checkExpressDelivery(
                            pickupDate: pickupDate,
                            pickupTimeSlot: pickupSlot,
                            deliveryDate: deliveryDate,
                            deliveryTimeSlot: slot,
                          ).isExpress;
                      final showThunder = isRushSlot || wouldBeExpress;
                      final labelRush = isRushSlot;

                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    slot,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isAvailable 
                                          ? (isSelected ? AppColors.primary : Colors.black)
                                          : Colors.grey,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  if (isAvailable && showThunder) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.bolt,
                                      size: 18,
                                      color: isSelected 
                                          ? Colors.orange.shade800 
                                          : Colors.orange.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      labelRush ? 'Rush' : 'Express',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected 
                                            ? Colors.orange.shade800 
                                            : Colors.orange.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (!isAvailable)
                              Text(
                                '(min 4h gap)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red.shade400,
                                ),
                              ),
                          ],
                        ),
                        value: slot,
                        groupValue: selectedDeliverySlot,
                        onChanged: isAvailable
                            ? (v) => controller.setDeliveryTimeSlot(v ?? '')
                            : null,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        activeColor: AppColors.primary,
                        selectedTileColor: Colors.transparent,
                      );
                    }),
                  ],
                );
              }),
              const SizedBox(height: 16),

              // Turnaround Note
              Text(
                'Note: You can schedule up to 2 weeks in advance. Turnaround times vary by service type.',
                      style: TextStyle(
                  fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
              ),
              
              // Rush / Express Delivery Indicator
              Obx(() {
                if (controller.selectedDeliveryTimeSlot.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                final isRush = controller.isRushDelivery.value;
                final isExpress = controller.isExpressDelivery.value;
                final duration = controller.deliveryDurationHours.value;
                final rushType = controller.rushServiceType.value;

                if (isRush && duration != null) {
                  final label = RushOrderService.instance.rushLabelFor(rushType);
                  final message = rushType == RushServiceType.laundry
                      ? RushOrderService.instance.laundryRushMessage
                      : RushOrderService.instance.dryCleaningRushMessage;
                  return Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade50, Colors.amber.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade400, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.bolt, color: Colors.orange.shade700, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⚡ $label',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${duration.toStringAsFixed(0)}h turnaround • $message',
                                    style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (rushType == RushServiceType.dryCleaning) ...[
                          const SizedBox(height: 10),
                          Text(
                            RushOrderService.instance.dryCleaningRushNote,
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                if (isExpress && duration != null) {
                  return Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade50, Colors.amber.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade400, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.bolt, color: Colors.orange.shade700, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚡ Express Delivery',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${duration.toStringAsFixed(0)}h turnaround • 5% express fee applies',
                                style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                Icon(Icons.person_outline,
                    color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
              Text(
                'Account',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                ),
              ),
            ],
          ),
            const SizedBox(height: 12),
          Text(
            'Create an account or login to save your preferences and track your orders.',
            style: TextStyle(
                fontSize: 14,
              color: AppColors.mutedForeground,
                height: 1.5,
            ),
          ),
            const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onLogin,
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foreground,
                    ),
                  ),
                ),
              ),
                const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onCreateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
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

      OrderSummaryController? orderCtrl;
      if (Get.isRegistered<OrderSummaryController>()) {
        try {
          orderCtrl = Get.find<OrderSummaryController>();
        } catch (_) {
          orderCtrl = null;
        }
      }
      final useOrderCtrl = orderCtrl != null && orderCtrl!.hasAnySelection;

      if (useOrderCtrl) {
        return OrderSummaryCard(
          items: orderCtrl!.items.values.map((e) => e.toJson()).toList(),
          subTotal: orderCtrl.subTotal,
          deliveryFee: orderCtrl.deliveryFee,
          expressFee: orderCtrl.expressFee,
          isExpressDelivery: orderCtrl.isExpressDelivery.value,
          isRushDelivery: orderCtrl.isRushDelivery.value,
          tax: orderCtrl.tax,
          grandTotal: orderCtrl.grandTotal,
          showBorder: false,
          pickupDate: pickupDateStr,
          pickupTimeSlot: pickupTimeSlot.isNotEmpty ? pickupTimeSlot : null,
          deliveryDate: deliveryDateStr,
          deliveryTimeSlot: deliveryTimeSlot.isNotEmpty ? deliveryTimeSlot : null,
        );
      }

      if (orderData.isNotEmpty) {
        final items = controller.orderItems;
        final totals = controller.orderTotals;
        if (items.isNotEmpty) {
          return OrderSummaryCard(
            items: items,
            subTotal: (totals['subTotal'] as num?)?.toDouble() ?? 0.0,
            deliveryFee: (totals['deliveryFee'] as num?)?.toDouble() ?? 0.0,
            expressFee: controller.expressFee,
            isExpressDelivery: controller.isExpressDelivery.value,
            isRushDelivery: controller.isRushDelivery.value,
            tax: (totals['tax'] as num?)?.toDouble() ?? 0.0,
            grandTotal: controller.grandTotal,
            showBorder: false,
            pickupDate: pickupDateStr,
            pickupTimeSlot: pickupTimeSlot.isNotEmpty ? pickupTimeSlot : null,
            deliveryDate: deliveryDateStr,
            deliveryTimeSlot: deliveryTimeSlot.isNotEmpty ? deliveryTimeSlot : null,
          );
        }
      }

      // Third, show empty state
      return _buildEmptyOrderSummary();
    });
  }

  Widget _buildEmptyOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
          Text(
            'No items selected yet',
            style: TextStyle(
                fontSize: 16,
              fontWeight: FontWeight.w600,
                color: AppColors.mutedForeground,
            ),
          ),
            const SizedBox(height: 8),
          Text(
            'Start booking to see your order summary',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
            ),
          ),
        ],
        ),
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
  Future<void> _showPaymentBottomSheet(BuildContext context) async {
    // Require a valid customer session before opening the payment sheet.
    // Shows snackbar "Please Login / SignUp" and redirects to SignupView when missing.
    final cid =
        await CustomerSessionHelper.requireCustomerIdOrRedirect('continue-to-pay');
    if (cid == null) return;
    if (!context.mounted) return;

    // Check minimum gap validation
    if (!controller.canProceedToCheckout) {
      Get.snackbar(
        'Invalid Schedule',
        'Minimum 4 hours required between pickup and delivery',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // Get order totals (includes express fee if applicable)
    double grandTotal = controller.grandTotal;

    if (Get.isRegistered<OrderSummaryController>()) {
      try {
        final orderCtrl = Get.find<OrderSummaryController>();
        orderCtrl.setRushAndExpressDelivery(
          serviceType: controller.serviceType.value,
          pickupDate: controller.selectedPickupDate.value,
          pickupTimeSlot: controller.selectedPickupTimeSlot.value,
          deliveryDate: controller.selectedDeliveryDate.value,
          deliveryTimeSlot: controller.selectedDeliveryTimeSlot.value,
        );
        grandTotal = orderCtrl.grandTotal;
      } catch (_) {}
    }
    if (grandTotal == 0) grandTotal = controller.grandTotal;

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
      useSafeArea: true,
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
    // Reactively follow the on-screen keyboard so the CardField is never hidden.
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusLg),
            topRight: Radius.circular(AppSizes.radiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            // Content (keyboard handled by AnimatedPadding above)
            Flexible(
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

                    // Express Delivery Indicator (if applicable)
                    if (widget.controller.isExpressDelivery.value)
                      Container(
                        margin: EdgeInsets.only(bottom: AppSizes.lg),
                        padding: EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade50,
                              Colors.amber.shade50,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: Colors.orange.shade400, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bolt,
                                color: Colors.orange.shade700,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⚡ Express Delivery Applied',
                                    style: TextStyle(
                                      fontSize: AppSizes.fontMd,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  Text(
                                    '5% express fee included in total',
                                    style: TextStyle(
                                      fontSize: AppSizes.fontSm,
                                      color: Colors.orange.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade700,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+\$${widget.controller.expressFee.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

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
      // Centralized: require valid customer ID or show snackbar and redirect to Sign In
      final customerId = await CustomerSessionHelper.requireCustomerIdOrRedirect('schedule-payment');
      if (customerId == null) {
        setState(() => _isProcessingPayment = false);
        return;
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
      final errorMessage = (e.error.message ?? '').isNotEmpty 
          ? e.error.message! 
          : 'Payment failed. Please try again.';
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
