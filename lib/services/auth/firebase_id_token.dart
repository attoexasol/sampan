import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Thrown when [getFirebaseIdToken] cannot produce a valid Firebase Auth ID token.
class FirebaseIdTokenException implements Exception {
  FirebaseIdTokenException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Best practice: after Google (or any) sign-in, read the token from **Firebase Auth**
/// with [User.getIdToken] — not from `GoogleSignInAuthentication` — and refresh before
/// sending to your backend so Admin SDK verifies a current JWT.
///
/// [forceRefresh]: `true` asks Firebase for a new ID token when possible (recommended
/// immediately before server exchange).
Future<String> getFirebaseIdToken({bool forceRefresh = true}) async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw FirebaseIdTokenException(
      'No Firebase user is signed in. Complete Firebase sign-in first.',
    );
  }

  final String? raw = await user.getIdToken(forceRefresh);
  if (raw == null) {
    throw FirebaseIdTokenException('Firebase returned a null ID token.');
  }

  final String token = raw.trim();
  if (token.isEmpty) {
    throw FirebaseIdTokenException('Firebase returned an empty ID token.');
  }

  if (kDebugMode) {
    _logFirebaseIdTokenDebug('getFirebaseIdToken(forceRefresh=$forceRefresh)', token);
    debugPrint('[FirebaseIdToken] full_token=$token');
  }

  return token;
}

/// Validates a token string before putting it in JSON (null-safe, no accidental quotes).
void validateFirebaseIdTokenForBackend(String token) {
  final String t = token.trim();
  if (t.isEmpty) {
    throw FirebaseIdTokenException('ID token is empty.');
  }
  if ((t.startsWith('"') && t.endsWith('"')) ||
      (t.startsWith("'") && t.endsWith("'"))) {
    throw FirebaseIdTokenException(
      'ID token must not be wrapped in quotes; send the raw JWT string only.',
    );
  }
  if (kDebugMode && !t.startsWith('eyJ')) {
    debugPrint(
      '[FirebaseIdToken] validate: warning — token does not look like a JWT (expected to start with eyJ).',
    );
  }
}

void _logFirebaseIdTokenDebug(String phase, String token) {
  final int n = token.length;
  final String prefix = n >= 20 ? token.substring(0, 20) : token;
  debugPrint('[FirebaseIdToken] $phase len=$n prefix=$prefix');
}
