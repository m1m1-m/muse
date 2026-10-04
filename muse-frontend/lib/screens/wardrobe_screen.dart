import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_wardrobe_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final ApiService apiService = ApiService();

  List<dynamic> wardrobeItems = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadWardrobe();
  }

  Future<void> loadWardrobe() async {
    try {
      final items = await apiService.getWardrobe();

      if (!mounted) return;

      setState(() {
        wardrobeItems = items;
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

  Future<void> openAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddWardrobeScreen(),
      ),
    );

    if (result == true) {
      setState(() {
        loading = true;
      });

      await loadWardrobe();
    }
  }

  Future<void> deleteItem(Map<String, dynamic> item) async {
    final usedBy = await apiService.outfitsUsingItem(item['id']);

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item'),
        content: Text(
          'Delete "${item['name']}" and its photo?'
          '${usedBy.isEmpty ? '' : '\n\nIt is used in: ${usedBy.join(', ')}. '
              'It will be removed from those outfits, and outfits left empty '
              'will be deleted.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await apiService.deleteWardrobeItem(item['id']);
      await loadWardrobe();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete item: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddItem,
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

                  loadWardrobe();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (wardrobeItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadWardrobe,
        child: ListView(
          children: const [
            SizedBox(height: 250),
            Center(
              child: Text(
                'Your wardrobe is empty.\nAdd your first item!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadWardrobe,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wardrobeItems.length,
        itemBuilder: (context, index) {
          final item = wardrobeItems[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.checkroom),
              ),
              title: Text(
                item['name'] ?? 'Unnamed item',
              ),
              subtitle: Text(
                '${item['category'] ?? 'Unknown'}'
                '${item['color'] != null ? ' • ${item['color']}' : ''}'
                '${item['season'] != null ? ' • ${item['season']}' : ''}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete item',
                onPressed: () => deleteItem(item),
              ),
            ),
          );
        },
      ),
    );
  }
}
