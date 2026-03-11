// lib/modules/laundry/laundry_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/products_controller.dart';
import '../../controller/order_summary_controller.dart';
import '../../data/service/products_service.dart';
import '../../models/product_model.dart';

class LaundryController extends GetxController {
  final orderCtrl = Get.find<OrderSummaryController>();
  final productsCtrl = Get.find<ProductsController>();

  // Loading states
  final isLoadingBulkyItems = false.obs;

  // Bulky items from API
  final bulkyItems = <Product>[].obs;

  // Service selections (Premium Bag, Subscriptions, Pay As You Go)
  final isPremiumBagSelected = false.obs;
  final isSubscriptionSelected = false.obs;
  final isPayAsYouGoSelected = false.obs;

  // NOTE: Express service is now automatically detected based on pickup/delivery schedule
  // See ExpressDeliveryService for automatic express detection (delivery within 24h of pickup)

  // Special instructions
  final specialInstructions = ''.obs;
  final specialInstructionsController = TextEditingController();
  final saveForFutureOrders = false.obs;

  // Service prices (static - should come from config/API in future)
  static const double premiumBagPrice = 20.0;
  static const double subscriptionPrice = 18.0;
  static const double payAsYouGoPrice = 2.25; // per pound
  static const double payAsYouGoMinCharge = 45.0;
  // NOTE: Express delivery fee is now 5% of subtotal, calculated automatically
  // when delivery is scheduled within 24 hours of pickup

  @override
  void onInit() {
    super.onInit();
    loadBulkyItems();
    specialInstructionsController.addListener(() {
      specialInstructions.value = specialInstructionsController.text;
    });
  }

  @override
  void onClose() {
    specialInstructionsController.dispose();
    super.onClose();
  }

  /// Load bulky items from API
  Future<void> loadBulkyItems() async {
    isLoadingBulkyItems.value = true;
    try {
      // Wait for products to load if they're still loading
      if (productsCtrl.isLoading.value) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      // If products are still empty, try to refresh
      if (productsCtrl.products.isEmpty) {
        await productsCtrl.loadProducts();
      }
      
      // Filter products for laundry category - these include bulky items
      final allProducts = productsCtrl.products;
      
      // Filter bulky items - typically items in specific sections
      // Adjust section IDs based on your API response structure
      // For now, we'll filter all laundry products as they may include bulky items
      final laundryProducts = ProductsService.filterByCategory(
        allProducts,
        ProductCategory.laundry,
      );
      
      // Store as bulky items (or filter further if needed based on product name/section)
      bulkyItems.value = laundryProducts;
      
      debugPrint("✅ Loaded ${bulkyItems.length} bulky items from API");
    } catch (e) {
      debugPrint("❌ Error loading bulky items: $e");
      Get.snackbar(
        'Error',
        'Failed to load bulky items. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingBulkyItems.value = false;
    }
  }

  /// Toggle Premium Bag service (Elite Express Bag from API only)
  void togglePremiumBag(ProductsController productsCtrl) {
    final elite = productsCtrl.eliteExpressBag.value;
    final price = productsCtrl.eliteExpressBagPrice.value;
    if (elite == null || price <= 0) {
      Get.snackbar(
        'Unavailable',
        'Premium Bag service is currently unavailable',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isPremiumBagSelected.value = !isPremiumBagSelected.value;
    _updateOrderSummary(productsCtrl);
  }

  /// Toggle Subscription service
  void toggleSubscription() {
    isSubscriptionSelected.value = !isSubscriptionSelected.value;
    _updateOrderSummary();
  }

  /// Toggle Pay As You Go service
  void togglePayAsYouGo() {
    isPayAsYouGoSelected.value = !isPayAsYouGoSelected.value;
    _updateOrderSummary();
  }

  /// Update quantity for a bulky item
  void updateBulkyItemQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      orderCtrl.items.remove(product.id);
    } else {
      orderCtrl.updateItem(
        key: product.id,
        title: product.name,
        subtitle: '${product.pieces} piece(s)',
        price: product.price,
        qty: quantity,
      );
    }
  }

  /// Get quantity for a bulky item
  int getBulkyItemQuantity(String productId) {
    return orderCtrl.getItemQty(productId);
  }

  /// Increment bulky item quantity
  void incrementBulkyItem(Product product) {
    final currentQty = getBulkyItemQuantity(product.id);
    updateBulkyItemQuantity(product, currentQty + 1);
  }

  /// Decrement bulky item quantity
  void decrementBulkyItem(Product product) {
    final currentQty = getBulkyItemQuantity(product.id);
    if (currentQty > 0) {
      updateBulkyItemQuantity(product, currentQty - 1);
    }
  }

  /// Update order summary with service selections
  void _updateOrderSummary([ProductsController? productsCtrl]) {
    final pCtrl = productsCtrl ?? this.productsCtrl;
    final elite = pCtrl.eliteExpressBag.value;
    final elitePrice = pCtrl.eliteExpressBagPrice.value;

    // Premium Bag: Elite Express Bag only (product id from API)
    if (isPremiumBagSelected.value && elite != null && elitePrice > 0) {
      orderCtrl.updateItem(
        key: elite.id,
        title: elite.name,
        subtitle: 'Premium Bag Service',
        price: elitePrice,
        qty: 1,
      );
    } else {
      if (elite != null) orderCtrl.items.remove(elite.id);
      orderCtrl.items.remove('premium_bag');
    }

    // Subscription
    if (isSubscriptionSelected.value) {
      orderCtrl.updateItem(
        key: 'subscription',
        title: 'Green Bag Plus',
        subtitle: 'Subscription - \$18/bag',
        price: subscriptionPrice,
        qty: 1,
      );
    } else {
      orderCtrl.items.remove('subscription');
    }

    // Pay As You Go
    if (isPayAsYouGoSelected.value) {
      orderCtrl.updateItem(
        key: 'pay_as_you_go',
        title: 'Pay Per Pound',
        subtitle: 'Pay As You Go - \$2.25/lb',
        price: payAsYouGoMinCharge, // Minimum charge
        qty: 1,
      );
    } else {
      orderCtrl.items.remove('pay_as_you_go');
    }

    // NOTE: Express delivery is now automatically detected based on schedule
    // Express fee (5% of subtotal) is applied when delivery is within 24h of pickup
    // See: ScheduleController._updateExpressDeliveryState() and ExpressDeliveryService
  }

  /// Check if user has any selection
  bool get hasAnySelection {
    return isPremiumBagSelected.value ||
        isSubscriptionSelected.value ||
        isPayAsYouGoSelected.value ||
        orderCtrl.hasAnySelection;
  }

  /// Get order summary snapshot for navigation
  Map<String, dynamic> getOrderSummarySnapshot() {
    final snapshot = orderCtrl.snapshot();
    snapshot['specialInstructions'] = specialInstructions.value;
    return snapshot;
  }
}
