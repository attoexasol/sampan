import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sampan/data/service/local_store.dart';
import 'package:sampan/data/models/user_profile.dart';
import 'package:sampan/routes/app_routes.dart';

class ProfileController extends GetxController {
  static const String defaultUserName = 'User Name';
  static const String defaultUserEmail = 'example@gmail.com';

  /// Reactive observables for UI binding (single source of truth for session display)
  final name = defaultUserName.obs;
  final email = defaultUserEmail.obs;
  final customerId = ''.obs;
  final apiToken = ''.obs;
  final phone = ''.obs;
  final address = ''.obs;
  final isLoggedIn = false.obs;

  /// Expose for Obx: userName / userEmail (same as name/email)
  RxString get userName => name;
  RxString get userEmail => email;

  @override
  void onInit() {
    super.onInit();
    loadFromStorage();
  }

  /// Load name, email, customerId, apiToken, phone, address from LocalStore so they update dynamically across the app.
  Future<void> loadFromStorage() async {
    try {
      final storedName = await LocalStore.instance.getUserName();
      final storedEmail = await LocalStore.instance.getUserEmail();
      final savedCid = await LocalStore.instance.getCustomerId();
      final savedToken = await LocalStore.instance.getApiToken();
      final storedAddress = await LocalStore.instance.getCustomerAddress();
      final loggedIn = await LocalStore.instance.isLoggedIn();

      if (storedName != null && storedName.trim().isNotEmpty) {
        name.value = storedName.trim();
      } else {
        name.value = defaultUserName;
      }
      if (storedEmail != null && storedEmail.trim().isNotEmpty) {
        email.value = storedEmail.trim();
      } else {
        email.value = defaultUserEmail;
      }

      customerId.value = savedCid?.trim() ?? '';
      apiToken.value = savedToken?.trim() ?? '';
      address.value = storedAddress?.trim() ?? '';
      isLoggedIn.value = loggedIn;

      final profile = await LocalStore.instance.getUserProfile();
      if (profile != null) {
        phone.value = profile.phone;
      } else {
        final storedPhone = await LocalStore.instance.getUserPhone();
        phone.value = storedPhone?.trim() ?? '';
      }
    } catch (e) {
      debugPrint("⚠️ Error in loadFromStorage: $e");
      name.value = defaultUserName;
      email.value = defaultUserEmail;
    }
  }

  /// Alias for loadFromStorage (keep existing callers working)
  Future<void> loadFromLocalStore() async => loadFromStorage();

  /// Set session: update Rx first (instant UI), then persist. Name/email/address/phone/customerID stored locally and drive the app.
  Future<void> setSession({
    required String name,
    required String email,
    required String customerId,
    required String apiToken,
    String? phone,
    String? address,
  }) async {
    final nameToSet = (name.trim().isNotEmpty) ? name.trim() : defaultUserName;
    final emailToSet = (email.trim().isNotEmpty) ? email.trim() : defaultUserEmail;
    this.name.value = nameToSet;
    this.email.value = emailToSet;
    this.customerId.value = customerId;
    this.apiToken.value = apiToken;
    if (phone != null) this.phone.value = phone.trim();
    if (address != null) this.address.value = address.trim();
    isLoggedIn.value = true;
    await LocalStore.instance.saveSession(
      customerId: customerId,
      apiToken: apiToken,
      name: nameToSet,
      email: emailToSet,
      phone: phone?.trim(),
      address: address?.trim(),
    );
    await LocalStore.instance.setLoggedIn(true);
  }

  /// Set user session (alias for setSession).
  Future<void> setUser({
    required String nameValue,
    required String emailValue,
    required String customerId,
    required String apiToken,
  }) async => setSession(
        name: nameValue,
        email: emailValue,
        customerId: customerId,
        apiToken: apiToken,
      );

  /// Update session (alias for setSession).
  Future<void> updateSession({
    required String nameValue,
    required String emailValue,
    required String customerId,
    required String apiToken,
  }) async => setSession(
        name: nameValue,
        email: emailValue,
        customerId: customerId,
        apiToken: apiToken,
      );

  /// Clear session: enforce defaults, then clear storage. Call on logout.
  Future<void> clearSession() async {
    name.value = defaultUserName;
    email.value = defaultUserEmail;
    customerId.value = '';
    apiToken.value = '';
    phone.value = '';
    address.value = '';
    isLoggedIn.value = false;
    await LocalStore.instance.clearSession();
  }

  /// Alias for clearSession.
  Future<void> clearUser() async => clearSession();

  /// Refresh name, email, customerId, address, phone from LocalStore so UI updates dynamically.
  Future<void> refreshProfile() async {
    try {
      await loadFromStorage();
    } catch (e) {
      debugPrint("⚠️ Error loading profile: $e");
    }
  }

  /// ✅ Save updated info locally and refresh reactive values. Returns false on failure.
  Future<bool> updateProfile(
    String newName,
    String newEmail,
    String newPhone, {
    bool showFeedback = true,
  }) async {
    try {
      final existing = await LocalStore.instance.getUserProfile();
      final updated = UserProfile(
        fullName: newName,
        email: newEmail,
        phone: newPhone,
        address: existing?.address ?? '',
        name: newName,
      );

      await LocalStore.instance.saveUserProfile(updated);
      await LocalStore.instance.saveSession(name: newName, email: newEmail);
      await refreshProfile();

      if (showFeedback) {
        Get.snackbar(
          'Profile Updated ✅',
          'Your profile information has been updated.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return true;
    } catch (e) {
      debugPrint("⚠️ Error updating profile: $e");
      if (showFeedback) {
        Get.snackbar(
          'Error',
          'Failed to update profile.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return false;
    }
  }

  /// ✅ Logout — clears all local data and resets app
  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await clearSession();
      await LocalStore.instance.clearAll(); // 🧹 clear SharedPreferences

      // Navigate back to login
      Get.offAllNamed(Routes.LOGIN);

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint("⚠️ Logout failed: $e");
      Get.snackbar(
        'Error',
        'Logout failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
