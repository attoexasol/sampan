import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sampan/data/service/network_caller.dart';
import 'package:sampan/data/service/local_store.dart';
import 'package:sampan/data/service/safe_snackbar.dart';
import 'package:sampan/data/models/user_profile.dart';
import 'package:sampan/data/service/utils.dart';
import 'package:sampan/routes/app_routes.dart';
import 'package:sampan/controller/profile_controller.dart';
import 'package:sampan/screens/home_screen.dart';
import 'package:sampan/services/auth/firebase_login_api.dart';
import 'package:sampan/services/auth/google_auth_service.dart';
import '../login/login_binding.dart';
import '../login/login_view.dart';

class SignupController extends GetxController {
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

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  void togglePasswordVisibility() => obscurePassword.value = !obscurePassword.value;
  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.value = !obscureConfirmPassword.value;

  /// Same Firebase Google flow as [LoginController.loginWithGoogle]; used from signup screen.
  Future<void> signupWithGoogle() async {
    if (isLoading.value) {
      debugPrint(
        '[GOOGLE_AUTH] Early return: signupWithGoogle() ignored (already loading)',
      );
      return;
    }
    debugPrint('[GOOGLE_AUTH] signupWithGoogle() started');
    isLoading.value = true;
    try {
      final result = await GoogleAuthService.instance.signInWithGoogle();
      if (!result.success && result.message.isEmpty) {
        debugPrint('[GOOGLE_AUTH] USER_CANCELLED');
        return;
      }
      if (!result.success) {
        debugPrint(
          '[GOOGLE_AUTH] Early return: signupWithGoogle() failed — ${result.message}',
        );
        _err(result.message);
        return;
      }

      final idToken = result.idToken;
      if (idToken == null || idToken.isEmpty) {
        _err('Missing Firebase ID token.');
        return;
      }

      final apiResponse = await FirebaseLoginApi.sendFirebaseToken(idToken);
      final apiBody = apiResponse.body ?? <String, dynamic>{};
      if (!apiResponse.isSuccess) {
        _err(apiResponse.errorMessage ?? 'Backend login failed.');
        return;
      }

      final persistError = await FirebaseLoginApi.persistGoogleBackendSession(
        apiBody,
        firebaseEmail: result.email ?? '',
        firebaseDisplayName: result.displayName,
      );
      if (persistError != null) {
        _err(persistError);
        return;
      }

      Get.offAll(() => const HomeScreen());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint(
          '[GOOGLE_AUTH] Google sign in successful, showing snackbar',
        );
        SafeSnackbar.show(
          'Success',
          'Google Sign-In Successful',
          isError: false,
        );
      });
    } catch (e, st) {
      debugPrint('[GOOGLE_AUTH] signupWithGoogle() unexpected exception: $e');
      debugPrint('[GOOGLE_AUTH] full exception: $e');
      debugPrint('[GOOGLE_AUTH] stack trace:\n$st');
      if (e is FirebaseAuthException) {
        debugPrint(
          '[GOOGLE_AUTH] FirebaseAuthException code=${e.code} message=${e.message}',
        );
      }
      if (e is PlatformException) {
        debugPrint(
          '[GOOGLE_AUTH] PlatformException code=${e.code} message=${e.message} details=${e.details}',
        );
      }
      _err(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

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
        '${firstNameController.text.trim()} ${lastNameController.text.trim()}'.trim();
    final addressLine =
        '${streetController.text.trim()}, ${cityController.text.trim()}, ${stateController.text.trim()}, ${zipCodeController.text.trim()}';
    final referralCode = referralCodeController.text.trim();

    final requestedBody = <String, dynamic>{
      'api_token': ApiConfig.apiToken,
      'customerName': fullName,
      'customerTel': phoneController.text.trim(),
      'customerEmail': emailController.text.trim(),
      'customerPassword': passwordController.text,
      'customerAddress': addressLine,
      'customerNotes': 'New customer registration from Sampan app',
    };
    if (referralCode.isNotEmpty) {
      requestedBody['promoCode'] = referralCode;
    }

    isLoading.value = true;

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.accountCreate,
        body: requestedBody,
      );

      final body = response.body ?? {};
      final errorMsg = body['Error']?.toString().trim();
      final hasErrorInBody = errorMsg != null && errorMsg.isNotEmpty;

      if (hasErrorInBody) {
        debugPrint('[Signup] API returned error: $errorMsg');
        final isEmailExists = errorMsg.toLowerCase().contains('already exists');
        if (isEmailExists) {
          debugPrint('[Signup] Email already exists');
          _err('An account already exists with this email. Please sign in instead.');
        } else {
          _err(errorMsg);
        }
        return;
      }

      final customerId =
          (body['CustomerID'] ?? body['cid'])?.toString().trim() ?? '';
      debugPrint('[CustomerSession] signup returned CustomerID: $customerId');
      final isSuccess = response.isSuccess &&
          (body['Success'] == 'True' || body['Success'] == true || customerId.isNotEmpty);

      if (!isSuccess || customerId.isEmpty) {
        _err(response.errorMessage ?? 'Signup failed. Please try again.');
        return;
      }

      debugPrint('[Signup] Account created successfully');
      final email = emailController.text.trim();
      final phoneStr = phoneController.text.trim();

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

      if (Get.isRegistered<ProfileController>()) {
        final session = Get.find<ProfileController>();
        await session.setSession(
          name: fullName,
          email: email,
          customerId: customerId,
          apiToken: ApiConfig.apiToken,
          phone: phoneStr,
          address: addressLine,
        );
      }

      debugPrint('[Signup] Showing safe snackbar');
      SafeSnackbar.show('Success', 'Account created successfully', isError: false);
      _clearForm();
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      _err(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

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

  void navigateToLogin() => Get.to(() => const LoginView(), binding: LoginBinding());

  void _err(String msg) =>
      SafeSnackbar.show('Error', msg, isError: true);

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
}
