import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sampan/data/service/local_store.dart';
import 'package:sampan/data/models/user_profile.dart';
import 'package:sampan/routes/app_routes.dart';

class ProfileController extends GetxController {
  /// Reactive observables for UI binding
  final name = ''.obs;
  final email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshProfile(); // auto-load saved info
  }

  /// ✅ Refresh data from SharedPreferences
  Future<void> refreshProfile() async {
    try {
      final profile = await LocalStore.instance.getUserProfile();
      if (profile != null) {
        name.value = profile.fullName;
        email.value = profile.email;
      } else {
        name.value = '';
        email.value = '';
      }
    } catch (e) {
      debugPrint("⚠️ Error loading profile: $e");
    }
  }

  /// ✅ Save updated info locally and refresh reactive values
  Future<void> updateProfile(String newName, String newEmail) async {
    try {
      final existing = await LocalStore.instance.getUserProfile();
      final updated = UserProfile(
        fullName: newName,
        email: newEmail,
        phone: existing?.phone ?? '',
        address: existing?.address ?? '',
        name: newName,
      );

      await LocalStore.instance.saveUserProfile(updated);
      await refreshProfile();

      Get.snackbar(
        'Profile Updated ✅',
        'Your profile information has been updated.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint("⚠️ Error updating profile: $e");
      Get.snackbar(
        'Error',
        'Failed to update profile.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// ✅ Logout — clears all local data and resets app
  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await LocalStore.instance.clearAll(); // 🧹 clear SharedPreferences + SecureStorage
      name.value = '';
      email.value = '';

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
