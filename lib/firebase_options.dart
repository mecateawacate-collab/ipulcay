import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.

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
        return windows;
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
    apiKey: 'AIzaSyDEKs26wsYiZ3-TuSxn7rYQuxibWJbp-Gw',
    appId: '1:423173526058:web:dc49dd417a2f2a61fd2953',
    messagingSenderId: '423173526058',
    projectId: 'ipulcay-9e655',
    authDomain: 'ipulcay-9e655.firebaseapp.com',
    storageBucket: 'ipulcay-9e655.firebasestorage.app',
    measurementId: 'G-CL23G1QMSV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLyPYyPkyl0ubpGs77Ev3fX0p_E0ruAN8',
    appId: '1:423173526058:android:71bb60d2249f2204fd2953',
    messagingSenderId: '423173526058',
    projectId: 'ipulcay-9e655',
    storageBucket: 'ipulcay-9e655.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDCUOe13WQQ0KDVVP8yQPJw64JA8c7jDGw',
    appId: '1:423173526058:ios:a26bca20ef1bb8aafd2953',
    messagingSenderId: '423173526058',
    projectId: 'ipulcay-9e655',
    storageBucket: 'ipulcay-9e655.firebasestorage.app',
    iosBundleId: 'com.example.ipulcay',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDCUOe13WQQ0KDVVP8yQPJw64JA8c7jDGw',
    appId: '1:423173526058:ios:a26bca20ef1bb8aafd2953',
    messagingSenderId: '423173526058',
    projectId: 'ipulcay-9e655',
    storageBucket: 'ipulcay-9e655.firebasestorage.app',
    iosBundleId: 'com.example.ipulcay',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDEKs26wsYiZ3-TuSxn7rYQuxibWJbp-Gw',
    appId: '1:423173526058:web:ff2f4aaf5836e3fffd2953',
    messagingSenderId: '423173526058',
    projectId: 'ipulcay-9e655',
    authDomain: 'ipulcay-9e655.firebaseapp.com',
    storageBucket: 'ipulcay-9e655.firebasestorage.app',
    measurementId: 'G-MLCB6E8DRG',
  );
}
