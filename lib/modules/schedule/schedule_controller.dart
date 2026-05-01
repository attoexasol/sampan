// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
// import '../../data/service/network_caller.dart';
// import '../../data/service/local_store.dart';
// import '../../data/service/utils.dart';
//
// class ScheduleController extends GetxController {
//   final formKey = GlobalKey<FormState>();
//
//   // Address fields
//   final streetController = TextEditingController();
//   final unitController = TextEditingController();
//   final cityController = TextEditingController();
//   final postalCodeController = TextEditingController();
//
//   // Reactive variables
//   final selectedPickupDate = Rx<DateTime?>(null);
//   final selectedPickupTimeSlot = ''.obs;
//   final selectedDeliveryDate = Rx<DateTime?>(null);
//   final selectedDeliveryTimeSlot = ''.obs;
//   final isLoading = false.obs;
//   final serviceType = ''.obs;
//
//   // ORDER SUMMARY DATA
//   final orderSummaryData = <String, dynamic>{}.obs;
//
//   // Time slots
//   final List<String> timeSlots = [
//     '8:00 AM - 10:00 AM',
//     '10:00 AM - 12:00 PM',
//     '12:00 PM - 2:00 PM',
//     '2:00 PM - 4:00 PM',
//     '4:00 PM - 6:00 PM',
//   ];
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     if (Get.arguments != null) {
//       if (Get.arguments is Map<String, dynamic>) {
//         final args = Get.arguments as Map<String, dynamic>;
//
//         serviceType.value = args['serviceType'] ?? '';
//
//         if (args.containsKey('orderSummary')) {
//           orderSummaryData.value = args['orderSummary'];
//           debugPrint('Order summary received: ${orderSummaryData.value}');
//         }
//       }
//     }
//
//     _loadSavedAddress();
//   }
//
//   Future<void> _loadSavedAddress() async {
//     final saved = await LocalStore.instance.getSavedAddress();
//     if (saved != null) {
//       streetController.text = saved['street'] ?? '';
//       unitController.text = saved['unit'] ?? '';
//       cityController.text = saved['city'] ?? '';
//       postalCodeController.text = saved['postal'] ?? '';
//     }
//   }
//
//   List<Map<String, dynamic>> get orderItems {
//     final items = orderSummaryData['items'];
//     if (items is List) {
//       return items.cast<Map<String, dynamic>>();
//     }
//     return [];
//   }
//
//   Map<String, dynamic> get orderTotals {
//     final totals = orderSummaryData['totals'];
//     if (totals is Map) {
//       return Map<String, dynamic>.from(totals);
//     }
//     return {};
//   }
//
//   bool get hasOrderSummary => orderItems.isNotEmpty;
//
//   double get grandTotal => (orderTotals['grandTotal'] as num?)?.toDouble() ?? 0.0;
//
//   @override
//   void onClose() {
//     streetController.dispose();
//     unitController.dispose();
//     cityController.dispose();
//     postalCodeController.dispose();
//     super.onClose();
//   }
//
//   int getTurnaroundDays() {
//     if (serviceType.value.toLowerCase().contains('rush')) return 1;
//     if (serviceType.value.toLowerCase().contains('dry-cleaning')) return 3;
//     if (serviceType.value.toLowerCase().contains('alterations')) return 5;
//     return 2;
//   }
//
//   DateTime? getMinDeliveryDate() {
//     if (selectedPickupDate.value == null) return null;
//     return selectedPickupDate.value!.add(Duration(days: getTurnaroundDays()));
//   }
//
//   bool isDeliveryTimeSlotAvailable(String timeSlot) {
//     if (selectedPickupDate.value == null || selectedDeliveryDate.value == null) {
//       return true;
//     }
//     final minDeliveryDate = getMinDeliveryDate();
//     if (minDeliveryDate == null) return true;
//
//     if (DateFormat('yyyy-MM-dd').format(selectedDeliveryDate.value!) ==
//         DateFormat('yyyy-MM-dd').format(minDeliveryDate)) {
//       final pickupSlotIndex = timeSlots.indexOf(selectedPickupTimeSlot.value);
//       final deliverySlotIndex = timeSlots.indexOf(timeSlot);
//       return deliverySlotIndex > pickupSlotIndex;
//     }
//     return true;
//   }
//
//   Future<void> selectPickupDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now().add(const Duration(days: 1)),
//       lastDate: DateTime.now().add(const Duration(days: 30)),
//     );
//
//     if (picked != null) {
//       selectedPickupDate.value = picked;
//       if (selectedDeliveryDate.value != null) {
//         final minDelivery = getMinDeliveryDate();
//         if (minDelivery != null &&
//             selectedDeliveryDate.value!.isBefore(minDelivery)) {
//           selectedDeliveryDate.value = null;
//           selectedDeliveryTimeSlot.value = '';
//         }
//       }
//     }
//   }
//
//   Future<void> selectDeliveryDate(BuildContext context) async {
//     if (selectedPickupDate.value == null) {
//       Get.snackbar('Error', 'Please select a pickup date first',
//           backgroundColor: Colors.orange, colorText: Colors.white);
//       return;
//     }
//
//     final minDelivery = getMinDeliveryDate()!;
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: minDelivery,
//       firstDate: minDelivery,
//       lastDate: DateTime.now().add(const Duration(days: 60)),
//     );
//
//     if (picked != null) {
//       selectedDeliveryDate.value = picked;
//       if (selectedDeliveryTimeSlot.value.isNotEmpty &&
//           !isDeliveryTimeSlotAvailable(selectedDeliveryTimeSlot.value)) {
//         selectedDeliveryTimeSlot.value = '';
//       }
//     }
//   }
//
//   /// Confirm Order and Process Payment
//   Future<void> confirmOrderAndPay() async {
//     if (!formKey.currentState!.validate()) {
//       Get.snackbar('Error', 'Please fill in all required fields',
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//
//     if (selectedPickupDate.value == null ||
//         selectedPickupTimeSlot.value.isEmpty ||
//         selectedDeliveryDate.value == null ||
//         selectedDeliveryTimeSlot.value.isEmpty) {
//       Get.snackbar('Error', 'Please select all required dates and times',
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//
//     isLoading.value = true;
//
//     try {
//       final customerId = await LocalStore.instance.getCustomerId();
//       if (customerId == null || customerId.isEmpty) {
//         Get.snackbar('Error', 'Please login first',
//             backgroundColor: Colors.red, colorText: Colors.white);
//         isLoading.value = false;
//         return;
//       }
//
//       // Save address for future use
//       await LocalStore.instance.saveAddress({
//         'street': streetController.text.trim(),
//         'unit': unitController.text.trim(),
//         'city': cityController.text.trim(),
//         'postal': postalCodeController.text.trim(),
//       });
//
//       // 1️⃣ Create schedule
//       final scheduleResponse = await NetworkCaller.postForm(
//         url: "https://cleancloudapp.com/api/addSchedule",
//         fields: {
//           "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
//           "cid": customerId,
//           "pickup_date": DateFormat('yyyy-MM-dd').format(selectedPickupDate.value!),
//           "pickup_time": selectedPickupTimeSlot.value,
//           "delivery_date": DateFormat('yyyy-MM-dd').format(selectedDeliveryDate.value!),
//           "delivery_time": selectedDeliveryTimeSlot.value,
//           "street": streetController.text.trim(),
//           "unit": unitController.text.trim(),
//           "city": cityController.text.trim(),
//           "zipCode": postalCodeController.text.trim(),
//         },
//       );
//
//       if (!scheduleResponse.isSuccess) {
//         throw Exception(scheduleResponse.errorMessage ?? 'Schedule creation failed');
//       }
//
//       // 2️⃣ Create order in CleanCloud
//       final orderResponse = await NetworkCaller.postRequest(
//         url: Urls.addOrder,
//         body: {
//           "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
//           "customerID": customerId,
//           "finalTotal": grandTotal.toStringAsFixed(2),
//           "status": "0",
//           "discount": "0",
//           "deliveryFee": (orderTotals['deliveryFee'] as num?)?.toStringAsFixed(2) ?? "0",
//           "tax": (orderTotals['tax'] as num?)?.toStringAsFixed(2) ?? "0",
//         },
//       );
//
//       if (!(orderResponse.isSuccess && (orderResponse.body?['Success'] == 'True'))) {
//         throw Exception(orderResponse.body?['Error'] ?? 'Order creation failed');
//       }
//
//       final orderId = orderResponse.body?['orderID']?.toString();
//       if (orderId == null || orderId.isEmpty) {
//         throw Exception('Order ID not returned from server');
//       }
//
//       // 3️⃣ Process Stripe Payment
//       await _processStripePayment(customerId, orderId);
//
//       Get.snackbar('Success', 'Your order and payment were successful!',
//           backgroundColor: Colors.green, colorText: Colors.white);
//
//       Get.offAllNamed('/');
//
//     } catch (e) {
//       Get.snackbar('Failed', e.toString(),
//           backgroundColor: Colors.red, colorText: Colors.white);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> _processStripePayment(String customerId, String orderId) async {
//     try {
//       final paymentMethod = await Stripe.instance.createPaymentMethod(
//         params: const PaymentMethodParams.card(
//           paymentMethodData: PaymentMethodData(),
//         ),
//       );
//
//       final addCardResponse = await NetworkCaller.postRequest(
//         url: Urls.addCard,
//         body: {
//           "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
//           "customerID": customerId,
//           "type": 1,
//           "paymentMethodID": paymentMethod.id,
//         },
//       );
//
//       if (!(addCardResponse.isSuccess &&
//           (addCardResponse.body?['Success'] == 'True'))) {
//         throw Exception(addCardResponse.body?['Error'] ?? "Failed to add card");
//       }
//
//       final chargeResponse = await NetworkCaller.postRequest(
//         url: Urls.chargeCard,
//         body: {
//           "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
//           "customerID": customerId,
//           "orderID": orderId,
//           "type": 1,
//           "amount": grandTotal.toStringAsFixed(2),
//           "currency": "usd",
//         },
//       );
//
//       if (!(chargeResponse.isSuccess &&
//           (chargeResponse.body?['Success'] == 'True'))) {
//         throw Exception(chargeResponse.body?['Error'] ?? "Payment failed");
//       }
//     } catch (e) {
//       throw Exception('Payment Error: ${e.toString()}');
//     }
//   }
// }


























import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import '../../data/models/order_history_model.dart';
import '../../data/service/network_caller.dart';
import '../../data/service/local_store.dart';
import '../../data/service/customer_session_helper.dart';
import '../../data/service/utils.dart';
import '../../data/service/express_delivery_service.dart';
import '../../data/service/rush_order_service.dart';
import '../../controller/order_summary_controller.dart';


class ScheduleController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Address fields
  final streetController = TextEditingController();
  final unitController = TextEditingController();
  final cityController = TextEditingController();
  final postalCodeController = TextEditingController();

  // Reactive variables
  final selectedPickupDate = Rx<DateTime?>(null);
  final selectedPickupTimeSlot = ''.obs;
  final selectedDeliveryDate = Rx<DateTime?>(null);
  final selectedDeliveryTimeSlot = ''.obs;
  final isLoading = false.obs;
  final serviceType = ''.obs;

  // EXPRESS / RUSH DELIVERY STATE
  final isExpressDelivery = false.obs;
  final isRushDelivery = false.obs;
  final isValidDeliveryGap = true.obs;
  final deliveryDurationHours = Rx<double?>(null);
  final expressDeliveryMessage = ''.obs;
  final rushServiceType = Rx<RushServiceType>(RushServiceType.unknown);

  // ORDER SUMMARY DATA
  final orderSummaryData = <String, dynamic>{}.obs;

  // Time slots
  final List<String> timeSlots = [
    '8:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 2:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
  ];

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      if (Get.arguments is Map<String, dynamic>) {
        final args = Get.arguments as Map<String, dynamic>;

        serviceType.value = args['serviceType']?.toString() ?? '';
        rushServiceType.value = RushOrderService.instance.serviceTypeFromString(serviceType.value);

        if (args.containsKey('orderSummary')) {
          orderSummaryData.value = args['orderSummary'];
          debugPrint('Order summary received: ${orderSummaryData.value}');
        }
      }
    }

    _loadSavedAddress();
  }

  /// Reset all per-order state so the next visit to ScheduleView starts empty.
  /// Address fields are intentionally preserved (still useful for the next
  /// order and saved in LocalStore anyway). Call after a successful payment.
  void resetForNewOrder() {
    selectedPickupDate.value = null;
    selectedPickupTimeSlot.value = '';
    selectedDeliveryDate.value = null;
    selectedDeliveryTimeSlot.value = '';
    isExpressDelivery.value = false;
    isRushDelivery.value = false;
    isValidDeliveryGap.value = true;
    deliveryDurationHours.value = null;
    expressDeliveryMessage.value = '';
    rushServiceType.value = RushServiceType.unknown;
    serviceType.value = '';
    orderSummaryData.clear();
    isLoading.value = false;
  }

  Future<void> _loadSavedAddress() async {
    final saved = await LocalStore.instance.getSavedAddress();
    if (saved != null) {
      streetController.text = saved['street'] ?? '';
      unitController.text = saved['unit'] ?? '';
      cityController.text = saved['city'] ?? '';
      postalCodeController.text = saved['postal'] ?? '';
    }
  }

  List<Map<String, dynamic>> get orderItems {
    final items = orderSummaryData['items'];
    if (items is List) {
      return items.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Map<String, dynamic> get orderTotals {
    final totals = orderSummaryData['totals'];
    if (totals is Map) {
      return Map<String, dynamic>.from(totals);
    }
    return {};
  }

  bool get hasOrderSummary => orderItems.isNotEmpty;

  /// Grand total: use OrderSummaryController when registered (includes rush 2x and express fee)
  double get grandTotal {
    if (Get.isRegistered<OrderSummaryController>()) {
      try {
        return Get.find<OrderSummaryController>().grandTotal;
      } catch (_) {}
    }
    double baseTotal = (orderTotals['grandTotal'] as num?)?.toDouble() ?? 0.0;
    if (isExpressDelivery.value && !isRushDelivery.value) {
      final subtotal = (orderTotals['subTotal'] as num?)?.toDouble() ?? 0.0;
      final deliveryFee = (orderTotals['deliveryFee'] as num?)?.toDouble() ?? 0.0;
      final tax = (orderTotals['tax'] as num?)?.toDouble() ?? 0.0;
      return subtotal + deliveryFee + expressFee + tax;
    }
    if (isRushDelivery.value) {
      final baseSub = (orderTotals['subTotal'] as num?)?.toDouble() ?? 0.0;
      final subtotal = baseSub * RushOrderService.rushPriceMultiplier;
      final deliveryFee = (orderTotals['deliveryFee'] as num?)?.toDouble() ?? 0.0;
      final tax = subtotal * 0.05;
      return subtotal + deliveryFee + tax;
    }
    return baseTotal;
  }

  /// Get order totals with express/rush included
  Map<String, dynamic> get orderTotalsWithExpress {
    final totals = Map<String, dynamic>.from(orderTotals);
    totals['expressFee'] = expressFee;
    totals['isExpressDelivery'] = isExpressDelivery.value;
    totals['isRushDelivery'] = isRushDelivery.value;
    totals['grandTotal'] = grandTotal;
    return totals;
  }

  /// Whether the given delivery slot qualifies as Rush for current service (for slot UI)
  bool isDeliverySlotRush(String deliveryTimeSlot) {
    final result = RushOrderService.instance.evaluateDeliverySlot(
      serviceType: rushServiceType.value,
      pickupDate: selectedPickupDate.value,
      pickupTimeSlot: selectedPickupTimeSlot.value,
      deliveryDate: selectedDeliveryDate.value,
      deliveryTimeSlot: deliveryTimeSlot,
    );
    return result.isRush;
  }

  @override
  void onClose() {
    streetController.dispose();
    unitController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    super.onClose();
  }

  /// Get minimum turnaround days for the service type.
  /// Note: This is now 0 for all services to allow express delivery (under 24h).
  /// The actual minimum gap (4 hours) is enforced at the time slot level.
  int getTurnaroundDays() {
    // Allow same-day delivery for all services
    // The 4-hour minimum gap is enforced by isDeliveryTimeSlotAvailable()
    return 0;
  }

  /// Get the minimum delivery date (same as pickup date to allow express delivery)
  DateTime? getMinDeliveryDate() {
    if (selectedPickupDate.value == null) return null;
    // Allow same-day delivery - the 4-hour gap is validated at time slot level
    return selectedPickupDate.value!;
  }

  bool isDeliveryTimeSlotAvailable(String timeSlot) {
    if (selectedPickupDate.value == null || selectedDeliveryDate.value == null) {
      return true;
    }
    
    // Check minimum 4-hour gap using ExpressDeliveryService
    final result = ExpressDeliveryService.instance.checkExpressDelivery(
      pickupDate: selectedPickupDate.value,
      pickupTimeSlot: selectedPickupTimeSlot.value,
      deliveryDate: selectedDeliveryDate.value,
      deliveryTimeSlot: timeSlot,
    );
    
    return result.isValidGap;
  }

  /// Update rush and express delivery state based on current selection
  void _updateExpressDeliveryState() {
    final rushType = rushServiceType.value;
    final rushResult = RushOrderService.instance.evaluateDeliverySlot(
      serviceType: rushType,
      pickupDate: selectedPickupDate.value,
      pickupTimeSlot: selectedPickupTimeSlot.value,
      deliveryDate: selectedDeliveryDate.value,
      deliveryTimeSlot: selectedDeliveryTimeSlot.value,
    );
    final expressResult = ExpressDeliveryService.instance.checkExpressDelivery(
      pickupDate: selectedPickupDate.value,
      pickupTimeSlot: selectedPickupTimeSlot.value,
      deliveryDate: selectedDeliveryDate.value,
      deliveryTimeSlot: selectedDeliveryTimeSlot.value,
    );

    isValidDeliveryGap.value = rushResult.isValidGap && expressResult.isValidGap;
    deliveryDurationHours.value = rushResult.durationHours ?? expressResult.durationHours;
    isRushDelivery.value = rushResult.isRush;
    isExpressDelivery.value = !rushResult.isRush && expressResult.isExpress;
    expressDeliveryMessage.value = rushResult.isRush
        ? 'Rush: ${rushResult.durationHours?.toStringAsFixed(1) ?? '?'}h turnaround'
        : (expressResult.message ?? '');

    if (Get.isRegistered<OrderSummaryController>()) {
      try {
        final orderCtrl = Get.find<OrderSummaryController>();
        orderCtrl.setRushAndExpressDelivery(
          serviceType: serviceType.value,
          pickupDate: selectedPickupDate.value,
          pickupTimeSlot: selectedPickupTimeSlot.value,
          deliveryDate: selectedDeliveryDate.value,
          deliveryTimeSlot: selectedDeliveryTimeSlot.value,
        );
      } catch (e) {
        debugPrint('Warning: Could not update OrderSummaryController: $e');
      }
    }

    debugPrint('📦 Rush=${rushResult.isRush} Express=${isExpressDelivery.value} '
        'isValidGap=${isValidDeliveryGap.value} duration=${deliveryDurationHours.value}');
  }

  /// Get express fee (0 when Rush; otherwise 5% of base subtotal if express)
  double get expressFee {
    if (isRushDelivery.value) return 0.0;
    if (!isExpressDelivery.value) return 0.0;
    double baseSub = 0.0;
    if (Get.isRegistered<OrderSummaryController>()) {
      try {
        baseSub = Get.find<OrderSummaryController>().baseSubTotal;
      } catch (_) {}
    }
    if (baseSub == 0) baseSub = (orderTotals['subTotal'] as num?)?.toDouble() ?? 0.0;
    return ExpressDeliveryService.instance.calculateExpressFee(baseSub, true);
  }

  /// Check if checkout can proceed (valid gap)
  bool get canProceedToCheckout => isValidDeliveryGap.value;

  Future<void> selectPickupDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      selectedPickupDate.value = picked;
      if (selectedDeliveryDate.value != null) {
        final minDelivery = getMinDeliveryDate();
        if (minDelivery != null &&
            selectedDeliveryDate.value!.isBefore(minDelivery)) {
          selectedDeliveryDate.value = null;
          selectedDeliveryTimeSlot.value = '';
        }
      }
      _updateExpressDeliveryState();
    }
  }

  /// Set pickup time slot and update express state
  void setPickupTimeSlot(String slot) {
    selectedPickupTimeSlot.value = slot;
    
    // Check if current delivery time slot is still valid
    if (selectedDeliveryTimeSlot.value.isNotEmpty &&
        !isDeliveryTimeSlotAvailable(selectedDeliveryTimeSlot.value)) {
      selectedDeliveryTimeSlot.value = '';
    }
    
    _updateExpressDeliveryState();
  }

  /// Set delivery time slot and update express state
  void setDeliveryTimeSlot(String slot) {
    if (!isDeliveryTimeSlotAvailable(slot)) {
      Get.snackbar(
        'Invalid Selection',
        'Minimum ${ExpressDeliveryService.minimumGapHours} hours required between pickup and delivery',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    selectedDeliveryTimeSlot.value = slot;
    _updateExpressDeliveryState();
  }

  Future<void> selectDeliveryDate(BuildContext context) async {
    if (selectedPickupDate.value == null) {
      Get.snackbar('Error', 'Please select a pickup date first',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final minDelivery = getMinDeliveryDate()!;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minDelivery,
      firstDate: minDelivery,
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (picked != null) {
      selectedDeliveryDate.value = picked;
      if (selectedDeliveryTimeSlot.value.isNotEmpty &&
          !isDeliveryTimeSlotAvailable(selectedDeliveryTimeSlot.value)) {
        selectedDeliveryTimeSlot.value = '';
      }
      _updateExpressDeliveryState();
    }
  }

  /// Confirm Order and Process Payment
  Future<void> confirmOrderAndPay() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar('Error', 'Please fill in all required fields',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedPickupDate.value == null ||
        selectedPickupTimeSlot.value.isEmpty ||
        selectedDeliveryDate.value == null ||
        selectedDeliveryTimeSlot.value.isEmpty) {
      Get.snackbar('Error', 'Please select all required dates and times',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final customerId = await CustomerSessionHelper.requireCustomerIdOrRedirect('place-order');
      if (customerId == null) {
        isLoading.value = false;
        return;
      }

      // Save address for future use
      await LocalStore.instance.saveAddress({
        'street': streetController.text.trim(),
        'unit': unitController.text.trim(),
        'city': cityController.text.trim(),
        'postal': postalCodeController.text.trim(),
      });

      // 1️⃣ Create schedule
      final scheduleResponse = await NetworkCaller.postForm(
        url: "https://cleancloudapp.com/api/addSchedule",
        fields: {
          "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
          "cid": customerId,
          "pickup_date": DateFormat('yyyy-MM-dd').format(selectedPickupDate.value!),
          "pickup_time": selectedPickupTimeSlot.value,
          "delivery_date": DateFormat('yyyy-MM-dd').format(selectedDeliveryDate.value!),
          "delivery_time": selectedDeliveryTimeSlot.value,
          "street": streetController.text.trim(),
          "unit": unitController.text.trim(),
          "city": cityController.text.trim(),
          "zipCode": postalCodeController.text.trim(),
        },
      );

      if (!scheduleResponse.isSuccess) {
        throw Exception(scheduleResponse.errorMessage ?? 'Schedule creation failed');
      }

      // 2️⃣ Create order in CleanCloud
      final orderResponse = await NetworkCaller.postRequest(
        url: Urls.addOrder,
        body: {
          "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
          "customerID": customerId,
          "finalTotal": grandTotal.toStringAsFixed(2),
          "status": "0",
          "discount": "0",
          "deliveryFee": (orderTotals['deliveryFee'] as num?)?.toStringAsFixed(2) ?? "0",
          "tax": (orderTotals['tax'] as num?)?.toStringAsFixed(2) ?? "0",
        },
      );

      if (!(orderResponse.isSuccess && (orderResponse.body?['Success'] == 'True'))) {
        throw Exception(orderResponse.body?['Error'] ?? 'Order creation failed');
      }

      final orderId = orderResponse.body?['orderID']?.toString();
      if (orderId == null || orderId.isEmpty) {
        throw Exception('Order ID not returned from server');
      }

      // 3️⃣ Process Stripe Payment
      await _processStripePayment(customerId, orderId);

      // ✅ 4️⃣ Save order to local history (max 10 orders)
      await _saveOrderToHistory(orderId);

      Get.snackbar('Success', 'Your order and payment were successful!',
          backgroundColor: Colors.green, colorText: Colors.white);

      Get.offAllNamed('/');

    } catch (e) {
      Get.snackbar('Failed', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ NEW: Save order to local history
  Future<void> _saveOrderToHistory(String serverOrderId) async {
    try {
      // Format dates for storage
      final pickupDateStr = selectedPickupDate.value != null
          ? DateFormat('MMMM d, yyyy').format(selectedPickupDate.value!)
          : null;
      final deliveryDateStr = selectedDeliveryDate.value != null
          ? DateFormat('MMMM d, yyyy').format(selectedDeliveryDate.value!)
          : null;

      // Create order history item
      final orderHistoryItem = OrderHistoryItem(
        id: serverOrderId.isNotEmpty ? serverOrderId : OrderHistoryItem.generateOrderId(),
        items: orderItems,
        subTotal: (orderTotals['subTotal'] as num?)?.toDouble() ?? 0.0,
        deliveryFee: (orderTotals['deliveryFee'] as num?)?.toDouble() ?? 0.0,
        tax: (orderTotals['tax'] as num?)?.toDouble() ?? 0.0,
        grandTotal: grandTotal,
        pickupDate: pickupDateStr,
        pickupTimeSlot: selectedPickupTimeSlot.value,
        deliveryDate: deliveryDateStr,
        deliveryTimeSlot: selectedDeliveryTimeSlot.value,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // Save to local storage (keeps max 10 orders)
      await LocalStore.instance.saveOrderToHistory(orderHistoryItem);

      debugPrint('✅ Order saved to history: ${orderHistoryItem.id}');
    } catch (e) {
      debugPrint('⚠️ Failed to save order to history: $e');
      // Don't throw - order was successful, just history save failed
    }
  }

  Future<void> _processStripePayment(String customerId, String orderId) async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      final addCardResponse = await NetworkCaller.postRequest(
        url: Urls.addCard,
        body: {
          "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
          "customerID": customerId,
          "type": 1,
          "paymentMethodID": paymentMethod.id,
        },
      );

      if (!(addCardResponse.isSuccess &&
          (addCardResponse.body?['Success'] == 'True'))) {
        throw Exception(addCardResponse.body?['Error'] ?? "Failed to add card");
      }

      final chargeResponse = await NetworkCaller.postRequest(
        url: Urls.chargeCard,
        body: {
          "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
          "customerID": customerId,
          "orderID": orderId,
          "type": 1,
          "amount": grandTotal.toStringAsFixed(2),
          "currency": "usd",
        },
      );

      if (!(chargeResponse.isSuccess &&
          (chargeResponse.body?['Success'] == 'True'))) {
        throw Exception(chargeResponse.body?['Error'] ?? "Payment failed");
      }
    } catch (e) {
      throw Exception('Payment Error: ${e.toString()}');
    }
  }
}