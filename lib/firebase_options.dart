// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAVq-qAyAe-ai_hSJbX4T0sonL5YqEIss4',
    appId: '1:353547129400:web:4ccf6776e0c4168106cccd',
    messagingSenderId: '353547129400',
    projectId: 'lobo-tour',
    authDomain: 'lobo-tour.firebaseapp.com',
    storageBucket: 'lobo-tour.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnp9rTd4KAkjpzQQMsV_NMQUAJltkjShA',
    appId: '1:353547129400:android:9883e7a44114360106cccd',
    messagingSenderId: '353547129400',
    projectId: 'lobo-tour',
    storageBucket: 'lobo-tour.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDE1xnBTsqbSqKU8LF-s31j1PQwZUSL-dk',
    appId: '1:353547129400:ios:00c997978fc0782106cccd',
    messagingSenderId: '353547129400',
    projectId: 'lobo-tour',
    storageBucket: 'lobo-tour.appspot.com',
    iosBundleId: 'com.example.lbTour',
  );
}
