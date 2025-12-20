// lib/bindings/laundry_binding.dart
import 'package:get/get.dart';

import '../controller/order_summary_controller.dart';


class LaundryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderSummaryController>(() => OrderSummaryController());
  }
}
