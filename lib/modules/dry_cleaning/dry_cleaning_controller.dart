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
  final isRushServiceSelected = false.obs;
  final specialInstructions = ''.obs;
  final specialInstructionsController = TextEditingController();
  final saveForFutureOrders = false.obs;

  static const double rushServiceMultiplier = 0.5;

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

  void toggleRushService() {
    isRushServiceSelected.value = !isRushServiceSelected.value;
    _updateOrderSummary();
  }

  void updateServiceQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      orderCtrl.items.remove(product.id);
    } else {
      double price = product.price;
      if (isRushServiceSelected.value) {
        price = price * (1 + rushServiceMultiplier);
      }
      
      orderCtrl.updateItem(
        key: product.id,
        title: product.name,
        subtitle: product.pieces > 1 ? '${product.pieces} piece(s)' : '',
        price: price,
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
    if (isRushServiceSelected.value) {
      orderCtrl.updateItem(
        key: 'rush_service',
        title: 'Rush Service',
        subtitle: '12 hour turnaround',
        price: 0,
        qty: 1,
      );
      
      for (var item in orderCtrl.items.values.toList()) {
        if (item.key != 'rush_service') {
          final product = services.where((p) => p.id == item.key).firstOrNull;
          if (product != null) {
            final newPrice = product.price * (1 + rushServiceMultiplier);
            orderCtrl.updateItem(
              key: item.key,
              title: item.title,
              subtitle: item.subtitle,
              price: newPrice,
              qty: item.qty,
            );
          }
        }
      }
    } else {
      orderCtrl.items.remove('rush_service');
      
      for (var item in orderCtrl.items.values.toList()) {
        if (item.key != 'rush_service') {
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
    }
  }

  bool get hasAnySelection {
    return orderCtrl.hasAnySelection;
  }

  Map<String, dynamic> getOrderSummarySnapshot() {
    final snapshot = orderCtrl.snapshot();
    snapshot['specialInstructions'] = specialInstructions.value;
    snapshot['rushService'] = isRushServiceSelected.value;
    return snapshot;
  }
}
