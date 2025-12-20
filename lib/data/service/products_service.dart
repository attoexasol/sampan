// lib/data/service/products_service.dart
import 'package:flutter/foundation.dart';
import '../../models/product_model.dart';
import 'network_caller.dart';
import 'local_store.dart';
import 'utils.dart';


class ProductsService {
  static const String _apiToken = "af547bb45f372a7b1171ba7a304fcd84ab319852";

  /// Fetch products from API
  static Future<ProductsResponse?> fetchProducts() async {
    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.itemsOfLaundry,
        body: {"api_token": _apiToken},
      );

      if (response.isSuccess && response.body != null) {
        final productsResponse = ProductsResponse.fromJson(response.body!);

        // Cache the response
        await LocalStore.instance.saveProducts(productsResponse);

        debugPrint("✅ Fetched ${productsResponse.products.length} products");
        return productsResponse;
      } else {
        debugPrint("❌ Failed to fetch products: ${response.errorMessage}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error fetching products: $e");
      return null;
    }
  }

  /// Get products (from cache or fetch)
  static Future<ProductsResponse?> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      // Try to get from cache first
      final cached = await LocalStore.instance.getCachedProducts();
      if (cached != null) {
        debugPrint("📦 Using cached products");
        return cached;
      }
    }

    // Fetch from API if cache is invalid or force refresh
    debugPrint("🌐 Fetching products from API");
    return await fetchProducts();
  }

  /// Filter products by category
  static List<Product> filterByCategory(
      List<Product> products,
      ProductCategory category,
      ) {
    final sectionIds = _getCategorySections(category);
    return products
        .where((p) => sectionIds.contains(p.section))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get section IDs for a category
  static List<String> _getCategorySections(ProductCategory category) {
    switch (category) {
      case ProductCategory.laundry:
        return ['7', '11']; // IS - Laundry, P&D - Laundry
      case ProductCategory.dryCleaning:
        return ['17', '18']; // IS - Dry Cleaning, P&D - Dry Cleaning
      case ProductCategory.alterations:
        return ['16', '12']; // IS - Alt/Ste/Shoe, P&D - Alt/Ste/Shoe
    }
  }
}

enum ProductCategory {
  laundry,
  dryCleaning,
  alterations,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.laundry:
        return 'Laundry';
      case ProductCategory.dryCleaning:
        return 'Dry Cleaning';
      case ProductCategory.alterations:
        return 'Alterations';
    }
  }

  String get description {
    switch (this) {
      case ProductCategory.laundry:
        return 'Wash & Fold, Bulky Items';
      case ProductCategory.dryCleaning:
        return 'Professional Dry Cleaning';
      case ProductCategory.alterations:
        return 'Alterations, Steaming, Shoe Care';
    }
  }
}