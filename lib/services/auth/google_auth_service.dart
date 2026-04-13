import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    if (_googleSignInInitialized) return;
    // If Android returns no Google idToken, pass serverClientId (Web client ID from Firebase).
    await GoogleSignIn.instance.initialize();
    _googleSignInInitialized = true;
  }

  Future<GoogleAuthResult> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInReady();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? googleIdToken = googleAuth.idToken;
      if (googleIdToken == null || googleIdToken.isEmpty) {
        return GoogleAuthResult.failure(
          'Missing Google ID token. Add a Web OAuth client in Firebase if needed, '
          'update google-services.json, or use initialize(serverClientId: ...).',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleIdToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return GoogleAuthResult.failure(
          'Sign-in completed but no Firebase user was returned.',
        );
      }

      final String? firebaseIdToken = await user.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        return GoogleAuthResult.failure('Could not obtain Firebase ID token.');
      }

      return GoogleAuthResult.ok(
        idToken: firebaseIdToken,
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted ||
          e.code == GoogleSignInExceptionCode.uiUnavailable) {
        return GoogleAuthResult.cancelled();
      }
      return GoogleAuthResult.failure(
        e.description?.isNotEmpty == true ? e.description! : e.code.name,
      );
    } on FirebaseAuthException catch (e) {
      return GoogleAuthResult.failure(
        e.message?.isNotEmpty == true ? e.message! : e.code,
      );
    } catch (e) {
      return GoogleAuthResult.failure(e.toString());
    }
  }
}
