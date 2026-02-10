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
  static const String _apiTokenKey = 'api_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _customerAddressKey = 'customer_address';
  static const String _deliveryInstructionsKey = 'delivery_instructions';
  static const String _lastApiResponseKey = 'last_api_response';
  static const String _loggedInKey = 'is_logged_in';
  static const String _userProfileKey = 'user_profile';
  static const String _productsKey = 'cached_products';
  static const String _productsTimestampKey = 'products_cache_timestamp';
  static const Duration _cacheValidDuration = Duration(hours: 24);

  /// Save products to cache
  Future<void> saveProducts(ProductsResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productsKey, jsonEncode(response.toJson()));
    await prefs.setInt(
        _productsTimestampKey, DateTime.now().millisecondsSinceEpoch);
    debugPrint("✅ Products cached successfully");
  }

  /// Get cached products
  Future<ProductsResponse?> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_productsKey);
    final timestamp = prefs.getInt(_productsTimestampKey);

    if (jsonStr == null || timestamp == null) return null;

    final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (cacheAge > _cacheValidDuration.inMilliseconds) {
      debugPrint("⚠️ Product cache expired");
      return null;
    }

    try {
      return ProductsResponse.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      debugPrint("⚠️ Failed to parse cached products: $e");
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

  // SAVE CUSTOMER ID
  Future<void> saveCustomerId(String cid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_customerIdKey, cid);
      debugPrint('✅ saveCustomerId: Saved customer ID "$cid" to key "$_customerIdKey"');
      
      // Verify it was saved
      final verify = prefs.getString(_customerIdKey);
      debugPrint('✅ saveCustomerId: Verification - Retrieved value: "$verify"');
    } catch (e) {
      debugPrint('❌ saveCustomerId: Error saving customer ID: $e');
      rethrow;
    }
  }

  Future<String?> getCustomerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString(_customerIdKey);
      debugPrint('🔍 getCustomerId: Retrieved from key "$_customerIdKey": "$cid"');
      
      // Also check all keys to see what's stored
      final allKeys = prefs.getKeys();
      debugPrint('🔍 getCustomerId: All SharedPreferences keys: ${allKeys.toList()}');
      
      return cid;
    } catch (e) {
      debugPrint('❌ getCustomerId: Error retrieving customer ID: $e');
      return null;
    }
  }

  // -----------------------------------------------------
  // SESSION (api_token, customer_id, user_name, user_email)
  // -----------------------------------------------------

  /// Save session data — single source of truth for user info and delivery address.
  Future<void> saveSession({
    String? customerId,
    String? apiToken,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? instructions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (customerId != null) await prefs.setString(_customerIdKey, customerId);
    if (apiToken != null) await prefs.setString(_apiTokenKey, apiToken);
    if (name != null) await prefs.setString(_userNameKey, name);
    if (email != null) await prefs.setString(_userEmailKey, email);
    if (phone != null) await prefs.setString(_userPhoneKey, phone);
    if (address != null) await prefs.setString(_customerAddressKey, address);
    if (instructions != null) await prefs.setString(_deliveryInstructionsKey, instructions);
  }

  Future<String?> getApiToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiTokenKey);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey);
  }

  Future<String?> getCustomerAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customerAddressKey);
  }

  Future<String?> getDeliveryInstructions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deliveryInstructionsKey);
  }

  /// Clear session keys (customer_id, api_token, user_name, user_email, user_phone, customer_address, delivery_instructions, is_logged_in).
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customerIdKey);
    await prefs.remove(_apiTokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_customerAddressKey);
    await prefs.remove(_deliveryInstructionsKey);
    await prefs.setBool(_loggedInKey, false);
  }

  Future<void> saveCustomerIdFromResponse(Map<String, dynamic> json) async {
    debugPrint('🔍 saveCustomerIdFromResponse: Starting extraction from response');
    debugPrint('🔍 saveCustomerIdFromResponse: Response keys: ${json.keys.toList()}');
    debugPrint('🔍 saveCustomerIdFromResponse: Full response: $json');
    
    String? cid;

    // Try common keys for customer ID (case-insensitive search)
    final keysToTry = [
      'CustomerID', 'customerID', 'customer_id', 'customerId', 'CustomerId',
      'cid', 'CID', 'Cid',
      'id', 'ID', 'Id',
      'customerID', 'Customer_ID',
    ];
    
    // First, try exact key matches
    for (final key in keysToTry) {
      if (json.containsKey(key) && json[key] != null) {
        final value = json[key];
        debugPrint('🔍 saveCustomerIdFromResponse: Found key "$key" with value: $value (type: ${value.runtimeType})');
        
        // Handle both string and numeric IDs
        if (value is String && value.isNotEmpty && value.trim().isNotEmpty) {
          cid = value.trim();
          debugPrint('✅ Found customer ID (string) with key "$key": $cid');
          break;
        } else if (value is num) {
          cid = value.toString().trim();
          debugPrint('✅ Found customer ID (numeric) with key "$key": $cid');
          break;
        } else if (value != null) {
          // Try to convert to string
          final strValue = value.toString().trim();
          if (strValue.isNotEmpty) {
            cid = strValue;
            debugPrint('✅ Found customer ID (converted) with key "$key": $cid');
            break;
          }
        }
      }
    }
    
    // If not found, try case-insensitive search through all keys
    if (cid == null || cid.isEmpty) {
      debugPrint('🔍 saveCustomerIdFromResponse: Trying case-insensitive search...');
      for (final responseKey in json.keys) {
        final lowerKey = responseKey.toString().toLowerCase();
        if (lowerKey.contains('customer') && lowerKey.contains('id')) {
          final value = json[responseKey];
          if (value != null) {
            if (value is String && value.isNotEmpty) {
              cid = value.trim();
              debugPrint('✅ Found customer ID (case-insensitive) with key "$responseKey": $cid');
              break;
            } else if (value is num) {
              cid = value.toString().trim();
              debugPrint('✅ Found customer ID (case-insensitive, numeric) with key "$responseKey": $cid');
              break;
            }
          }
        }
      }
    }

    if (cid != null && cid.isNotEmpty) {
      await saveCustomerId(cid);
      debugPrint('✅ Customer ID saved successfully: $cid');
    } else {
      debugPrint('⚠️ Customer ID not found in response!');
      debugPrint('⚠️ Available keys: ${json.keys.toList()}');
      debugPrint('⚠️ Full response structure: $json');
    }
  }
  
  /// Debug helper: Print all stored data
  Future<void> debugPrintAllStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      debugPrint('🔍 DEBUG: All SharedPreferences keys: ${allKeys.toList()}');
      
      for (final key in allKeys) {
        final value = prefs.get(key);
        debugPrint('🔍 DEBUG: Key "$key" = $value');
      }
    } catch (e) {
      debugPrint('❌ DEBUG: Error reading SharedPreferences: $e');
    }
  }

  // PAYMENT METHODS
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

    return decoded
        .map<Map<String, dynamic>>(
            (e) => Map<String, dynamic>.from(e))
        .toList();
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

  // ADDRESS
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

  // API RESPONSE STORAGE
  Future<void> saveApiResponse(Map<String, dynamic> json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(json);
      await prefs.setString(_lastApiResponseKey, jsonString);
      debugPrint('✅ saveApiResponse: Saved API response to key "$_lastApiResponseKey"');
      debugPrint('✅ saveApiResponse: Response keys: ${json.keys.toList()}');
      
      // Verify it was saved
      final verify = prefs.getString(_lastApiResponseKey);
      debugPrint('✅ saveApiResponse: Verification - Data saved: ${verify != null && verify.isNotEmpty}');
    } catch (e) {
      debugPrint('❌ saveApiResponse: Error saving API response: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getLastApiResponse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_lastApiResponseKey);
      debugPrint('🔍 getLastApiResponse: Retrieved from key "$_lastApiResponseKey": ${data != null ? "exists (${data.length} chars)" : "null"}');
      
      if (data == null || data.isEmpty) {
        return null;
      }
      
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      debugPrint('🔍 getLastApiResponse: Decoded keys: ${decoded.keys.toList()}');
      return decoded;
    } catch (e) {
      debugPrint('❌ getLastApiResponse: Error retrieving API response: $e');
      return null;
    }
  }

  // LOGIN STATE
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  // USER PROFILE
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
  // ⭐ ORDER HISTORY (MAX 10 ORDERS)
  // ============================================================

  static const String _orderHistoryKey = 'order_history_v1';
  static const int _maxOrderHistory = 10;

  /// Save order
  Future<void> saveOrderToHistory(OrderHistoryItem order) async {
    final prefs = await SharedPreferences.getInstance();
    final orders = await getOrderHistory();

    orders.insert(0, order); // newest first

    final trimmed = orders.take(_maxOrderHistory).toList();
    await prefs.setString(
      _orderHistoryKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  /// Get all orders
  Future<List<OrderHistoryItem>> getOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_orderHistoryKey);

    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonStr) as List;
      return decoded
          .map((e) => OrderHistoryItem.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList();
    } catch (e) {
      debugPrint("⚠️ Failed to parse order history: $e");
      return [];
    }
  }

  /// Delete order by ID
  Future<void> deleteOrderFromHistory(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final orders = await getOrderHistory();

    orders.removeWhere((o) => o.id == orderId);

    await prefs.setString(
      _orderHistoryKey,
      jsonEncode(orders.map((e) => e.toJson()).toList()),
    );
  }

  /// Clear all history
  Future<void> clearOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_orderHistoryKey);
  }

  /// Count
  Future<int> getOrderHistoryCount() async {
    final orders = await getOrderHistory();
    return orders.length;
  }

  // CLEAR ALL DATA
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
