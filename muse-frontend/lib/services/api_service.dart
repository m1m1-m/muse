import 'dart:math';

import 'drive_store.dart';
import 'logic.dart';

/// Data layer. Same interface the screens always used, but data now lives in
/// the signed-in user's own Google Drive (appDataFolder) instead of a server.
class ApiService {
  static final ApiService _instance = ApiService._();

  factory ApiService() => _instance;

  ApiService._();

  /// Drop cached data (call on logout so the next user starts clean).
  static void reset() => _instance._data = null;

  final DriveStore _store = DriveStore();
  final Random _random = Random();

  Map<String, dynamic>? _data;

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${_random.nextInt(1 << 32).toRadixString(36)}';

  String _now() => DateTime.now().toUtc().toIso8601String();

  Future<Map<String, dynamic>> _load() async {
    final data = _data ??= await _store.loadData();

    data.putIfAbsent('wardrobe', () => <dynamic>[]);
    data.putIfAbsent('outfits', () => <dynamic>[]);
    data.putIfAbsent('planner', () => <String, dynamic>{});
    data.putIfAbsent('packingLists', () => <dynamic>[]);

    return data;
  }

  Future<void> _save() => _store.saveData(_data!);

  List<Map<String, dynamic>> _list(Map<String, dynamic> data, String key) =>
      List<Map<String, dynamic>>.from(
        (data[key] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );

  Map<String, dynamic> _find(
    Map<String, dynamic> data,
    String key,
    String id,
  ) {
    for (final entry in data[key] as List) {
      if ((entry as Map)['id'] == id) return entry as Map<String, dynamic>;
    }

    throw Exception('Resource not found');
  }

  // =============================
  // WARDROBE
  // =============================

  Future<List<dynamic>> getWardrobe() async {
    final data = await _load();

    return List<dynamic>.from(data['wardrobe'] as List);
  }

  Future<Map<String, dynamic>> addWardrobeItem({
    required String name,
    required String category,
    String? color,
    String? season,
    List<String>? occasions,
    String? notes,
    bool archived = false,
  }) async {
    if (name.trim().isEmpty) throw Exception('Invalid name');
    if (!categories.contains(category)) throw Exception('Invalid category');
    if (season != null && !seasons.contains(season)) {
      throw Exception('Invalid season');
    }

    final data = await _load();
    final now = _now();

    final item = <String, dynamic>{
      'id': _newId(),
      'name': name.trim(),
      'category': category,
      'color': color,
      'season': season ?? 'all',
      'occasions': occasions ?? <String>[],
      'imagePath': null,
      'notes': notes,
      'archived': archived,
      'createdAt': now,
      'updatedAt': now,
    };

    (data['wardrobe'] as List).add(item);
    await _save();

    return item;
  }

  /// Uploads the photo to the user's Drive and links it to the item.
  Future<Map<String, dynamic>> setWardrobeImage({
    required String itemId,
    required List<int> bytes,
  }) async {
    final data = await _load();
    final item = _find(data, 'wardrobe', itemId);

    item['imagePath'] = await _store.uploadImage('wardrobe_$itemId.jpg', bytes);
    item['updatedAt'] = _now();
    await _save();

    return item;
  }

  /// Names of outfits that contain this wardrobe item.
  Future<List<String>> outfitsUsingItem(String itemId) async {
    final data = await _load();

    return [
      for (final outfit in _list(data, 'outfits'))
        if ((outfit['itemIds'] as List).contains(itemId))
          outfit['name'] as String,
    ];
  }

  /// Deletes an item and its photo. The item is removed from every outfit
  /// that uses it; outfits left with no items are deleted too.
  Future<void> deleteWardrobeItem(String itemId) async {
    final data = await _load();
    final item = _find(data, 'wardrobe', itemId);

    final emptied = <String>[];

    for (final outfit in data['outfits'] as List) {
      final itemIds = (outfit as Map)['itemIds'] as List;

      if (itemIds.remove(itemId) && itemIds.isEmpty) {
        emptied.add(outfit['id'] as String);
      }
    }

    _removeOutfits(data, emptied);
    (data['wardrobe'] as List).removeWhere((i) => i['id'] == itemId);

    // Save the data first: a leftover photo is harmless, a dangling item is not.
    await _save();

    final imageId = item['imagePath'];

    if (imageId is String) {
      try {
        await _store.deleteFile(imageId);
      } catch (_) {
        // Orphaned photo in the hidden app folder; nothing the user can act on.
      }
    }
  }

  void _removeOutfits(Map<String, dynamic> data, List<String> outfitIds) {
    if (outfitIds.isEmpty) return;

    (data['outfits'] as List).removeWhere((o) => outfitIds.contains(o['id']));
    (data['planner'] as Map).removeWhere(
      (_, plan) => outfitIds.contains((plan as Map)['outfitId']),
    );
  }

  // =============================
  // OUTFITS
  // =============================

  /// Deletes an outfit and any planner entries that use it. Packing lists keep
  /// their own copy of the items, so they are unaffected.
  Future<void> deleteOutfit(String outfitId) async {
    final data = await _load();

    _find(data, 'outfits', outfitId);
    _removeOutfits(data, [outfitId]);
    await _save();
  }

  Future<List<dynamic>> getOutfits() async {
    final data = await _load();

    return List<dynamic>.from(data['outfits'] as List);
  }

  Future<Map<String, dynamic>> addOutfit({
    required String name,
    required List<String> itemIds,
    String? occasion,
    String? season,
    String? notes,
  }) async {
    if (name.trim().isEmpty) throw Exception('Invalid name');
    if (itemIds.isEmpty) throw Exception('itemIds cannot be empty');

    final data = await _load();

    for (final itemId in itemIds) {
      if (_find(data, 'wardrobe', itemId)['archived'] == true) {
        throw Exception('Archived wardrobe items cannot be selected');
      }
    }

    final now = _now();

    final outfit = <String, dynamic>{
      'id': _newId(),
      'name': name.trim(),
      'itemIds': itemIds,
      'occasion': occasion,
      'season': season,
      'notes': notes,
      'createdAt': now,
      'updatedAt': now,
    };

    (data['outfits'] as List).add(outfit);
    await _save();

    return outfit;
  }

  // =============================
  // PLANNER
  // =============================

  Future<List<dynamic>> getPlanner({
    required String from,
    required String to,
  }) async {
    final data = await _load();
    final planner = data['planner'] as Map;

    final days = planner.keys
        .cast<String>()
        .where((day) => day.compareTo(from) >= 0 && day.compareTo(to) <= 0)
        .toList()
      ..sort();

    return [for (final day in days) planner[day]];
  }

  Future<Map<String, dynamic>> savePlanner({
    required String date,
    required String outfitId,
    String? notes,
  }) async {
    final data = await _load();

    _find(data, 'outfits', outfitId);

    final planner = data['planner'] as Map<String, dynamic>;
    final old = planner[date] as Map?;

    final entry = <String, dynamic>{
      'id': date,
      'date': date,
      'outfitId': outfitId,
      'notes': notes,
      'createdAt': old?['createdAt'] ?? _now(),
      'updatedAt': _now(),
    };

    planner[date] = entry;
    await _save();

    return entry;
  }

  Future<void> deletePlanner({
    required String date,
  }) async {
    final data = await _load();

    (data['planner'] as Map).remove(date);
    await _save();
  }

  // =============================
  // PACKING LISTS
  // =============================

  Future<List<dynamic>> getPackingLists() async {
    final data = await _load();

    return List<dynamic>.from(data['packingLists'] as List);
  }

  Future<Map<String, dynamic>> createPackingList({
    required String name,
    required String startDate,
    required String endDate,
    required List<String> outfitIds,
    List<String>? extraItemIds,
  }) async {
    if (name.trim().isEmpty) throw Exception('Invalid name');
    if (endDate.compareTo(startDate) < 0) {
      throw Exception('endDate must be on or after startDate');
    }

    final extras = extraItemIds ?? <String>[];

    if (outfitIds.isEmpty && extras.isEmpty) {
      throw Exception('Choose an outfit or an extra item');
    }

    final data = await _load();

    final outfits = [
      for (final id in outfitIds)
        Map<String, dynamic>.from(_find(data, 'outfits', id)),
    ];

    final items = packingItems(outfits, _list(data, 'wardrobe'), extras);
    final now = _now();

    final record = <String, dynamic>{
      'id': _newId(),
      'name': name.trim(),
      'startDate': startDate,
      'endDate': endDate,
      'outfitIds': outfitIds,
      'extraItemIds': extras,
      'items': items,
      'createdAt': now,
      'updatedAt': now,
    };

    (data['packingLists'] as List).add(record);
    await _save();

    return record;
  }

  Future<Map<String, dynamic>> getPackingList(
    String listId,
  ) async {
    final data = await _load();

    return Map<String, dynamic>.from(_find(data, 'packingLists', listId));
  }

  Future<Map<String, dynamic>> updatePackingItem({
    required String listId,
    required String itemId,
    required bool packed,
  }) async {
    final data = await _load();
    final list = _find(data, 'packingLists', listId);
    final items = (list['items'] as List).cast<Map>();

    final item = items.where((i) => i['itemId'] == itemId).firstOrNull;

    if (item == null) throw Exception('Item not found in packing list');

    item['packed'] = packed;
    list['updatedAt'] = _now();
    await _save();

    return Map<String, dynamic>.from(list);
  }

  Future<void> deletePackingList(String listId) async {
    final data = await _load();

    (data['packingLists'] as List).removeWhere((l) => l['id'] == listId);
    await _save();
  }

  // =============================
  // RECOMMENDATIONS
  // =============================

  Future<List<dynamic>> getRecommendations({
    String? occasion,
    String? season,
  }) async {
    final data = await _load();

    final wardrobe = _list(data, 'wardrobe');

    final names = {
      for (final item in wardrobe) item['id'] as String: item['name'] as String,
    };

    return recommend(
      wardrobe,
      occasion: occasion != null && occasion.isNotEmpty ? occasion : null,
      season: season != null && season.isNotEmpty ? season : null,
    ).map((r) => {
          ...r,
          'name': (r['itemIds'] as List).map((id) => names[id]).join(' + '),
        }).toList();
  }
}
