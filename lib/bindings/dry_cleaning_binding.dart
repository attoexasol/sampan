import 'package:get/get.dart';
import '../controller/order_summary_controller.dart';
import '../modules/dry_cleaning/dry_cleaning_controller.dart';

class DryCleaningBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OrderSummaryController>()) {
      Get.put(OrderSummaryController());
    }
    Get.lazyPut<DryCleaningController>(() => DryCleaningController());
  }
}
