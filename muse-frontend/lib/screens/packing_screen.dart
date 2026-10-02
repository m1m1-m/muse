import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_packing_screen.dart';
import 'packing_details_screen.dart';

class PackingScreen extends StatefulWidget {
  const PackingScreen({super.key});

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  final ApiService apiService = ApiService();

  List<dynamic> packingLists = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadPackingLists();
  }

  Future<void> loadPackingLists() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await apiService.getPackingLists();

      if (!mounted) return;

      setState(() {
        packingLists = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> openAddPackingScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPackingScreen(),
      ),
    );

    if (result == true) {
      await loadPackingLists();
    }
  }

  Future<void> openPackingDetails(dynamic list) async {
    if (list is! Map<String, dynamic>) {
      return;
    }

    final listId = list['id']?.toString();

    if (listId == null || listId.isEmpty) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackingDetailsScreen(
          listId: listId,
        ),
      ),
    );

    await loadPackingLists();
  }

  String getValue(dynamic list, String key) {
    if (list is Map<String, dynamic>) {
      return list[key]?.toString() ?? '';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing Lists'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddPackingScreen,
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
                onPressed: loadPackingLists,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (packingLists.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadPackingLists,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Center(
              child: Text(
                'No packing lists yet.',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPackingLists,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: packingLists.length,
        itemBuilder: (context, index) {
          final list = packingLists[index];

          final name = getValue(list, 'name');
          final startDate = getValue(list, 'startDate');
          final endDate = getValue(list, 'endDate');

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.luggage),
              ),
              title: Text(
                name.isEmpty ? 'Unnamed trip' : name,
              ),
              subtitle: Text(
                '$startDate → $endDate',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                openPackingDetails(list);
              },
            ),
          );
        },
      ),
    );
  }
}