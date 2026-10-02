import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_outfit_screen.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  final ApiService apiService = ApiService();

  List<dynamic> outfits = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadOutfits();
  }

  Future<void> loadOutfits() async {
    try {
      final data = await apiService.getOutfits();

      if (!mounted) return;

      setState(() {
        outfits = data;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> openAddOutfit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddOutfitScreen(),
      ),
    );

    if (result == true) {
      setState(() {
        loading = true;
      });

      await loadOutfits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Outfits'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddOutfit,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    loading = true;
                    error = null;
                  });

                  loadOutfits();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (outfits.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadOutfits,
        child: ListView(
          children: const [
            SizedBox(height: 250),
            Center(
              child: Text(
                'No outfits yet.\nCreate your first outfit!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadOutfits,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: outfits.length,
        itemBuilder: (context, index) {
          final outfit = outfits[index];

          final String name =
              outfit['name']?.toString() ?? 'Unnamed Outfit';

          final String occasion =
              outfit['occasion']?.toString() ?? 'No occasion';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.style),
              ),
              title: Text(name),
              subtitle: Text(occasion),
            ),
          );
        },
      ),
    );
  }
}
