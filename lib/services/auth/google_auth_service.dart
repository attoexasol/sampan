import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sampan/firebase_options.dart';
import 'package:sampan/services/auth/firebase_id_token.dart';
import 'package:sampan/services/auth/google_auth_log.dart';

/// Outcome of [GoogleAuthService.signInWithGoogle].
class GoogleAuthResult {
  const GoogleAuthResult({
    required this.success,
    required this.message,
    this.idToken,
    this.uid,
    this.email,
    this.displayName,
  });

  final bool success;
  final String message;
  /// Firebase Auth **ID token** (JWT) after Google sign-in — not the Google OAuth `accessToken`.
  final String? idToken;
  final String? uid;
  final String? email;
  final String? displayName;

  /// User closed the picker / dismissed sign-in (no snackbar needed).
  factory GoogleAuthResult.cancelled() =>
      const GoogleAuthResult(success: false, message: '');

  factory GoogleAuthResult.failure(String message) => GoogleAuthResult(
        success: false,
        message: message,
      );

  factory GoogleAuthResult.ok({
    required String idToken,
    required String uid,
    required String? email,
    required String? displayName,
  }) =>
      GoogleAuthResult(
        success: true,
        message: 'Signed in with Google.',
        idToken: idToken,
        uid: uid,
        email: email,
        displayName: displayName,
      );
}

/// Firebase Auth + Google Sign-In (`google_sign_in` v7). Call after [Firebase.initializeApp].
class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInReady() async {
    if (_googleSignInInitialized) {
      debugPrint('[GOOGLE_AUTH] GoogleSignIn initialize (already done, skipped)');
      return;
    }
    debugPrint('[GOOGLE_AUTH] GoogleSignIn initialize');
    await GoogleSignIn.instance.initialize(
      serverClientId: DefaultFirebaseOptions.googleSignInServerClientId,
    );
    _googleSignInInitialized = true;
    debugPrint('[GOOGLE_AUTH] GoogleSignIn initialize complete');
  }

  Future<GoogleAuthResult> signInWithGoogle() async {
    try {
      debugPrint('[GOOGLE_AUTH] Starting authentication');
      await _ensureGoogleSignInReady();

      debugPrint('[GOOGLE_AUTH] authenticate start');
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final emailLabel =
          googleUser.email.isEmpty ? '(none)' : googleUser.email;
      debugPrint('[GOOGLE_AUTH] Account selected: $emailLabel');

      debugPrint('[GOOGLE_AUTH] authentication tokens received');
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? googleIdToken = googleAuth.idToken;
      if (googleIdToken == null || googleIdToken.isEmpty) {
        debugPrint('[GOOGLE_AUTH] NO_ID_TOKEN');
        debugPrint('[GOOGLE_AUTH] full exception: Google idToken was null or empty');
        return GoogleAuthResult.failure(
          'Missing Google ID token. Add a Web OAuth client in Firebase if needed, '
          'update google-services.json, or use initialize(serverClientId: ...).',
        );
      }
      logGoogleAuthJwtSnapshot('Google ID Token (for Firebase credential)', googleIdToken);

      debugPrint('[GOOGLE_AUTH] Firebase credential created');
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleIdToken,
      );

      debugPrint('[GOOGLE_AUTH] FirebaseAuth.signInWithCredential start');
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        debugPrint('[GOOGLE_AUTH] Firebase login failure: user is null');
        debugPrint(
          '[GOOGLE_AUTH] full exception: FirebaseAuth signIn returned null user',
        );
        return GoogleAuthResult.failure(
          'Sign-in completed but no Firebase user was returned.',
        );
      }

      debugPrint(
        '[GOOGLE_AUTH] Email: ${user.email ?? "(none)"}',
      );
      debugPrint('[GOOGLE_AUTH] Firebase login success UID: ${user.uid}');

      // Backend must receive Firebase Auth **ID token** (force refresh), not Google OAuth access_token.
      final String firebaseIdToken;
      try {
        firebaseIdToken = await getFirebaseIdToken(forceRefresh: true);
        validateFirebaseIdTokenForBackend(firebaseIdToken);
      } on FirebaseIdTokenException catch (e) {
        debugPrint('[GOOGLE_AUTH] NO_ID_TOKEN (Firebase) ${e.message}');
        return GoogleAuthResult.failure(e.message);
      }
      if (kDebugMode) {
        logGoogleAuthJwtSnapshot(
          'Firebase ID Token (Firebase Auth, for backend)',
          firebaseIdToken,
        );
      }

      return GoogleAuthResult.ok(
        idToken: firebaseIdToken,
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    } on GoogleSignInException catch (e, st) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted ||
          e.code == GoogleSignInExceptionCode.uiUnavailable) {
        debugPrint('[GOOGLE_AUTH] USER_CANCELLED');
        debugPrint('[GOOGLE_AUTH] full exception: $e');
        return GoogleAuthResult.cancelled();
      }
      debugPrint('[GOOGLE_AUTH] GoogleSignInException: $e');
      debugPrint('[GOOGLE_AUTH] full exception: $e');
      debugPrint('[GOOGLE_AUTH] stack trace:\n$st');
      return GoogleAuthResult.failure(
        e.description?.isNotEmpty == true ? e.description! : e.code.name,
      );
    } on FirebaseAuthException catch (e, st) {
      debugPrint('[GOOGLE_AUTH] Firebase login failure');
      debugPrint('[GOOGLE_AUTH] FirebaseAuthException code=${e.code} message=${e.message}');
      debugPrint('[GOOGLE_AUTH] full exception: $e');
      debugPrint('[GOOGLE_AUTH] stack trace:\n$st');
      return GoogleAuthResult.failure(
        e.message?.isNotEmpty == true ? e.message! : e.code,
      );
    } on PlatformException catch (e, st) {
      debugPrint('[GOOGLE_AUTH] PlatformException code=${e.code} message=${e.message} details=${e.details}');
      debugPrint('[GOOGLE_AUTH] full exception: $e');
      debugPrint('[GOOGLE_AUTH] stack trace:\n$st');
      return GoogleAuthResult.failure(e.message ?? e.code);
    } catch (e, st) {
      debugPrint('[GOOGLE_AUTH] Exception: $e');
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
      return GoogleAuthResult.failure(e.toString());
    }
  }
}
