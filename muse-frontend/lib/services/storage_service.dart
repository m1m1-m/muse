import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadWardrobeImage({
    required String userId,
    required String itemId,
    required File imageFile,
  }) async {
    final storagePath =
        'users/$userId/wardrobe/$itemId/image.jpg';

    final reference = _storage.ref().child(storagePath);

    await reference.putFile(
      imageFile,
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );

    return storagePath;
  }

  Future<void> deleteWardrobeImage({
    required String userId,
    required String itemId,
  }) async {
    final storagePath =
        'users/$userId/wardrobe/$itemId/image.jpg';

    final reference = _storage.ref().child(storagePath);

    try {
      await reference.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        rethrow;
      }
    }
  }
}