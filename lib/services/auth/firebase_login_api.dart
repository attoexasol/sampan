import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sampan/controller/profile_controller.dart';
import 'package:sampan/data/models/user_profile.dart';
import 'package:sampan/data/service/local_store.dart';
import 'package:sampan/data/service/network_caller.dart';
import 'package:sampan/data/service/utils.dart';
import 'package:sampan/services/auth/firebase_id_token.dart';
import 'package:sampan/services/auth/google_auth_log.dart';

/// Result of `/auth/firebase-login` — backend tells us whether the Firebase user
/// is new (`created`) or already linked (`exists`).
enum FirebaseLoginStatus { created, exists, unknown }

/// Parsed `user` block from `/auth/firebase-login`.
class FirebaseLoginParsedUser {
  const FirebaseLoginParsedUser({
    required this.status,
    required this.firebaseUid,
    required this.email,
    required this.name,
    required this.phone,
    required this.cleanCloudPassword,
  });

  final FirebaseLoginStatus status;
  final String firebaseUid;
  final String email;
  final String name;
  final String phone;

  /// Plaintext password the app must send to CleanCloud
  /// (`/api/addCustomer` on created, `/api/loginCustomer` on exists).
  /// Derived from [firebaseUid] so the same value is reproduced on every sign-in.
  final String cleanCloudPassword;
}

/// Outcome of [FirebaseLoginApi.bridgeToCleanCloud].
class CleanCloudBridgeResult {
  const CleanCloudBridgeResult._({
    required this.isSuccess,
    required this.status,
    this.errorMessage,
  });

  final bool isSuccess;
  final FirebaseLoginStatus status;
  final String? errorMessage;

  bool get isCreated => status == FirebaseLoginStatus.created;
  bool get isExists => status == FirebaseLoginStatus.exists;

  factory CleanCloudBridgeResult.ok(FirebaseLoginStatus status) =>
      CleanCloudBridgeResult._(isSuccess: true, status: status);

  factory CleanCloudBridgeResult.failure(
    FirebaseLoginStatus status,
    String message,
  ) =>
      CleanCloudBridgeResult._(
        isSuccess: false,
        status: status,
        errorMessage: message,
      );
}

