// lib/modules/laundry/laundry_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/products_controller.dart';
import '../../controller/order_summary_controller.dart';
import '../../data/models/subscription_state_model.dart';
import '../../data/service/customer_session_helper.dart';
import '../../data/service/local_store.dart';
import '../../data/service/products_service.dart';
import '../../data/service/subscription_service.dart';
import '../../data/service/utils.dart';
import '../../models/product_model.dart';

/// Centralized customer ID validation. Treat null, empty, literal "null", whitespace as invalid.
bool isInvalidCustomerId(String? id) {
  if (id == null) return true;
  final t = id.trim();
  return t.isEmpty || t.toLowerCase() == 'null';
}

/// Result of tapping Dream Big Plan Add; UI shows message from context when not canContinue.
enum DreamBigTapResult { canContinue, needLogin, alreadyActive }

class LaundryController extends GetxController {
  final orderCtrl = Get.find<OrderSummaryController>();
  final productsCtrl = Get.find<ProductsController>();

  /// Show snackbar only when Overlay is available to avoid "No Overlay widget found" crash.
  void _safeSnackbar(String title, String message, {required bool isError}) {
    if (Get.overlayContext == null) {
      debugPrint('[DreamBig] _safeSnackbar skipped (no overlay): $title - $message');
      return;
    }
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Loading states
  final isLoadingBulkyItems = false.obs;

  // Bulky items from API
  final bulkyItems = <Product>[].obs;

  // Service selections (Premium Bag, Subscriptions, Pay As You Go)
  final isPremiumBagSelected = false.obs;
  final isSubscriptionSelected = false.obs;
  final isPayAsYouGoSelected = false.obs;

  // Dream Big Plan: persisted state (restored on init, cleared when expired)
  final dreamBigSubscription = Rx<SubscriptionStateModel?>(null);
  final isSubscriptionProcessing = false.obs;

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
    restoreDreamBigPlanState();
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

  /// Toggle Subscription service (legacy toggle; Dream Big uses Add flow)
  void toggleSubscription() {
    isSubscriptionSelected.value = !isSubscriptionSelected.value;
    _updateOrderSummary();
  }

  /// True when the Dream Big Plan line is currently in the Order Summary.
  bool get isDreamBigInSummary => orderCtrl.items.containsKey('dream_big_plan');

  /// Toggle the Dream Big Plan as a line item in the Order Summary.
  /// No login/payment is required here — auth + payment are enforced at the
  /// global "Continue to Pay" checkout step. The price compounds with
  /// Bulky Items via [OrderSummaryController.subTotal].
  void toggleDreamBigPlanInSummary() {
    // If user has already paid and the plan is active, do nothing here.
    if (isDreamBigPlanActive) return;
    if (isDreamBigInSummary) {
      orderCtrl.items.remove('dream_big_plan');
      isSubscriptionSelected.value = false;
    } else {
      orderCtrl.updateItem(
        key: 'dream_big_plan',
        title: SubscriptionConfig.dreamBigPlanName,
        subtitle: '4 bags per month',
        price: SubscriptionConfig.dreamBigPlanPrice,
        qty: 1,
      );
      isSubscriptionSelected.value = true;
    }
  }

  /// Restore Dream Big state from storage (pending or active). Clear if expired.
  Future<void> restoreDreamBigPlanState() async {
    final stored = await LocalStore.instance.getDreamBigSubscription();
    dreamBigSubscription.value = stored;
    dreamBigSubscription.refresh();
    await expireDreamBigPlanIfNeeded();
    if (dreamBigSubscription.value != null) {
      isSubscriptionSelected.value = true;
      _updateOrderSummary();
    }
  }

  /// Clear expired active subscription; remove from summary if expired.
  Future<void> expireDreamBigPlanIfNeeded() async {
    final state = dreamBigSubscription.value;
    if (state == null) return;
    if (state.isActive && state.isExpired) {
      await LocalStore.instance.clearDreamBigSubscription();
      dreamBigSubscription.value = null;
      dreamBigSubscription.refresh();
      isSubscriptionSelected.value = false;
      orderCtrl.items.remove('dream_big_plan');
      _updateOrderSummary();
    }
  }

  /// True if Dream Big Plan is active and not expired.
  bool get isDreamBigPlanActive {
    final state = dreamBigSubscription.value;
    if (state == null) return false;
    return state.isActive && !state.isExpired;
  }

  /// True if user tapped Add and payment not yet completed (show Inactive).
  bool get isDreamBigPlanPending {
    final state = dreamBigSubscription.value;
    return state != null && state.isPending;
  }

  bool get shouldShowAdd => !isDreamBigPlanActive && !isDreamBigPlanPending;

  /// Button label from state: Add | Inactive | Active
  String get subscriptionButtonText {
    if (isDreamBigPlanActive) return 'Active';
    if (isDreamBigPlanPending) return 'Inactive';
    return 'Add';
  }

  /// Called when user taps Dream Big Plan. Validates customer; does NOT show snackbar (no Overlay).
  /// Returns canContinue only when customerId is valid; then UI may open payment dialog.
  Future<DreamBigTapResult> onTapDreamBigPlan() async {
    debugPrint('[DreamBig] onTapDreamBigPlan called');
    if (isSubscriptionProcessing.value) {
      debugPrint('[DreamBig] Early return: processing');
      return DreamBigTapResult.needLogin;
    }
    if (isDreamBigPlanActive) {
      debugPrint('[DreamBig] Early return: already active');
      return DreamBigTapResult.alreadyActive;
    }
    final customerId = await CustomerSessionHelper.requireCustomerIdOrRedirect('dream-big-plan');
    if (customerId == null) {
      debugPrint('[DreamBig] Early return: no valid customer ID (snackbar + redirect)');
      return DreamBigTapResult.needLogin;
    }
    debugPrint('[DreamBig] Validation passed; setting pending');
    final pendingState = SubscriptionStateModel(
      subscriptionId: SubscriptionConfig.dreamBigPlanId,
      planName: SubscriptionConfig.dreamBigPlanName,
      customerId: customerId,
      price: SubscriptionConfig.dreamBigPlanPrice,
      isActive: false,
      isPending: true,
      activatedAt: null,
      expiresAt: null,
    );
    await LocalStore.instance.saveDreamBigSubscription(pendingState);
    dreamBigSubscription.value = pendingState;
    isSubscriptionSelected.value = true;
    _updateOrderSummary();
    debugPrint('[DreamBig] Pending state saved; button should show Inactive');
    dreamBigSubscription.refresh();
    return DreamBigTapResult.canContinue;
  }

  /// Call after payment succeeds: call CleanCloud addSubscription, then mark active or revert.
  Future<void> onPaymentSuccess(String customerId) async {
    if (isInvalidCustomerId(customerId)) {
      debugPrint('[DreamBig] onPaymentSuccess skipped: invalid customerId');
      return;
    }
    debugPrint('[DreamBig] onPaymentSuccess called for customerId=$customerId');
    isSubscriptionProcessing.value = true;
    try {
      final ok = await SubscriptionService.addSubscription(customerId);
      debugPrint('[DreamBig] addSubscription API result: $ok');
      if (!ok) {
        await onPaymentFailed();
        _safeSnackbar(
          'Subscription failed',
          'Could not add plan. Please try again or contact support.',
          isError: true,
        );
        return;
      }
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 30));
      final state = SubscriptionStateModel(
        subscriptionId: SubscriptionConfig.dreamBigPlanId,
        planName: SubscriptionConfig.dreamBigPlanName,
        customerId: customerId,
        price: SubscriptionConfig.dreamBigPlanPrice,
        isActive: true,
        isPending: false,
        activatedAt: now,
        expiresAt: expiresAt,
      );
      await LocalStore.instance.saveDreamBigSubscription(state);
      dreamBigSubscription.value = state;
      _updateOrderSummary();
      debugPrint('[DreamBig] Active state saved; button should show Active');
      dreamBigSubscription.refresh();
      _safeSnackbar(
        'Success',
        'Dream Big Plan is now active for 30 days.',
        isError: false,
      );
    } catch (e) {
      debugPrint('[DreamBig] onPaymentSuccess error: $e');
      await onPaymentFailed();
      _safeSnackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      isSubscriptionProcessing.value = false;
    }
  }

  /// Call on payment fail or cancel: clear pending and remove from summary.
  Future<void> onPaymentFailed() async {
    debugPrint('[DreamBig] onPaymentFailed: reverting to Add');
    await LocalStore.instance.clearDreamBigSubscription();
    dreamBigSubscription.value = null;
    dreamBigSubscription.refresh();
    isSubscriptionSelected.value = false;
    orderCtrl.items.remove('dream_big_plan');
    _updateOrderSummary();
  }

  /// Legacy: activate after payment (used if card passes customerId after dialog success).
  Future<void> activateDreamBigPlan(String customerId) async {
    await onPaymentSuccess(customerId);
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

    // Subscription (legacy Green Bag Plus)
    if (isSubscriptionSelected.value && dreamBigSubscription.value == null) {
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

    // Dream Big Plan: in summary when pending or active (not expired)
    final dreamBig = dreamBigSubscription.value;
    if (dreamBig != null && (!dreamBig.isExpired || dreamBig.isPending)) {
      orderCtrl.updateItem(
        key: 'dream_big_plan',
        title: SubscriptionConfig.dreamBigPlanName,
        subtitle: '4 bags per month',
        price: SubscriptionConfig.dreamBigPlanPrice,
        qty: 1,
      );
    } else {
      orderCtrl.items.remove('dream_big_plan');
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
