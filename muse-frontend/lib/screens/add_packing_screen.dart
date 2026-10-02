import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddPackingScreen extends StatefulWidget {
  const AddPackingScreen({super.key});

  @override
  State<AddPackingScreen> createState() => _AddPackingScreenState();
}

class _AddPackingScreenState extends State<AddPackingScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController nameController = TextEditingController();

  List<dynamic> outfits = [];
  final Set<String> selectedOutfitIds = {};

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));

  bool loadingOutfits = true;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadOutfits();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadOutfits() async {
    try {
      final result = await apiService.getOutfits();

      if (!mounted) return;

      setState(() {
        outfits = result;
        loadingOutfits = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loadingOutfits = false;
      });
    }
  }

  Future<void> selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      startDate = picked;

      if (endDate.isBefore(startDate)) {
        endDate = startDate;
      }
    });
  }

  Future<void> selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.isBefore(startDate) ? startDate : endDate,
      firstDate: startDate,
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      endDate = picked;
    });
  }

  String getOutfitId(dynamic outfit) {
    if (outfit is Map<String, dynamic>) {
      return outfit['id']?.toString() ?? '';
    }

    return '';
  }

  String getOutfitName(dynamic outfit) {
    if (outfit is Map<String, dynamic>) {
      return outfit['name']?.toString() ?? 'Unnamed outfit';
    }

    return 'Unnamed outfit';
  }

  Future<void> savePackingList() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a packing list name.'),
        ),
      );
      return;
    }

    if (selectedOutfitIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one outfit.'),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await apiService.createPackingList(
        name: name,
        startDate: formatDate(startDate),
        endDate: formatDate(endDate),
        outfitIds: selectedOutfitIds.toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Packing list created successfully.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create packing list: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Packing List'),
      ),
      body: loadingOutfits
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
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
                              loadingOutfits = true;
                              error = null;
                            });

                            loadOutfits();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Trip name',
                          hintText: 'Example: Chennai Trip',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Travel dates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Start date'),
                          subtitle: Text(formatDate(startDate)),
                          trailing: const Icon(Icons.edit_calendar),
                          onTap: selectStartDate,
                        ),
                      ),

                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.event),
                          title: const Text('End date'),
                          subtitle: Text(formatDate(endDate)),
                          trailing: const Icon(Icons.edit_calendar),
                          onTap: selectEndDate,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Select outfits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (outfits.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No outfits available. Create an outfit first.',
                            ),
                          ),
                        )
                      else
                        ...outfits.map(
                          (outfit) {
                            final outfitId = getOutfitId(outfit);

                            if (outfitId.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Card(
                              child: CheckboxListTile(
                                value: selectedOutfitIds.contains(outfitId),
                                title: Text(
                                  getOutfitName(outfit),
                                ),
                                subtitle: Text(
                                  'ID: $outfitId',
                                ),
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected == true) {
                                      selectedOutfitIds.add(outfitId);
                                    } else {
                                      selectedOutfitIds.remove(outfitId);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: saving ? null : savePackingList,
                          icon: saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.luggage),
                          label: Text(
                            saving
                                ? 'Creating...'
                                : 'Create Packing List',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}