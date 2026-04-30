import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sampan/data/service/network_caller.dart';
import 'package:sampan/data/service/local_store.dart';
import 'package:sampan/data/service/safe_snackbar.dart';
import 'package:sampan/data/service/utils.dart'; // Urls, ApiConfig
import 'package:sampan/routes/app_routes.dart';
import 'package:sampan/controller/profile_controller.dart';
import 'package:sampan/screens/home_screen.dart';
import 'package:sampan/services/auth/firebase_login_api.dart';
import 'package:sampan/services/auth/google_auth_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  /// Google Sign-In via Firebase Auth. CleanCloud session is applied after backend links the account.
  Future<void> loginWithGoogle() async {
    if (isLoading.value) {
      debugPrint(
        '[GOOGLE_AUTH] Early return: loginWithGoogle() ignored (already loading)',
      );
      return;
    }
    debugPrint('[GOOGLE_AUTH] loginWithGoogle() started');
    isLoading.value = true;
    try {
      final result = await GoogleAuthService.instance.signInWithGoogle();
      if (!result.success && result.message.isEmpty) {
        debugPrint('[GOOGLE_AUTH] USER_CANCELLED');
        return; // user cancelled
      }
      if (!result.success) {
        debugPrint(
          '[GOOGLE_AUTH] Early return: loginWithGoogle() failed — ${result.message}',
        );
        SafeSnackbar.show('Google Sign-In', result.message, isError: true);
        return;
      }

      final idToken = result.idToken;
      if (idToken == null || idToken.isEmpty) {
        SafeSnackbar.show(
          'Google Sign-In',
          'Missing Firebase ID token.',
          isError: true,
        );
        return;
      }

      final apiResponse = await FirebaseLoginApi.sendFirebaseToken(idToken);
      final apiBody = apiResponse.body ?? <String, dynamic>{};
      if (!apiResponse.isSuccess) {
        SafeSnackbar.show(
          'Google Sign-In',
          apiResponse.errorMessage ?? 'Backend login failed.',
          isError: true,
        );
        return;
      }

      final parsed = FirebaseLoginApi.parseFirebaseLoginResponse(
        apiBody,
        firebaseEmailFallback: result.email,
        firebaseDisplayNameFallback: result.displayName,
      );
      if (parsed == null) {
        SafeSnackbar.show(
          'Google Sign-In',
          'Invalid response from server.',
          isError: true,
        );
        return;
      }

      final bridge = await FirebaseLoginApi.bridgeToCleanCloud(parsed);
      if (!bridge.isSuccess) {
        SafeSnackbar.show(
          'Google Sign-In',
          bridge.errorMessage ?? 'Sign-in failed. Please try again.',
          isError: true,
        );
        return;
      }

      Get.offAll(() => const HomeScreen());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint(
          '[GOOGLE_AUTH] Google sign in successful, showing snackbar',
        );
        SafeSnackbar.show(
          'Success',
          bridge.isCreated
              ? 'Account created with Google'
              : 'Google Sign-In Successful',
          isError: false,
        );
      });
    } catch (e, st) {
      debugPrint('[GOOGLE_AUTH] loginWithGoogle() unexpected exception: $e');
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
      SafeSnackbar.show('Error', e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🚀 LOGIN FUNCTION
  Future<void> login() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      SafeSnackbar.show('Error', 'Please enter valid credentials', isError: true);
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
        // Login returns cid; fallback to CustomerID. Same identity as signup's CustomerID.
        final customerId = (body['cid'] ?? body['CustomerID'])?.toString().trim() ?? '';
        debugPrint('[CustomerSession] login returned cid: $customerId');

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

        debugPrint('[Login] Logged in successfully');
        SafeSnackbar.show('Success', 'Logged in successfully', isError: false);

        Get.offAllNamed(Routes.HOME);
      } else {
        SafeSnackbar.show(
          'Login Failed',
          body['Error']?.toString() ?? response.errorMessage ?? 'Invalid credentials.',
          isError: true,
        );
      }
    } catch (e) {
      SafeSnackbar.show('Error', e.toString(), isError: true);
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
