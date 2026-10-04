import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class AddWardrobeScreen extends StatefulWidget {
  const AddWardrobeScreen({super.key});

  @override
  State<AddWardrobeScreen> createState() =>
      _AddWardrobeScreenState();
}

class _AddWardrobeScreenState
    extends State<AddWardrobeScreen> {
  final ApiService apiService = ApiService();
  final ImagePicker imagePicker = ImagePicker();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController colorController =
      TextEditingController();

  final TextEditingController notesController =
      TextEditingController();

  String selectedCategory = 'top';
  String selectedSeason = 'all';

  File? selectedImage;

  bool saving = false;

  final List<String> categories = [
    'top',
    'bottom',
    'dress',
    'outerwear',
    'shoes',
    'accessory',
  ];

  final List<String> seasons = [
    'spring',
    'summer',
    'autumn',
    'winter',
    'all',
  ];

  @override
  void dispose() {
    nameController.dispose();
    colorController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return;
    }

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<void> saveWardrobeItem() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an item name.'),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      // Step 1: Create the wardrobe item.
      final createdItem =
          await apiService.addWardrobeItem(
        name: nameController.text.trim(),
        category: selectedCategory,
        color: colorController.text.trim().isEmpty
            ? null
            : colorController.text.trim(),
        season: selectedSeason,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      final itemId = createdItem['id']?.toString();

      if (itemId == null || itemId.isEmpty) {
        throw Exception(
          'Wardrobe item was created but no item ID was returned.',
        );
      }

      // Step 2: Store the image in the user's Google Drive.
      if (selectedImage != null) {
        await apiService.setWardrobeImage(
          itemId: itemId,
          bytes: await selectedImage!.readAsBytes(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Wardrobe item added successfully!',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add wardrobe item: $e',
          ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Wardrobe Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: saving ? null : pickImage,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: selectedImage == null
                    ? const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 55,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tap to select an image',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12),
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              enabled: !saving,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories.map(
                (category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category[0].toUpperCase() +
                          category.substring(1),
                    ),
                  );
                },
              ).toList(),
              onChanged: saving
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        selectedCategory = value;
                      });
                    },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: colorController,
              enabled: !saving,
              decoration: const InputDecoration(
                labelText: 'Color',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedSeason,
              decoration: const InputDecoration(
                labelText: 'Season',
                border: OutlineInputBorder(),
              ),
              items: seasons.map(
                (season) {
                  return DropdownMenuItem<String>(
                    value: season,
                    child: Text(
                      season[0].toUpperCase() +
                          season.substring(1),
                    ),
                  );
                },
              ).toList(),
              onChanged: saving
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        selectedSeason = value;
                      });
                    },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: notesController,
              enabled: !saving,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saving
                    ? null
                    : saveWardrobeItem,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  saving
                      ? 'Uploading...'
                      : 'Save Item',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}