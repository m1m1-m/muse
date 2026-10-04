import 'package:google_sign_in/google_sign_in.dart';

import 'api_service.dart';

const String driveAppDataScope =
    'https://www.googleapis.com/auth/drive.appdata';

/// Google-only sign in. Grants MUSE access to its own hidden app folder in the
/// user's Google Drive (drive.appdata). No other Drive files are visible to it.
class AuthService {
  static final GoogleSignIn _google = GoogleSignIn(
    scopes: [driveAppDataScope],
  );

  static GoogleSignInAccount? get currentUser => _google.currentUser;

  Future<GoogleSignInAccount?> restore() => _google.signInSilently();

  Future<GoogleSignInAccount?> signIn() async {
    final account = await _google.signIn();

    if (account == null) return null;

    // canAccessScopes/requestScopes are web-only. On Android the scope is
    // granted during signIn, so verify by actually reaching the Drive folder.
    try {
      await ApiService().getWardrobe();
    } catch (e) {
      await _google.signOut();
      ApiService.reset();
      throw Exception('Google Drive access is required to store your data. $e');
    }

    return account;
  }

  Future<Map<String, String>> authHeaders() async {
    final account = _google.currentUser ?? await _google.signInSilently();

    if (account == null) {
      throw Exception('User is not logged in');
    }

    return account.authHeaders;
  }

  Future<void> logout() async {
    ApiService.reset();
    await _google.signOut();
  }
}
