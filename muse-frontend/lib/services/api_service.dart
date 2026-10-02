import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://10.0.2.2:5001/muse-35420/asia-south1/api';

  Future<Map<String, String>> _headers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final token = await user.getIdToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // =============================
  // WARDROBE
  // =============================

  Future<List<dynamic>> getWardrobe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/wardrobe'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }

    throw Exception(
      'Failed to load wardrobe: '
      '${response.statusCode} ${response.body}',
    );
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
    final body = {
      'name': name,
      'category': category,
      'color': color,
      'season': season,
      'occasions': occasions,
      'notes': notes,
      'archived': archived,
    };

    body.removeWhere((key, value) => value == null);

    final response = await http.post(
      Uri.parse('$baseUrl/v1/wardrobe'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to add wardrobe item: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<Map<String, dynamic>> updateWardrobeImagePath({
    required String itemId,
    required String imagePath,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/v1/wardrobe/$itemId'),
      headers: await _headers(),
      body: jsonEncode({
        'imagePath': imagePath,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update wardrobe image: '
      '${response.statusCode} ${response.body}',
    );
  }

  // =============================
  // OUTFITS
  // =============================

  Future<List<dynamic>> getOutfits() async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/outfits'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }

    throw Exception(
      'Failed to load outfits: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<Map<String, dynamic>> addOutfit({
    required String name,
    required List<String> itemIds,
    String? occasion,
    String? season,
    String? notes,
  }) async {
    final body = {
      'name': name,
      'itemIds': itemIds,
      'occasion': occasion,
      'season': season,
      'notes': notes,
    };

    body.removeWhere((key, value) => value == null);

    final response = await http.post(
      Uri.parse('$baseUrl/v1/outfits'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to add outfit: '
      '${response.statusCode} ${response.body}',
    );
  }

  // =============================
  // PLANNER
  // =============================

  Future<List<dynamic>> getPlanner({
    required String from,
    required String to,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/v1/planner?from=$from&to=$to',
      ),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }

    throw Exception(
      'Failed to load planner: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<Map<String, dynamic>> savePlanner({
    required String date,
    required String outfitId,
    String? notes,
  }) async {
    final body = {
      'outfitId': outfitId,
      'notes': notes,
    };

    body.removeWhere((key, value) => value == null);

    final response = await http.put(
      Uri.parse('$baseUrl/v1/planner/$date'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to save planner: '
        '${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body);
  }

  Future<void> deletePlanner({
    required String date,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/v1/planner/$date'),
      headers: await _headers(),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete planner entry: '
        '${response.statusCode} ${response.body}',
      );
    }
  }

  // =============================
  // PACKING LISTS
  // =============================

  Future<List<dynamic>> getPackingLists() async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/packing-lists'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }

    throw Exception(
      'Failed to load packing lists: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<Map<String, dynamic>> createPackingList({
    required String name,
    required String startDate,
    required String endDate,
    required List<String> outfitIds,
    List<String>? extraItemIds,
  }) async {
    final body = {
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'outfitIds': outfitIds,
      'extraItemIds': extraItemIds,
    };

    body.removeWhere((key, value) => value == null);

    final response = await http.post(
      Uri.parse('$baseUrl/v1/packing-lists'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create packing list: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<Map<String, dynamic>> getPackingList(
    String listId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/packing-lists/$listId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load packing list: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<Map<String, dynamic>> updatePackingItem({
    required String listId,
    required String itemId,
    required bool packed,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '$baseUrl/v1/packing-lists/$listId/items/$itemId',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'packed': packed,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update packing item: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<void> deletePackingList(String listId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/v1/packing-lists/$listId'),
      headers: await _headers(),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete packing list: '
        '${response.statusCode} ${response.body}',
      );
    }
  }

  // =============================
  // RECOMMENDATIONS
  // =============================

  Future<List<dynamic>> getRecommendations({
    String? occasion,
    String? season,
  }) async {
    final queryParameters = <String, String>{};

    if (occasion != null && occasion.isNotEmpty) {
      queryParameters['occasion'] = occasion;
    }

    if (season != null && season.isNotEmpty) {
      queryParameters['season'] = season;
    }

    final uri = Uri.parse(
      '$baseUrl/v1/recommendations',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }

    throw Exception(
      'Failed to load recommendations: '
      '${response.statusCode} ${response.body}',
    );
  }
}