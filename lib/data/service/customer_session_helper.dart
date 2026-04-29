// Centralized customer ID session handling.
// All API flows that need customerID/cid should use getValidCustomerId() or requireCustomerIdOrRedirect().

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'local_store.dart';
import 'safe_snackbar.dart';
import '../../routes/app_routes.dart';

class CustomerSessionHelper {
  CustomerSessionHelper._();

  /// Returns a valid customer ID from the saved session, or null if missing/invalid.
  /// Use when you only need to check or read the ID (e.g. display, conditional fetch).
  static Future<String?> getValidCustomerId() async {
    return LocalStore.instance.getValidCustomerId();
  }

  /// When an API or screen action requires a customer ID:
  /// - If a valid ID exists, returns it (trimmed string).
  /// - If missing/null/empty/"null": shows snackbar, navigates to Sign Up screen, and returns null.
  /// Call sites must abort the operation when null is returned.
  /// [featureName] is used for [AuthGuard] debug logs only.
  static Future<String?> requireCustomerIdOrRedirect([String? featureName]) async {
    final name = featureName ?? 'unknown';
    debugPrint('[AuthGuard] Checking customer session for: $name');
    final cid = await LocalStore.instance.getValidCustomerId();
    if (LocalStore.isValidCustomerId(cid)) {
      debugPrint('[AuthGuard] customerId found: ${cid!.trim()}');
      return cid.trim();
    }
    debugPrint('[AuthGuard] Missing customerId. Redirecting to Sign Up.');
    SafeSnackbar.show(
      'Account required',
      'Please SignUp/ Sign In',
      isError: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));
    Get.toNamed(Routes.SIGNUP);
    return null;
  }
}
