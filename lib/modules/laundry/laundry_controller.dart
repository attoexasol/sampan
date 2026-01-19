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

  // Express service
  final isExpressServiceSelected = false.obs;

  // Special instructions
  final specialInstructions = ''.obs;
  final specialInstructionsController = TextEditingController();
  final saveForFutureOrders = false.obs;

  // Service prices (static - should come from config/API in future)
  static const double premiumBagPrice = 20.0;
  static const double subscriptionPrice = 18.0;
  static const double payAsYouGoPrice = 2.25; // per pound
  static const double payAsYouGoMinCharge = 45.0;
  static const double expressServicePrice = 5.0;

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

  /// Toggle Premium Bag service
  void togglePremiumBag() {
    isPremiumBagSelected.value = !isPremiumBagSelected.value;
    _updateOrderSummary();
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

  /// Toggle Express Service
  void toggleExpressService() {
    isExpressServiceSelected.value = !isExpressServiceSelected.value;
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
  void _updateOrderSummary() {
    // Premium Bag
    if (isPremiumBagSelected.value) {
      orderCtrl.updateItem(
        key: 'premium_bag',
        title: 'Premium Bag',
        subtitle: 'Premium Bag Service',
        price: premiumBagPrice,
        qty: 1,
      );
    } else {
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

    // Express Service
    if (isExpressServiceSelected.value) {
      orderCtrl.updateItem(
        key: 'express_service',
        title: 'Express Service',
        subtitle: '24-hour turnaround',
        price: expressServicePrice,
        qty: 1,
      );
    } else {
      orderCtrl.items.remove('express_service');
    }
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
