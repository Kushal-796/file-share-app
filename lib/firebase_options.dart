import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not supported yet');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCIIgjv666OvddbC8ZAW2kX35Q5Py2BapI',
    appId: '1:1000852630204:android:fe9c62866f648607a57eb9',
    messagingSenderId: '1000852630204',
    projectId: 'file-share-app-292f3',
    storageBucket: 'file-share-app-292f3.firebasestorage.app',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4ZCtI5IJGmTN2BmFui5KMoqp2khVorUs',
    appId: '1:1000852630204:ios:6c329f02851baf32a57eb9',
    messagingSenderId: '1000852630204',
    projectId: 'file-share-app-292f3',
    storageBucket: 'file-share-app-292f3.firebasestorage.app',
    iosBundleId: 'file.share',
  );
}
