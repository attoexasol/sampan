import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sampan/data/service/network_caller.dart';
import 'package:sampan/data/service/local_store.dart';
import 'package:sampan/data/models/user_profile.dart';
import '../../data/service/utils.dart';
import '../../routes/app_routes.dart';
import '../../controller/profile_controller.dart';
import '../login/login_binding.dart';
import '../login/login_view.dart';

class SignupController extends GetxController {
  // -----------------------------------------------------
  // 🧱 TEXT CONTROLLERS
  // -----------------------------------------------------
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipCodeController = TextEditingController();
  final referralCodeController = TextEditingController();

  // -----------------------------------------------------
  // 🔑 FORM KEY & STATE
  // -----------------------------------------------------
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // -----------------------------------------------------
  // 👁️ PASSWORD VISIBILITY TOGGLE
  // -----------------------------------------------------
  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  // -----------------------------------------------------
  // 🚀 SIGNUP FUNCTION
  // -----------------------------------------------------
  Future<void> signup() async {
    if (!formKey.currentState!.validate()) {
      _err('Please fill in all required fields');
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _err('Please enter a valid email address');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _err('Passwords do not match');
      return;
    }

    final fullName =
    "${firstNameController.text.trim()} ${lastNameController.text.trim()}".trim();

    final addressLine =
        "${streetController.text.trim()}, ${cityController.text.trim()}, ${stateController.text.trim()}, ${zipCodeController.text.trim()}";

    final referralCode = referralCodeController.text.trim();
    if (referralCode.isEmpty) {
      debugPrint('[Signup] referralCode empty or skipped');
    } else {
      debugPrint('[Signup] referralCode entered: $referralCode');
    }

    final requestedBody = {
      "api_token": ApiConfig.apiToken,
      "customerName": fullName,
      "customerTel": phoneController.text.trim(),
      "customerEmail": emailController.text.trim(),
      "customerPassword": passwordController.text,
      "customerAddress": addressLine,
      "customerNotes": "New customer registration from Sampan app",
    };
    if (referralCode.isNotEmpty) {
      requestedBody["referralCode"] = referralCode;
    }

    isLoading.value = true;

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.accountCreate,
        body: requestedBody,
      );

      if (response.isSuccess) {
        final body = response.body ?? {};
        debugPrint('[Signup] account created successfully');
        if (referralCode.isNotEmpty && (body['referralError'] != null || body['ReferralError'] != null)) {
          debugPrint('[Signup] referral code may be invalid but signup succeeded');
        }
        // Registration returns "CustomerID": 3492; fallback to "cid" if present
        final customerId = (body['CustomerID'] ?? body['cid'])?.toString().trim() ?? '';
        final email = emailController.text.trim();
        final phoneStr = phoneController.text.trim();
        // api_token is same for every user; customerID is per-user and used for all API calls
        await LocalStore.instance.saveSession(
          customerId: customerId,
          apiToken: ApiConfig.apiToken,
          name: fullName,
          email: email,
          phone: phoneStr,
          address: addressLine,
          instructions: '',
        );

        await LocalStore.instance.saveCustomerIdFromResponse(body);
        final profile = UserProfile(
          fullName: fullName,
          email: email,
          phone: phoneStr,
          address: addressLine,
          name: fullName,
        );
        await LocalStore.instance.saveUserProfile(profile);
        await LocalStore.instance.setLoggedIn(true);

        final session = Get.find<ProfileController>();
        await session.setSession(
          name: fullName,
          email: email,
          customerId: customerId,
          apiToken: ApiConfig.apiToken,
          phone: phoneStr,
          address: addressLine,
        );

        Get.snackbar(
          'Success',
          'Account created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        _clearForm();
        Get.offAllNamed(Routes.HOME);
      } else {
        _err(response.errorMessage ?? 'Signup failed. Please try again.');
      }
    } catch (e) {
      _err(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // -----------------------------------------------------
  // 🧼 CLEAR FORM
  // -----------------------------------------------------
  void _clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    zipCodeController.clear();
    referralCodeController.clear();
  }

  // -----------------------------------------------------
  // 🔁 NAVIGATION
  // -----------------------------------------------------
  void navigateToLogin() =>
      Get.to(() => const LoginView(), binding: LoginBinding());

  void navigateToHome() => Get.offAllNamed(Routes.HOME);

  // -----------------------------------------------------
  // 🧹 CLEANUP (Dispose controllers properly)
  // -----------------------------------------------------
  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    referralCodeController.dispose();
    super.onClose();
  }

  // -----------------------------------------------------
  // ✅ FEEDBACK HELPERS
  // -----------------------------------------------------
  void _ok(String msg) => Get.snackbar(
    'Success 🎉',
    msg,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );

  void _err(String msg) => Get.snackbar(
    'Error',
    msg,
    backgroundColor: Colors.red,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );
}
