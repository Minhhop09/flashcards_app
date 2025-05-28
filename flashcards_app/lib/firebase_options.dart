// firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMoSSkkt4_F6B4F767hwnLaVgABPD6SfQ',
    appId: '1:325062670463:android:1a0cfa0e58ea63953fa74a',
    messagingSenderId: '325062670463',
    projectId: 'flashcards-app-13c16',
    storageBucket: 'flashcards-app-13c16.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA5mJA-2PKcSbFYe8Z1vr_RBz6UmtDNPqo',
    authDomain: 'flashcards-app-13c16.firebaseapp.com',
    projectId: 'flashcards-app-13c16',
    storageBucket: 'flashcards-app-13c16.firebasestorage.app',
    messagingSenderId: '325062670463',
    appId: '1:325062670463:web:f73b435384d0e4023fa74a',
    measurementId: 'G-Q7DGMLVDTD',
  );
}
