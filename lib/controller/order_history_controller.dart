import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/service/network_caller.dart';
import '../data/service/local_store.dart';
import '../data/service/customer_session_helper.dart';
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
  /// 0 = All, 1 = Active, 2 = Completed
  final selectedFilterIndex = 0.obs;
  /// Non-null when fetch failed; null when success or not yet tried
  final fetchError = Rx<String?>(null);

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

  /// Filtered list for current tab (newest first)
  List<ApiOrder> get filteredOrders {
    final list = orders.toList();
    if (selectedFilterIndex.value == 1) {
      return list.where((o) => o.statusCategory == OrderStatusCategory.active).toList();
    }
    if (selectedFilterIndex.value == 2) {
      return list.where((o) => o.statusCategory == OrderStatusCategory.completed).toList();
    }
    return list;
  }

  void setFilterIndex(int index) {
    if (index >= 0 && index <= 2) selectedFilterIndex.value = index;
  }

  void _safeSnackbar(String title, String message, {required bool isError}) {
    if (Get.overlayContext == null) return;
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Colors.red : Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> fetchOrders() async {
    final cid = await CustomerSessionHelper.requireCustomerIdOrRedirect('order-history');
    if (cid == null) {
      fetchError.value = 'Please log in to view order history.';
      return;
    }

    final apiToken = await LocalStore.instance.getApiToken() ?? _apiTokenFallback;
    isLoading.value = true;
    fetchError.value = null;
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
        fetchError.value = response.errorMessage ?? 'Could not load orders.';
      }
    } catch (e) {
      debugPrint('OrderHistoryController fetchOrders error: $e');
      orders.clear();
      fetchError.value = e.toString().replaceAll('Exception: ', '');
      _safeSnackbar('Error', 'Failed to load order history', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
