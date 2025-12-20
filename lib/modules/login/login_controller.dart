import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sampan/data/service/network_caller.dart';
import 'package:sampan/data/service/local_store.dart';
import 'package:sampan/routes/app_routes.dart';

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

    try {
      // ✅ Use JSON POST, not form
      final response = await NetworkCaller.postRequest(
        url: "https://cleancloudapp.com/api/loginCustomer",
        body: {
          "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
          "customerEmail": emailController.text.trim(),
          "customerPassword": passwordController.text,
        },
      );

      final body = response.body ?? {};

      if (response.isSuccess && body['Success'] == 'True') {
        // ✅ Save response data
        debugPrint('🔍 Login: Response body: $body');
        debugPrint('🔍 Login: Response body type: ${body.runtimeType}');
        debugPrint('🔍 Login: Response body keys: ${body.keys.toList()}');
        
        // Save API response first
        await LocalStore.instance.saveApiResponse(body);
        
        // Extract and save customer ID
        await LocalStore.instance.saveCustomerIdFromResponse(body);
        
        // Wait a bit to ensure async operations complete
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Verify customer ID was saved
        final savedCustomerId = await LocalStore.instance.getCustomerId();
        debugPrint('🔍 Login: Verification - Saved customer ID: $savedCustomerId');
        
        // Verify API response was saved
        final savedResponse = await LocalStore.instance.getLastApiResponse();
        debugPrint('🔍 Login: Verification - Saved API response exists: ${savedResponse != null}');
        
        await LocalStore.instance.setLoggedIn(true);
        
        final isLoggedIn = await LocalStore.instance.isLoggedIn();
        debugPrint('🔍 Login: Verification - Is logged in flag: $isLoggedIn');
        
        // Debug: Print all stored data
        await LocalStore.instance.debugPrintAllStoredData();

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
  void navigateToHome() => Get.offAllNamed(Routes.HOME);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
