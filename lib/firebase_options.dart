// File generated from project `android/app/google-services.json` (Android) and
// `ios/Runner/GoogleService-Info.plist` (iOS). If iOS Firebase still fails, open
// Firebase Console → Project settings → add/re-download the iOS app for
// `com.sampan.laundry`, then replace `GOOGLE_APP_ID` in both this file (ios.appId)
// and `GoogleService-Info.plist` with the value from the downloaded plist.
//
// Recommended: install Firebase CLI + run `flutterfire configure` to regenerate.

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
    apiKey: 'AIzaSyApT7SUYexV9mGnhAKwv58v5JJM0nlxqAg',
    appId: '1:972205906276:ios:b165eb2935c880fa8e8271',
    messagingSenderId: '972205906276',
    projectId: 'sampan-app-ebba8',
    storageBucket: 'sampan-app-ebba8.firebasestorage.app',
    iosClientId:
        '972205906276-au69fl085aaj00j64rqag880ddpdmcni.apps.googleusercontent.com',
    iosBundleId: 'com.sampan.laundry',
  );
}
