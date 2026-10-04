import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'wardrobe_screen.dart';
import 'outfits_screen.dart';
import 'planner_screen.dart';
import 'packing_screen.dart';
import 'recommendations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MUSE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();

              if (context.mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  '/login',
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.displayName ?? user?.email ?? 'User'} 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome to your smart wardrobe.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'What would you like to do?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _featureCard(
                    context,
                    Icons.checkroom,
                    'My Wardrobe',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const WardrobeScreen(),
                        ),
                      );
                    },
                  ),
                  _featureCard(
                    context,
                    Icons.style,
                    'Outfits',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const OutfitsScreen(),
                        ),
                      );
                    },
                  ),
                  _featureCard(
                    context,
                    Icons.calendar_month,
                    'Planner',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PlannerScreen(),
                        ),
                      );
                    },
                  ),
                  _featureCard(
                    context,
                    Icons.luggage,
                    'Packing',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PackingScreen(),
                        ),
                      );
                    },
                  ),
                  _featureCard(
                    context,
                    Icons.auto_awesome,
                    'Recommendations',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RecommendationsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 45,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}