/// Bridges Firebase Google sign-in to CleanCloud:
/// 1. POST Firebase ID token to our internal server (`/auth/firebase-login`).
/// 2. Use the response to call CleanCloud `/api/addCustomer` (created) or
///    `/api/loginCustomer` (exists), then persist the session locally.
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

  /// Parse `{ "status", "user": { ... } }` returned by `/auth/firebase-login`.
  /// `firebase*Fallback` values are used when the server omits a field.
  /// Returns `null` if the response is unusable.
  static FirebaseLoginParsedUser? parseFirebaseLoginResponse(
    Map<String, dynamic> body, {
    required String? firebaseEmailFallback,
    required String? firebaseDisplayNameFallback,
  }) {
    final statusStr = body['status']?.toString().trim().toLowerCase() ?? '';
    final FirebaseLoginStatus status;
    switch (statusStr) {
      case 'created':
        status = FirebaseLoginStatus.created;
        break;
      case 'exists':
        status = FirebaseLoginStatus.exists;
        break;
      default:
        status = FirebaseLoginStatus.unknown;
    }

    final dynamic userRaw = body['user'];
    if (userRaw is! Map) return null;
    final user = Map<String, dynamic>.from(userRaw);

    final firebaseUid = user['firebase_uid']?.toString().trim() ?? '';

    var email = user['email']?.toString().trim() ?? '';
    if (email.isEmpty) email = firebaseEmailFallback?.trim() ?? '';

    var name = user['name']?.toString().trim() ?? '';
    if (name.isEmpty) {
      final d = firebaseDisplayNameFallback?.trim();
      name = (d != null && d.isNotEmpty) ? d : _nameFromEmail(email);
    }

    final phone = user['phone']?.toString().trim() ?? '';

    // CleanCloud's /loginCustomer needs PLAINTEXT (it bcrypt-compares server-side),
    // and bcrypt is one-way — the "password" field returned on status="exists"
    // (e.g. "$2b$10$...") cannot be reversed in the app. We therefore derive a
    // deterministic plaintext from `firebase_uid` and use it on BOTH branches:
    //   - status="created": addCustomer  with customerPassword = firebase_uid
    //   - status="exists" : loginCustomer with customerPassword = firebase_uid
    // firebase_uid is stable per Google account and identical on every sign-in,
    // so the same value is presented at create-time and at every later login.
    final cleanCloudPassword = firebaseUid;

    return FirebaseLoginParsedUser(
      status: status,
      firebaseUid: firebaseUid,
      email: email,
      name: name,
      phone: phone,
      cleanCloudPassword: cleanCloudPassword,
    );
  }

  /// Calls CleanCloud and saves the session locally based on [parsed.status].
  ///
  /// - [parsed.status] == created → `POST /api/addCustomer` then persist `CustomerID`.
  /// - [parsed.status] == exists  → `POST /api/loginCustomer` then persist `cid`.
  ///
  /// [referralCode] is only applied on the create path. [addressOverride] /
  /// [notesOverride] let callers supply richer values (otherwise defaults are used).
  static Future<CleanCloudBridgeResult> bridgeToCleanCloud(
    FirebaseLoginParsedUser parsed, {
    String? referralCode,
    String? addressOverride,
    String? notesOverride,
  }) async {
    if (parsed.email.isEmpty) {
      return CleanCloudBridgeResult.failure(
        parsed.status,
        'Invalid response: missing email',
      );
    }
    if (parsed.cleanCloudPassword.isEmpty) {
      return CleanCloudBridgeResult.failure(
        parsed.status,
        'Invalid response: missing firebase_uid',
      );
    }

    if (parsed.status == FirebaseLoginStatus.created) {
      return _addCustomerOnCleanCloud(
        parsed,
        referralCode: referralCode,
        addressOverride: addressOverride,
        notesOverride: notesOverride,
      );
    }
    if (parsed.status == FirebaseLoginStatus.exists) {
      return _loginCustomerOnCleanCloud(parsed);
    }
    return CleanCloudBridgeResult.failure(
      parsed.status,
      'Unexpected response from server. Please try again.',
    );
  }

  // ────────────────────────── status: created ──────────────────────────

  static Future<CleanCloudBridgeResult> _addCustomerOnCleanCloud(
    FirebaseLoginParsedUser parsed, {
    String? referralCode,
    String? addressOverride,
    String? notesOverride,
  }) async {
    final addressLine = (addressOverride?.trim().isNotEmpty ?? false)
        ? addressOverride!.trim()
        : 'Pending address update, please edit profile';
    final notes = (notesOverride?.trim().isNotEmpty ?? false)
        ? notesOverride!.trim()
        : 'New customer registration from Sampan app (Google)';

    final addBody = <String, dynamic>{
      'api_token': ApiConfig.apiToken,
      'customerName': parsed.name,
      'customerTel': parsed.phone,
      'customerEmail': parsed.email,
      'customerPassword': parsed.cleanCloudPassword,
      'customerAddress': addressLine,
      'customerNotes': notes,
    };
    if (referralCode != null && referralCode.trim().isNotEmpty) {
      addBody['promoCode'] = referralCode.trim();
    }

    final res = await NetworkCaller.postRequest(
      url: Urls.accountCreate,
      body: addBody,
    );
    final resBody = res.body ?? <String, dynamic>{};

    final errorMsg = resBody['Error']?.toString().trim();
    if (errorMsg != null && errorMsg.isNotEmpty) {
      debugPrint('[Signup] Google addCustomer error: $errorMsg');
      final isExists = errorMsg.toLowerCase().contains('already exists');
      return CleanCloudBridgeResult.failure(
        FirebaseLoginStatus.created,
        isExists
            ? 'An account already exists with this email. Please sign in instead.'
            : errorMsg,
      );
    }

    final customerId =
        (resBody['CustomerID'] ?? resBody['cid'])?.toString().trim() ?? '';
    final ok = res.isSuccess &&
        (resBody['Success'] == 'True' ||
            resBody['Success'] == true ||
            customerId.isNotEmpty);
    if (!ok || customerId.isEmpty) {
      return CleanCloudBridgeResult.failure(
        FirebaseLoginStatus.created,
        res.errorMessage ?? 'Signup failed. Please try again.',
      );
    }

    debugPrint(
      '[CustomerSession] Google signup addCustomer CustomerID: $customerId',
    );

    await _persistSession(
      customerId: customerId,
      name: parsed.name,
      email: parsed.email,
      phone: parsed.phone,
      address: addressLine,
      apiResponse: resBody,
    );

    return CleanCloudBridgeResult.ok(FirebaseLoginStatus.created);
  }

  // ────────────────────────── status: exists ───────────────────────────

  static Future<CleanCloudBridgeResult> _loginCustomerOnCleanCloud(
    FirebaseLoginParsedUser parsed,
  ) async {
    final loginBody = <String, dynamic>{
      'api_token': ApiConfig.apiToken,
      'customerEmail': parsed.email,
      'customerPassword': parsed.cleanCloudPassword,
    };

    final res = await NetworkCaller.postRequest(
      url: Urls.logInAcc,
      body: loginBody,
    );
    final resBody = res.body ?? <String, dynamic>{};

    final errorMsg = resBody['Error']?.toString().trim();
    if (errorMsg != null && errorMsg.isNotEmpty) {
      debugPrint('[Login] Google loginCustomer error: $errorMsg');
      return CleanCloudBridgeResult.failure(
        FirebaseLoginStatus.exists,
        errorMsg,
      );
    }

    final cid =
        (resBody['cid'] ?? resBody['CustomerID'])?.toString().trim() ?? '';
    final ok = res.isSuccess &&
        (resBody['Success'] == 'True' ||
            resBody['Success'] == true ||
            cid.isNotEmpty);
    if (!ok || cid.isEmpty) {
      return CleanCloudBridgeResult.failure(
        FirebaseLoginStatus.exists,
        res.errorMessage ?? 'Sign-in failed. Please try again.',
      );
    }

    debugPrint('[CustomerSession] Google login cid: $cid');

    // Login response may not include name/phone/address — fall back to local
    // values + parsed Firebase values so the UI still has something to render.
    final apiName = resBody['customerName']?.toString().trim() ??
        resBody['CustomerName']?.toString().trim() ??
        resBody['name']?.toString().trim() ??
        '';
    final nameToSave = apiName.isNotEmpty ? apiName : parsed.name;

    final apiPhone = resBody['customerTel']?.toString().trim() ??
        resBody['customerPhone']?.toString().trim() ??
        '';
    final localPhone = await LocalStore.instance.getUserPhone();
    final phoneToSave = apiPhone.isNotEmpty
        ? apiPhone
        : (parsed.phone.isNotEmpty ? parsed.phone : (localPhone ?? ''));

    final apiAddress = resBody['customerAddress']?.toString().trim() ?? '';
    final localAddress = await LocalStore.instance.getCustomerAddress();
    final addressToSave =
        apiAddress.isNotEmpty ? apiAddress : (localAddress ?? '');

    await _persistSession(
      customerId: cid,
      name: nameToSave,
      email: parsed.email,
      phone: phoneToSave,
      address: addressToSave,
      apiResponse: resBody,
    );

    return CleanCloudBridgeResult.ok(FirebaseLoginStatus.exists);
  }

  // ────────────────────────── shared persistence ──────────────────────

  static Future<void> _persistSession({
    required String customerId,
    required String name,
    required String email,
    required String phone,
    required String address,
    required Map<String, dynamic> apiResponse,
  }) async {
    final instructionsToSave =
        await LocalStore.instance.getDeliveryInstructions();

    await LocalStore.instance.saveSession(
      customerId: customerId,
      apiToken: ApiConfig.apiToken,
      name: name,
      email: email,
      phone: phone,
      address: address,
      instructions: instructionsToSave,
    );
    await LocalStore.instance.saveCustomerIdFromResponse(apiResponse);
    await LocalStore.instance.setLoggedIn(true);

    final profile = UserProfile(
      fullName: name,
      email: email,
      phone: phone,
      address: address,
      name: name,
    );
    await LocalStore.instance.saveUserProfile(profile);

    if (Get.isRegistered<ProfileController>()) {
      await Get.find<ProfileController>().setSession(
        name: name,
        email: email,
        customerId: customerId,
        apiToken: ApiConfig.apiToken,
        phone: phone,
        address: address,
      );
    }
  }

  // ────────────────────────── helpers ─────────────────────────────────

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
