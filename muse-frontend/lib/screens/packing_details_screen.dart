import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PackingDetailsScreen extends StatefulWidget {
  final String listId;

  const PackingDetailsScreen({
    super.key,
    required this.listId,
  });

  @override
  State<PackingDetailsScreen> createState() =>
      _PackingDetailsScreenState();
}

class _PackingDetailsScreenState
    extends State<PackingDetailsScreen> {
  final ApiService apiService = ApiService();

  Map<String, dynamic>? packingList;
  bool loading = true;
  bool deleting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadPackingList();
  }

  Future<void> loadPackingList() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result =
          await apiService.getPackingList(widget.listId);

      if (!mounted) return;

      setState(() {
        packingList = result;
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

  String getString(String key) {
    return packingList?[key]?.toString() ?? '';
  }

  List<dynamic> getItems() {
    final items = packingList?['items'];

    if (items is List) {
      return items;
    }

    return [];
  }

  String getItemValue(
    dynamic item,
    String key,
  ) {
    if (item is Map<String, dynamic>) {
      return item[key]?.toString() ?? '';
    }

    return '';
  }

  bool getPackedValue(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item['packed'] == true;
    }

    return false;
  }

  Future<void> updateItem(
    String itemId,
    bool packed,
  ) async {
    try {
      final updated =
          await apiService.updatePackingItem(
        listId: widget.listId,
        itemId: itemId,
        packed: packed,
      );

      if (!mounted) return;

      setState(() {
        packingList = updated;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update item: $e',
          ),
        ),
      );
    }
  }

  Future<void> deletePackingList() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Packing List'),
          content: const Text(
            'Are you sure you want to delete this packing list?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      deleting = true;
    });

    try {
      await apiService.deletePackingList(widget.listId);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        deleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete packing list: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing Details'),
        actions: [
          IconButton(
            onPressed: deleting ? null : deletePackingList,
            icon: deleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.delete),
          ),
        ],
      ),
      body: _buildBody(),
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
                onPressed: loadPackingList,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final items = getItems();

    return RefreshIndicator(
      onRefresh: loadPackingList,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    getString('name'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${getString('startDate')} → '
                    '${getString('endDate')}',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Items to Pack (${items.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No items found in this packing list.',
                ),
              ),
            ),

          ...items.map(
            (item) {
              final itemId =
                  getItemValue(item, 'itemId');

              final itemName =
                  getItemValue(item, 'name');

              final category =
                  getItemValue(item, 'category');

              final quantity =
                  getItemValue(item, 'quantity');

              final packed =
                  getPackedValue(item);

              return Card(
                margin:
                    const EdgeInsets.only(bottom: 10),
                child: CheckboxListTile(
                  value: packed,
                  title: Text(
                    itemName.isEmpty
                        ? 'Unnamed item'
                        : itemName,
                  ),
                  subtitle: Text(
                    category.isEmpty
                        ? 'Quantity: $quantity'
                        : '$category • Quantity: $quantity',
                  ),
                  secondary: const Icon(
                    Icons.checkroom,
                  ),
                  onChanged: itemId.isEmpty
                      ? null
                      : (value) {
                          if (value == null) return;

                          updateItem(
                            itemId,
                            value,
                          );
                        },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}