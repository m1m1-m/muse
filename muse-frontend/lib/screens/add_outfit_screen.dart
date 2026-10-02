import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddOutfitScreen extends StatefulWidget {
  const AddOutfitScreen({super.key});

  @override
  State<AddOutfitScreen> createState() => _AddOutfitScreenState();
}

class _AddOutfitScreenState extends State<AddOutfitScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  List<dynamic> wardrobeItems = [];
  List<String> selectedItemIds = [];

  String? selectedOccasion;
  String? selectedSeason;

  bool loading = true;
  bool saving = false;

  final List<String> occasions = [
    'casual',
    'work',
    'formal',
    'sport',
    'travel',
  ];

  final List<String> seasons = [
    'spring',
    'summer',
    'autumn',
    'winter',
    'all',
  ];

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
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load wardrobe: $e'),
        ),
      );
    }
  }

  Future<void> saveOutfit() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an outfit name'),
        ),
      );
      return;
    }

    if (selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one wardrobe item'),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await apiService.addOutfit(
        name: nameController.text.trim(),
        itemIds: selectedItemIds,
        occasion: selectedOccasion,
        season: selectedSeason,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Outfit created successfully!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create outfit: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Outfit'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Outfit Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. College Casual',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Occasion',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: selectedOccasion,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select occasion'),
                    items: occasions.map((occasion) {
                      return DropdownMenuItem(
                        value: occasion,
                        child: Text(
                          occasion[0].toUpperCase() +
                              occasion.substring(1),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedOccasion = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Season',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: selectedSeason,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select season'),
                    items: seasons.map((season) {
                      return DropdownMenuItem(
                        value: season,
                        child: Text(
                          season[0].toUpperCase() +
                              season.substring(1),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSeason = value;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Select Wardrobe Items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (wardrobeItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Your wardrobe is empty.\n'
                        'Add wardrobe items first.',
                      ),
                    )
                  else
                    ...wardrobeItems.map((item) {
                      final String id = item['id'].toString();

                      final String name =
                          item['name']?.toString() ?? 'Unnamed item';

                      final String category =
                          item['category']?.toString() ?? '';

                      final bool selected =
                          selectedItemIds.contains(id);

                      return Card(
                        child: CheckboxListTile(
                          value: selected,
                          title: Text(name),
                          subtitle: Text(category),
                          secondary: const Icon(Icons.checkroom),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                if (!selectedItemIds.contains(id)) {
                                  selectedItemIds.add(id);
                                }
                              } else {
                                selectedItemIds.remove(id);
                              }
                            });
                          },
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Optional notes',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: saving ? null : saveOutfit,
                      child: saving
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Save Outfit',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
