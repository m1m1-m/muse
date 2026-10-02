import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'demo-api-key',
      appId: '1:1234567890:android:demo',
      messagingSenderId: '1234567890',
      projectId: 'muse-35420',
      storageBucket: 'muse-35420.firebasestorage.app',
    ),
  );

  await FirebaseAuth.instance.useAuthEmulator(
    '10.0.2.2',
    9099,
  );

  FirebaseStorage.instance.useStorageEmulator(
    '10.0.2.2',
    9199,
  );

  runApp(const MuseApp());
}

class MuseApp extends StatelessWidget {
  const MuseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MUSE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
        ),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}