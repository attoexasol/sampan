// lib/controller/products_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/service/products_service.dart';
import '../models/product_model.dart';

class ProductsController extends GetxController {
  final isLoading = false.obs;
  final products = <Product>[].obs;
  final sections = <ProductSection>[].obs;
  final weightSymbol = 'lb'.obs;

  /// Premium Bag: Elite Express Bag from API (single product by exact name)
  final Rxn<Product> eliteExpressBag = Rxn<Product>();
  final RxDouble eliteExpressBagPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  /// Find "Elite Express Bag" product by exact name match.
  Product? findEliteExpressBag(List<Product> products) {
    for (final p in products) {
      if ((p.name).trim() == 'Elite Express Bag') return p;
    }
    return null;
  }

  /// Load products (from cache or API)
  Future<void> loadProducts({bool forceRefresh = false}) async {
    isLoading.value = true;

    try {
      final response = await ProductsService.getProducts(
        forceRefresh: forceRefresh,
      );

      if (response != null) {
        products.value = response.products;
        sections.value = response.sections;
        weightSymbol.value = response.weightSymbol;
        final elite = findEliteExpressBag(response.products);
        eliteExpressBag.value = elite;
        eliteExpressBagPrice.value = elite != null ? elite.price : 0.0;
        debugPrint("✅ Loaded ${products.length} products");
      } else {
        Get.snackbar(
          'Error',
          'Failed to load products. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("❌ Error loading products: $e");
      Get.snackbar(
        'Error',
        'An error occurred while loading products.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get products by category
  List<Product> getProductsByCategory(ProductCategory category) {
    return ProductsService.filterByCategory(products, category);
  }

  /// Refresh products from API
  Future<void> refreshProducts() async {
    await loadProducts(forceRefresh: true);
  }
}