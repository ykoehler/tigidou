import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (const bool.fromEnvironment('USE_FIREBASE_EMULATOR')) {
    const host = String.fromEnvironment(
      'FIREBASE_EMULATOR_HOST',
      defaultValue: 'localhost',
    );
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }

  // Enable Firestore persistence for web to prevent data loss on refresh
  if (kIsWeb) {
    await FirebaseFirestore.instance.enablePersistence(
      const PersistenceSettings(synchronizeTabs: true),
    );
  }

  runApp(const MyApp());
}
