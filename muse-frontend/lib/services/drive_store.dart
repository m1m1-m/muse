import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// Reads/writes MUSE data in the signed-in user's Google Drive appDataFolder.
/// The folder is hidden from the user's Drive UI and invisible to the developer.
class DriveStore {
  static const _api = 'https://www.googleapis.com/drive/v3/files';
  static const _upload = 'https://www.googleapis.com/upload/drive/v3/files';
  static const _dataFile = 'muse.json';

  final AuthService _auth = AuthService();

  String? _dataFileId;

  Future<Map<String, dynamic>> loadData() async {
    final headers = await _auth.authHeaders();

    _dataFileId ??= await _findFile(_dataFile, headers);

    if (_dataFileId == null) return {};

    final response = await http.get(
      Uri.parse('$_api/$_dataFileId?alt=media'),
      headers: headers,
    );

    _check(response, 'load data');

    return jsonDecode(utf8.decode(response.bodyBytes))
        as Map<String, dynamic>;
  }

  Future<void> saveData(Map<String, dynamic> data) async {
    final headers = await _auth.authHeaders();
    final body = utf8.encode(jsonEncode(data));

    _dataFileId ??= await _findFile(_dataFile, headers);

    if (_dataFileId == null) {
      _dataFileId = await _create(
        _dataFile,
        'application/json',
        body,
        headers,
      );
      return;
    }

    final response = await http.patch(
      Uri.parse('$_upload/$_dataFileId?uploadType=media'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: body,
    );

    _check(response, 'save data');
  }

  /// Stores an image in the app folder and returns its Drive file id.
  Future<String> uploadImage(String name, List<int> bytes) async {
    final headers = await _auth.authHeaders();

    return _create(name, 'image/jpeg', bytes, headers);
  }

  /// Deletes a file from the app folder. Already-missing files are ignored.
  Future<void> deleteFile(String fileId) async {
    final headers = await _auth.authHeaders();

    final response = await http.delete(
      Uri.parse('$_api/$fileId'),
      headers: headers,
    );

    if (response.statusCode != 404) _check(response, 'delete file');
  }

  Future<String?> _findFile(String name, Map<String, String> headers) async {
    final response = await http.get(
      Uri.parse(_api).replace(queryParameters: {
        'spaces': 'appDataFolder',
        'q': "name = '$name' and trashed = false",
        'fields': 'files(id)',
      }),
      headers: headers,
    );

    _check(response, 'find data file');

    final files = jsonDecode(response.body)['files'] as List;

    return files.isEmpty ? null : files.first['id'] as String;
  }

  Future<String> _create(
    String name,
    String mimeType,
    List<int> content,
    Map<String, String> headers,
  ) async {
    const boundary = 'muse_boundary_7f3a';

    final metadata = jsonEncode({
      'name': name,
      'parents': ['appDataFolder'],
    });

    final body = BytesBuilder()
      ..add(utf8.encode(
        '--$boundary\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n'
        '$metadata\r\n--$boundary\r\nContent-Type: $mimeType\r\n\r\n',
      ))
      ..add(content)
      ..add(utf8.encode('\r\n--$boundary--'));

    final response = await http.post(
      Uri.parse('$_upload?uploadType=multipart&fields=id'),
      headers: {
        ...headers,
        'Content-Type': 'multipart/related; boundary=$boundary',
      },
      body: body.toBytes(),
    );

    _check(response, 'create $name');

    return jsonDecode(response.body)['id'] as String;
  }

  void _check(http.Response response, String action) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Google Drive: failed to $action (${response.statusCode})',
      );
    }
  }
}
