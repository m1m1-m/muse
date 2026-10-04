import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();

  bool loading = false;

  Future<void> signIn() async {
    setState(() {
      loading = true;
    });

    try {
      final account = await authService.signIn();

      if (!mounted || account == null) return;

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MUSE'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/logo.jpeg',
                width: 160,
                height: 160,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Welcome to MUSE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Your wardrobe is stored in your own Google Drive.\n'
              'We never see or keep your data.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : signIn,
                icon: const Icon(Icons.login),
                label: Text(
                  loading ? 'Please wait...' : 'Continue with Google',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
