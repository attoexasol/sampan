// lib/bindings/laundry_binding.dart
import 'package:get/get.dart';
import '../controller/order_summary_controller.dart';
import '../modules/laundry/laundry_controller.dart';

class LaundryBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure OrderSummaryController exists (may already be registered)
    if (!Get.isRegistered<OrderSummaryController>()) {
      Get.put(OrderSummaryController());
    }
    // Register LaundryController
    Get.lazyPut<LaundryController>(() => LaundryController());
  }
}
