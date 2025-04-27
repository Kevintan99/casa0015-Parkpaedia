import 'package:firebase_core/firebase_core.dart';
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
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBhUk58EFnWIN25De2HsfEs1zUwGLOwU3U',
    appId: '1:75544526594:web:3a5188c8dc0bf9e3ef8c1b',
    messagingSenderId: '75544526594',
    projectId: 'parkpaedia',
    authDomain: 'parkpaedia.firebaseapp.com',
    storageBucket: 'parkpaedia.firebasestorage.app',
  );
  
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgnD3jNjXJ4EKG8tUTq0EhexdO5wFwyqY',
    appId: '1:75544526594:android:33f0e631cd537e9eef8c1b',
    messagingSenderId: '75544526594',
    projectId: 'parkpaedia',
    storageBucket: 'parkpaedia.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDM9KHkpEp2FIk5NfivJL54Hg_RfCmcpmU',
    appId: '1:75544526594:ios:163bc97150963aaaef8c1b',
    messagingSenderId: '75544526594',
    projectId: 'parkpaedia',
    storageBucket: 'parkpaedia.firebasestorage.app',
    iosBundleId: 'com.example.parkkkkkkk',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBhUk58EFnWIN25De2HsfEs1zUwGLOwU3U',
    appId: '1:75544526594:windows:YOUR_WINDOWS_APP_ID',
    messagingSenderId: '75544526594',
    projectId: 'parkpaedia',
    storageBucket: 'parkpaedia.firebasestorage.app',
  );
} 