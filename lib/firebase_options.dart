
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGMW_OEIs4SSVv3IpdcTSv9Tyy4hhgx_0',
    appId: '1:621835105918:android:f064c11ef7fe4e9600ca2f',
    messagingSenderId: '621835105918',
    projectId: 'yug-adda',
    storageBucket: 'yug-adda.firebasestorage.app',
  );
}
