// import 'dart:convert';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sampan/data/models/user_profile.dart';
import '../../data/models/order_history_model.dart';
import '../../models/product_model.dart';

class LocalStore {
  LocalStore._privateConstructor();
  static final LocalStore instance = LocalStore._privateConstructor();

  static const String _customerIdKey = 'customer_id';
  static const String _lastApiResponseKey = 'last_api_response';
  static const String _loggedInKey = 'is_logged_in';
  static const String _userProfileKey = 'user_profile';
  static const String _productsKey = 'cached_products';
  static const String _productsTimestampKey = 'products_cache_timestamp';
  static const Duration _cacheValidDuration = Duration(hours: 24);

  // Order History Key
  static const String _orderHistoryKey = 'order_history_v1';
  static const int _maxOrderHistory = 10;

  // ============================================================
  // PRODUCT CACHE
  // ============================================================

  Future<void> saveProducts(ProductsResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productsKey, jsonEncode(response.toJson()));
    await prefs.setInt(_productsTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<ProductsResponse?> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_productsKey);
    final timestamp = prefs.getInt(_productsTimestampKey);

    if (jsonStr == null || timestamp == null) return null;

    final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (cacheAge > _cacheValidDuration.inMilliseconds) return null;

    try {
      return ProductsResponse.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  Future<bool> isProductsCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_productsTimestampKey);
    if (timestamp == null) return false;

    final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
    return cacheAge <= _cacheValidDuration.inMilliseconds;
  }

  Future<void> clearProductsCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productsKey);
    await prefs.remove(_productsTimestampKey);
  }

  // ============================================================
  // CUSTOMER ID + LOGIN
  // ============================================================

  Future<void> saveCustomerId(String cid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customerIdKey, cid);
  }

  Future<String?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customerIdKey);
  }

  Future<void> saveCustomerIdFromResponse(Map<String, dynamic> json) async {
    String? cid;

    for (final key in ['CustomerID', 'cid', 'customer_id', 'id']) {
      if (json[key] != null && json[key].toString().isNotEmpty) {
        cid = json[key].toString();
        break;
      }
    }

    if (cid != null) {
      await saveCustomerId(cid);
    }
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  // ============================================================
  // PAYMENT METHODS
  // ============================================================

  static const String _kPayments = 'payments_methods_v1';

  Future<void> savePaymentMethods(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPayments, jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPayments);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> appendPaymentMethod(Map<String, dynamic> item) async {
    final list = await getPaymentMethods();
    list.add(item);
    await savePaymentMethods(list);
  }

  Future<void> clearPayments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPayments);
  }

  // ============================================================
  // ADDRESS
  // ============================================================

  Future<void> saveAddress(Map<String, dynamic> address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_address', jsonEncode(address));
  }

  Future<Map<String, dynamic>?> getSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_address');
    if (raw == null) return null;
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  // ============================================================
  // USER PROFILE
  // ============================================================

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userProfileKey);
    if (jsonStr == null) return null;

    try {
      return UserProfile.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // ORDER HISTORY (⭐ REQUIRED FOR YOUR APP)
  // ============================================================

  Future<void> saveOrderToHistory(OrderHistoryItem order) async {
    final prefs = await SharedPreferences.getInstance();
    final orders = await getOrderHistory();

    orders.insert(0, order);

    final trimmedOrders = orders.take(_maxOrderHistory).toList();

    final jsonList = trimmedOrders.map((o) => o.toJson()).toList();
    await prefs.setString(_orderHistoryKey, jsonEncode(jsonList));

    debugPrint("✅ Order saved: ${order.id}");
  }

  Future<List<OrderHistoryItem>> getOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_orderHistoryKey);

    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonStr) as List;
      return decoded
          .map((e) => OrderHistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteOrderFromHistory(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final orders = await getOrderHistory();

    orders.removeWhere((o) => o.id == orderId);

    final jsonList = orders.map((o) => o.toJson()).toList();
    await prefs.setString(_orderHistoryKey, jsonEncode(jsonList));

    debugPrint("🗑 Order deleted: $orderId");
  }

  Future<void> clearOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_orderHistoryKey);
  }

  Future<OrderHistoryItem?> getOrderById(String orderId) async {
    final orders = await getOrderHistory();
    try {
      return orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  Future<int> getOrderHistoryCount() async {
    final orders = await getOrderHistory();
    return orders.length;
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
