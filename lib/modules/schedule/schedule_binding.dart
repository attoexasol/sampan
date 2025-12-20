import 'package:get/get.dart';
import 'schedule_controller.dart';
import '../../controller/order_summary_controller.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduleController>(() => ScheduleController());
    // ✅ Ensure OrderSummaryController is available (will be reconstructed in ScheduleController.onInit)
    if (!Get.isRegistered<OrderSummaryController>()) {
      Get.lazyPut<OrderSummaryController>(() => OrderSummaryController());
    }
  }
}