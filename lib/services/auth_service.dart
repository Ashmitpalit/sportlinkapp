import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthServiceApi {
  AuthServiceApi({required this.baseUrl});
  final String baseUrl; // e.g. http://localhost:3000

  // Set your iOS Google client ID to avoid runtime crash if plist isn't picked up
  static const String _iosGoogleClientId =
      '568889191116-85ieqljt80a6ouraviuvue2kkl7de2m1.apps.googleusercontent.com';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  Future<void> _saveTokens(String access, String refresh) async {
    final p = await _prefs;
    await p.setString('accessToken', access);
    await p.setString('refreshToken', refresh);
  }

  Future<String?> get accessToken async =>
      (await _prefs).getString('accessToken');
  Future<String?> get refreshToken async =>
      (await _prefs).getString('refreshToken');

  Future<void> signupWithEmail(String email, String password,
      {String? name}) async {
    final res = await _post('/api/auth/signup',
        {'email': email, 'password': password, 'name': name});
    await _saveTokens(
        res['accessToken'] as String, res['refreshToken'] as String);
  }

  Future<void> loginWithEmail(String email, String password) async {
    final res =
        await _post('/api/auth/login', {'email': email, 'password': password});
    await _saveTokens(
        res['accessToken'] as String, res['refreshToken'] as String);
  }

  Future<Map<String, dynamic>> me() async {
    final token = await accessToken;
    if (token == null) throw Exception('No token');
    final res = await http.get(Uri.parse('$baseUrl/api/auth/me'),
        headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode == 401) {
      await refresh();
      return me();
    }
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  Future<void> refresh() async {
    final rt = await refreshToken;
    if (rt == null) throw Exception('No refresh token');
    final res = await _post('/api/auth/refresh', {'refreshToken': rt});
    await _saveTokens(
        res['accessToken'] as String, res['refreshToken'] as String);
  }

  Future<void> logout() async {
    final rt = await refreshToken;
    if (rt != null) {
      try {
        await _post('/api/auth/logout', {'refreshToken': rt});
      } catch (_) {}
    }
    final p = await _prefs;
    await p.remove('accessToken');
    await p.remove('refreshToken');
  }

  Future<void> signInWithGoogle() async {
    final google =
        GoogleSignIn(scopes: ['email'], clientId: _iosGoogleClientId);
    final acct = await google.signIn();
    if (acct == null) throw Exception('Cancelled');
    final auth = await acct.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('No Google idToken');
    final res = await _post('/api/auth/google', {'idToken': idToken});
    await _saveTokens(
        res['accessToken'] as String, res['refreshToken'] as String);
  }

  Future<void> signInWithApple() async {
    final result = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ]);
    final identityToken = result.identityToken;
    if (identityToken == null) {
      throw Exception('No Apple identityToken');
    }
    final res =
        await _post('/api/auth/apple', {'identityToken': identityToken});
    await _saveTokens(
        res['accessToken'] as String, res['refreshToken'] as String);
  }
}
