// Android values from `android/app/google-services.json`. iOS values must match
// `ios/Runner/GoogleService-Info.plist` (appId, apiKey, iosClientId). Regenerate
// with `flutterfire configure` after Firebase console changes.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApT7SUYexV9mGnhAKwv58v5JJM0nlxqAg',
    appId: '1:972205906276:android:b165eb2935c880fa8e8271',
    messagingSenderId: '972205906276',
    projectId: 'sampan-app-ebba8',
    storageBucket: 'sampan-app-ebba8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAEHCW9mi2I4J-xHRGZ5V72TzuVTEQltww',
    appId: '1:972205906276:ios:9f0cb8a594c849228e8271',
    messagingSenderId: '972205906276',
    projectId: 'sampan-app-ebba8',
    storageBucket: 'sampan-app-ebba8.firebasestorage.app',
    iosClientId:
        '972205906276-28oadbedhqjklrraorc79n9g09r1unh3.apps.googleusercontent.com',
    iosBundleId: 'com.sampan.laundry',
  );

  /// Web OAuth client (`client_type` 3 in `android/app/google-services.json`).
  /// Use as [GoogleSignIn.initialize] `serverClientId` so the plugin returns a
  /// Google ID token for [GoogleAuthProvider.credential] on Android and iOS.
  static const String googleSignInServerClientId =
      '972205906276-au69fl085aaj00j64rqag880ddpdmcni.apps.googleusercontent.com';
}
