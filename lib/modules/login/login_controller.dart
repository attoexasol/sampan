import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sampan/data/service/network_caller.dart';
import 'package:sampan/data/service/local_store.dart';
import 'package:sampan/data/service/utils.dart'; // Urls, ApiConfig
import 'package:sampan/routes/app_routes.dart';
import 'package:sampan/controller/profile_controller.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  /// 🚀 LOGIN FUNCTION
  Future<void> login() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      Get.snackbar('Error', 'Please enter valid credentials',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    final email = emailController.text.trim();
    final requestBody = {
      'api_token': ApiConfig.apiToken,
      'customerEmail': email,
      'customerPassword': passwordController.text,
    };

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.logInAcc,
        body: requestBody,
      );

      final body = response.body ?? {};

      if (response.isSuccess && body['Success'] == 'True') {
        final customerId = body['cid']?.toString() ?? '';

        // Name: 1) from API, 2) from storage, 3) derive from email
        String nameToSave = 'User Name';
        final apiName = body['customerName'] ?? body['CustomerName'] ?? body['name'] ?? body['Name'];
        if (apiName != null && apiName.toString().trim().isNotEmpty) {
          nameToSave = apiName.toString().trim();
        } else {
          final existingName = await LocalStore.instance.getUserName();
          if (existingName != null && existingName.trim().isNotEmpty) {
            nameToSave = existingName.trim();
          } else {
            nameToSave = _displayNameFromEmail(email);
          }
        }

        // Address & phone: from API if present, else keep existing local values
        String? addressToSave = body['customerAddress']?.toString().trim();
        if (addressToSave == null || addressToSave.isEmpty) {
          addressToSave = await LocalStore.instance.getCustomerAddress();
        }
        String? phoneToSave = body['customerTel']?.toString().trim() ?? body['customerPhone']?.toString().trim();
        if (phoneToSave == null || phoneToSave.isEmpty) {
          phoneToSave = await LocalStore.instance.getUserPhone();
        }
        final instructionsToSave = await LocalStore.instance.getDeliveryInstructions();

        // Save all user info locally so it updates dynamically across the app (customerID is per-user; api_token is same for all)
        await LocalStore.instance.saveSession(
          customerId: customerId,
          apiToken: ApiConfig.apiToken,
          name: nameToSave,
          email: email,
          phone: phoneToSave,
          address: addressToSave,
          instructions: instructionsToSave,
        );
        await LocalStore.instance.saveCustomerIdFromResponse(body);
        await LocalStore.instance.setLoggedIn(true);

        final session = Get.find<ProfileController>();
        await session.setSession(
          name: nameToSave,
          email: email,
          customerId: customerId,
          apiToken: ApiConfig.apiToken,
          phone: phoneToSave,
          address: addressToSave,
        );

        Get.snackbar('Success 🎉', 'Login successful!',
            backgroundColor: Colors.green, colorText: Colors.white);

        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          'Login Failed',
          body['Error'] ?? response.errorMessage ?? 'Invalid credentials.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }




  // ✅ Optional quick helper (used in LoginView “Back to Order”)
  static String _displayNameFromEmail(String email) {
    if (email.trim().isEmpty) return 'User Name';
    final beforeAt = email.split('@').first.trim();
    if (beforeAt.isEmpty) return 'User Name';
    final withSpaces = beforeAt.replaceAll(RegExp(r'[._]'), ' ');
    final words = withSpaces.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return 'User Name';
    final capitalized = words
        .map((w) => w.length > 1
            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
            : w.toUpperCase())
        .join(' ');
    return capitalized.isNotEmpty ? capitalized : 'User Name';
  }

  void navigateToHome() => Get.offAllNamed(Routes.HOME);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
