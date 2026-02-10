import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/service/network_caller.dart';
import '../data/service/local_store.dart';
import '../data/service/utils.dart';
import '../data/models/api_order_model.dart';
import '../constants/environmental_constants.dart';

/// Cached details for an order (when we have a getOrderDetails endpoint later).
class OrderDetails {
  final Map<String, List<Map<String, dynamic>>> services;
  OrderDetails({required this.services});
}

class OrderHistoryController extends GetxController {
  final isLoading = false.obs;
  final orders = <ApiOrder>[].obs;
  final expandedOrderIds = <String>[].obs;

  final Map<String, OrderDetails> detailsCache = {};
  final Map<String, bool> detailsLoading = {};

  // api_token is same for every user; prefer stored value from login/signup
  static String get _apiTokenFallback => ApiConfig.apiToken;

  void toggleExpanded(String orderId) {
    if (expandedOrderIds.contains(orderId)) {
      expandedOrderIds.remove(orderId);
    } else {
      expandedOrderIds.add(orderId);
      fetchDetailsIfNeeded(orderId);
    }
  }

  bool isExpanded(String orderId) => expandedOrderIds.contains(orderId);

  /// Lazy load details when user expands (placeholder if no details API).
  Future<void> fetchDetailsIfNeeded(String orderId) async {
    if (detailsCache.containsKey(orderId) || detailsLoading[orderId] == true) return;
    detailsLoading[orderId] = true;
    // No getOrderDetails endpoint in codebase yet — keep placeholder
    await Future.delayed(const Duration(milliseconds: 100));
    detailsLoading[orderId] = false;
  }

  /// Get display services for expanded card (from cache or empty placeholder).
  Map<String, List<Map<String, dynamic>>> getServicesForOrder(String orderId) {
    final cached = detailsCache[orderId];
    if (cached != null) return cached.services;
    return {};
  }

  /// Format order number: ORD-YYYY-XXX (XXX = 3-digit sequence, newest = 003)
  String orderNumberFor(ApiOrder order, int indexInSortedList) {
    final date = order.displayDate ?? DateTime.now();
    final year = date.year;
    final seq = (orders.length - indexInSortedList).toString().padLeft(3, '0');
    return 'ORD-$year-$seq';
  }

  /// Environmental metrics for an order (from weight)
  Map<String, double> environmentalForOrder(ApiOrder order) {
    return environmentalFromWeight(order.weight);
  }

  /// Total environmental impact across all orders
  Map<String, double> get totalEnvironmentalImpact {
    double water = 0, detergent = 0, gas = 0, energy = 0, co2 = 0;
    for (final o in orders) {
      final e = environmentalForOrder(o);
      water += e['water']!;
      detergent += e['detergent']!;
      gas += e['gas']!;
      energy += e['energy']!;
      co2 += e['co2']!;
    }
    return {'water': water, 'detergent': detergent, 'gas': gas, 'energy': energy, 'co2': co2};
  }

  Future<void> fetchOrders() async {
    final cid = await LocalStore.instance.getCustomerId();
    if (cid == null || cid.isEmpty) {
      Get.snackbar(
        'Login required',
        'Please login first',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final apiToken = await LocalStore.instance.getApiToken() ?? _apiTokenFallback;
    isLoading.value = true;
    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.getOrders_History,
        body: {
          'api_token': apiToken,
          'customerID': cid,
        },
      );

      if (response.isSuccess && response.body != null) {
        final parsed = OrderHistoryResponse.fromJson(response.body!);
        if (parsed.success) {
          orders.value = parsed.orders;
        } else {
          orders.clear();
        }
      } else {
        orders.clear();
      }
    } catch (e) {
      debugPrint('OrderHistoryController fetchOrders error: $e');
      orders.clear();
      Get.snackbar(
        'Error',
        'Failed to load order history',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
