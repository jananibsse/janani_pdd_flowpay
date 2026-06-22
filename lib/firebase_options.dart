import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCr9Sh4D1HbT5hDJgv9ySb4apeWc2W5hNY',
    appId: '1:461330632925:web:df60a627c3df9d4e6b8b34',
    messagingSenderId: '461330632925',
    projectId: 'flowpay-441fc',
    authDomain: 'flowpay-441fc.firebaseapp.com',
    storageBucket: 'flowpay-441fc.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC7Ng9cew32taKJKH1kqXspfstYQyQqngQ',
    appId: '1:461330632925:android:d3fdbcfa989e2c6f6b8b34',
    messagingSenderId: '461330632925',
    projectId: 'flowpay-441fc',
    storageBucket: 'flowpay-441fc.firebasestorage.app',
  );
}