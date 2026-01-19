import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt currentTab = 0.obs;
  final RxString currentStep = 'service-selection'.obs;

  // Services
  final RxMap<String, bool> services = <String, bool>{
    'weekly': false,
    'payasyougo': false,
    'eliteexpress': false,
  }.obs;

  // Addons
  final RxMap<String, bool> addons = <String, bool>{
    'laundry-rush-service': false,
    'dry-cleaning-rush-service': false,
    'steaming-rush-service': false,
    'alterations-rush-service': false,
  }.obs;

  // Item quantities
  final RxMap<String, int> quantities = <String, int>{}.obs;

  // Pricing data
  final Map<String, double> itemPrices = {
    'blanket': 30.0,
    'down-comforter': 60.0,
    'pillow': 15.0,
    'down-pillow': 50.0,
    'rug': 50.0,
    'sleeping-bag': 50.0,
    'coverall': 15.0,
    'jacket': 15.0,
    'pet-bed': 50.0,
    'hang-dry': 7.50,
    'extra-soiled': 10.00,
    'pet-hair': 7.50,
  };

  void toggleService(String service) {
    services[service] = !(services[service] ?? false);
  }

  void toggleAddon(String addon) {
    addons[addon] = !(addons[addon] ?? false);
  }

  void updateQuantity(String item, int quantity) {
    quantities[item] = quantity;
  }

  void incrementQuantity(String item) {
    quantities[item] = (quantities[item] ?? 0) + 1;
  }

  void decrementQuantity(String item) {
    int current = quantities[item] ?? 0;
    if (current > 0) {
      quantities[item] = current - 1;
    }
  }

  double calculateTotal() {
    double total = 0.0;

    // Add service prices
    if (services['weekly'] == true) total += 75.0;
    if (services['payasyougo'] == true) total += 2.25;
    if (services['eliteexpress'] == true) total += 25.0;

    // Add item prices
    quantities.forEach((item, qty) {
      total += (itemPrices[item] ?? 0.0) * qty;
    });

    return total;
  }

  void changeTab(int index) {
    currentTab.value = index;
  }

  void goToSchedule() {
    Get.toNamed('/schedule');
  }
}
