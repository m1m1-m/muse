import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AuthService().restore();
  } catch (_) {
    // Offline or revoked: fall through to the login screen.
  }

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
      home: AuthService.currentUser == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}
