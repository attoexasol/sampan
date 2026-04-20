import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sampan/controller/profile_controller.dart';
import 'package:sampan/data/models/user_profile.dart';
import 'package:sampan/data/service/local_store.dart';
import 'package:sampan/data/service/network_caller.dart';
import 'package:sampan/data/service/utils.dart';
import 'package:sampan/services/auth/firebase_id_token.dart';
import 'package:sampan/services/auth/google_auth_log.dart';

/// POST Firebase ID token to your backend (`Urls.sendGoogleToken`) and persist session.
class FirebaseLoginApi {
  FirebaseLoginApi._();

  /// `POST` JSON `{ "token": "<Firebase Auth ID token>" }`.
  ///
  /// Pass the **same** string returned from [GoogleAuthService.signInWithGoogle] (already
  /// from [getFirebaseIdToken] with refresh). Do **not** call [getFirebaseIdToken] again here:
  /// a second `forceRefresh` would mint a **new** JWT and your logs would no longer match
  /// the token shown right after sign-in.
  static Future<NetworkResponse> sendFirebaseToken(String firebaseIdToken) async {
    try {
      validateFirebaseIdTokenForBackend(firebaseIdToken);
      if (kDebugMode) {
        logGoogleAuthJwtSnapshot(
          'firebase-login HTTP (POST body = sign-in Firebase ID token)',
          firebaseIdToken,
        );
        logGoogleAuthPostBodyContainsToken(firebaseIdToken);
      }
      return NetworkCaller.postRequest(
        url: Urls.sendGoogleToken,
        body: <String, dynamic>{'token': firebaseIdToken},
      );
    } on FirebaseIdTokenException catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.message,
      );
    }
  }

  /// After a successful HTTP response, parse `{ "status", "user": { ... } }` and mirror email login storage.
  /// Returns `null` on success, or a short error message for the UI.
  static Future<String?> persistGoogleBackendSession(
    Map<String, dynamic> body, {
    required String firebaseEmail,
    required String? firebaseDisplayName,
  }) async {
    final dynamic userRaw = body['user'];
    if (userRaw is! Map) {
      return 'Invalid response: missing user';
    }
    final user = Map<String, dynamic>.from(userRaw);
    final customerId =
        (user['id'] ?? user['firebase_uid'])?.toString().trim() ?? '';
    if (!LocalStore.isValidCustomerId(customerId)) {
      return 'Invalid response: missing user id';
    }

    var email = user['email']?.toString().trim() ?? '';
    if (email.isEmpty) {
      email = firebaseEmail.trim();
    }
    if (email.isEmpty) {
      return 'Invalid response: missing email';
    }

    var name = user['name']?.toString().trim() ?? '';
    if (name.isEmpty) {
      final d = firebaseDisplayName?.trim();
      name = (d != null && d.isNotEmpty) ? d : _nameFromEmail(email);
    }

    final addressToSave = await LocalStore.instance.getCustomerAddress();
    final phoneToSave = await LocalStore.instance.getUserPhone();
    final instructionsToSave =
        await LocalStore.instance.getDeliveryInstructions();

    await LocalStore.instance.saveSession(
      customerId: customerId,
      apiToken: ApiConfig.apiToken,
      name: name,
      email: email,
      phone: phoneToSave,
      address: addressToSave,
      instructions: instructionsToSave,
    );
    await LocalStore.instance.setLoggedIn(true);

    final profile = UserProfile(
      fullName: name,
      email: email,
      phone: phoneToSave ?? '',
      address: addressToSave ?? '',
      name: name,
    );
    await LocalStore.instance.saveUserProfile(profile);

    if (Get.isRegistered<ProfileController>()) {
      await Get.find<ProfileController>().setSession(
        name: name,
        email: email,
        customerId: customerId,
        apiToken: ApiConfig.apiToken,
        phone: phoneToSave,
        address: addressToSave,
      );
    }

    return null;
  }

  static String _nameFromEmail(String email) {
    if (email.trim().isEmpty) return 'User';
    final beforeAt = email.split('@').first.trim();
    if (beforeAt.isEmpty) return 'User';
    final withSpaces = beforeAt.replaceAll(RegExp(r'[._]'), ' ');
    final words = withSpaces.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return 'User';
    final capitalized = words
        .map((w) => w.length > 1
            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
            : w.toUpperCase())
        .join(' ');
    return capitalized.isNotEmpty ? capitalized : 'User';
  }
}
