import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/products_controller.dart';
import '../../controller/order_summary_controller.dart';
import '../../data/service/products_service.dart';
import '../../models/product_model.dart';

class DryCleaningController extends GetxController {
  final orderCtrl = Get.find<OrderSummaryController>();
  final productsCtrl = Get.find<ProductsController>();

  final isLoadingServices = false.obs;
  final services = <Product>[].obs;
  final specialInstructions = ''.obs;
  final specialInstructionsController = TextEditingController();
  final saveForFutureOrders = false.obs;

  /// UI opt-in for rush dry cleaning (card on dry cleaning screen).
  final isRushServiceSelected = false.obs;

  void toggleRushService() {
    isRushServiceSelected.value = !isRushServiceSelected.value;
  }

  @override
  void onInit() {
    super.onInit();
    loadServices();
    specialInstructionsController.addListener(() {
      specialInstructions.value = specialInstructionsController.text;
    });
  }

  @override
  void onClose() {
    specialInstructionsController.dispose();
    super.onClose();
  }

  Future<void> loadServices() async {
    isLoadingServices.value = true;
    try {
      if (productsCtrl.isLoading.value) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      if (productsCtrl.products.isEmpty) {
        await productsCtrl.loadProducts();
      }
      
      final allProducts = productsCtrl.products;
      final dryCleaningProducts = ProductsService.filterByCategory(
        allProducts,
        ProductCategory.dryCleaning,
      );
      
      services.value = dryCleaningProducts;
      
      debugPrint("✅ Loaded ${services.length} dry cleaning services from API");
    } catch (e) {
      debugPrint("❌ Error loading dry cleaning services: $e");
      Get.snackbar(
        'Error',
        'Failed to load services. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingServices.value = false;
    }
  }

  void updateServiceQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      orderCtrl.items.remove(product.id);
    } else {
      orderCtrl.updateItem(
        key: product.id,
        title: product.name,
        subtitle: product.pieces > 1 ? '${product.pieces} piece(s)' : '',
        price: product.price,
        qty: quantity,
      );
    }
    _updateOrderSummary();
  }

  int getServiceQuantity(String productId) {
    return orderCtrl.getItemQty(productId);
  }

  void incrementService(Product product) {
    final currentQty = getServiceQuantity(product.id);
    updateServiceQuantity(product, currentQty + 1);
  }

  void decrementService(Product product) {
    final currentQty = getServiceQuantity(product.id);
    if (currentQty > 0) {
      updateServiceQuantity(product, currentQty - 1);
    }
  }

  void _updateOrderSummary() {
    for (var item in orderCtrl.items.values.toList()) {
      final product = services.where((p) => p.id == item.key).firstOrNull;
      if (product != null) {
        orderCtrl.updateItem(
          key: item.key,
          title: item.title,
          subtitle: item.subtitle,
          price: product.price,
          qty: item.qty,
        );
      }
    }
  }

  bool get hasAnySelection {
    return orderCtrl.hasAnySelection;
  }

  Map<String, dynamic> getOrderSummarySnapshot() {
    final snapshot = orderCtrl.snapshot();
    snapshot['specialInstructions'] = specialInstructions.value;
    snapshot['wantsRushService'] = isRushServiceSelected.value;
    return snapshot;
  }
}
