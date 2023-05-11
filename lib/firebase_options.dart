// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyAks8hI8BcT1lxEfyTSufVrydZqcrF8OlE',
    appId: '1:952512317577:web:40a5c97ee6969fdd371e58',
    messagingSenderId: '952512317577',
    projectId: 'flutter-forge2d',
    authDomain: 'flutter-forge2d.firebaseapp.com',
    storageBucket: 'flutter-forge2d.appspot.com',
    measurementId: 'G-C2SC3WC0ZR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-nlkreYO47YgHNYMmFdwzefY5G0qFOF8',
    appId: '1:952512317577:android:9ba364643e5199c4371e58',
    messagingSenderId: '952512317577',
    projectId: 'flutter-forge2d',
    storageBucket: 'flutter-forge2d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIu8cPl7oei9AWX4azNdQQ0bMknXO0pdg',
    appId: '1:952512317577:ios:12940675cea544e4371e58',
    messagingSenderId: '952512317577',
    projectId: 'flutter-forge2d',
    storageBucket: 'flutter-forge2d.appspot.com',
    iosClientId: '952512317577-r0t5gafgfqmb28m7imgar58nujlp87gl.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterForge2d',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBIu8cPl7oei9AWX4azNdQQ0bMknXO0pdg',
    appId: '1:952512317577:ios:21586418de54423f371e58',
    messagingSenderId: '952512317577',
    projectId: 'flutter-forge2d',
    storageBucket: 'flutter-forge2d.appspot.com',
    iosClientId: '952512317577-8q1dsa2au8n5bc8rtsip1gmd5k8r5ol3.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterForge2d.RunnerTests',
  );
}
