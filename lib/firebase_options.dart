import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBLnMDV-_nXeNSXkPouVVxnJWo_bJoRsYY',
    appId: '1:99674628115:web:YOUR_WEB_APP_ID',
    messagingSenderId: '99674628115',
    projectId: 'adventurersledger',
    authDomain: 'advledger.firebaseapp.com',
    storageBucket: 'adventurersledger.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLnMDV-_nXeNSXkPouVVxnJWo_bJoRsYY',
    appId: '1:99674628115:android:a4b9d047e3dc84554d1fe6',
    messagingSenderId: '99674628115',
    projectId: 'adventurersledger',
    storageBucket: 'adventurersledger.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDObalh1_YuTpuJX0XsH3Fcw2t_6hUet-g',
    appId: '1:99674628115:ios:67c99c740ce1e3e94d1fe6',
    messagingSenderId: '99674628115',
    projectId: 'adventurersledger',
    storageBucket: 'adventurersledger.firebasestorage.app',
    iosClientId: '99674628115-ios-client-id',
    iosBundleId: 'com.example.adventurers-ledger',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBLnMDV-_nXeNSXkPouVVxnJWo_bJoRsYY',
    appId: '1:99674628115:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '99674628115',
    projectId: 'adventurersledger',
    storageBucket: 'adventurersledger.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.adventurers_ledger',
  );
}
