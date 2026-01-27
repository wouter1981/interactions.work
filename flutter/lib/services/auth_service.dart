import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../models/github_user.dart';

/// GitHub OAuth configuration
///
/// To use this app, you need to:
/// 1. Create a GitHub OAuth App at https://github.com/settings/developers
/// 2. Set the callback URL to: interactions.work://callback
/// 3. Replace these values with your app's credentials
class GitHubOAuthConfig {
  // TODO: Replace with your GitHub OAuth App credentials
  // These should be stored securely in production (e.g., environment variables)
  static const String clientId = 'YOUR_GITHUB_CLIENT_ID';
  static const String clientSecret = 'YOUR_GITHUB_CLIENT_SECRET';
  static const String redirectUri = 'interactions.work://callback';
  static const String callbackScheme = 'interactions.work';
  static const String scope = 'repo user read:org';
}

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'github_access_token';
  static const _userKey = 'github_user';

  /// Attempt to restore a saved session
  Future<AuthSession?> restoreSession() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final userJson = await _storage.read(key: _userKey);

      if (token == null || userJson == null) {
        return null;
      }

      final user = GitHubUser.fromJson(jsonDecode(userJson));
      return AuthSession(accessToken: token, user: user);
    } catch (e) {
      debugPrint('Failed to restore session: $e');
      await clearSession();
      return null;
    }
  }

  /// Perform GitHub OAuth login
  Future<AuthSession> login() async {
    // Step 1: Get authorization code
    final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': GitHubOAuthConfig.clientId,
      'redirect_uri': GitHubOAuthConfig.redirectUri,
      'scope': GitHubOAuthConfig.scope,
      'state': _generateState(),
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: GitHubOAuthConfig.callbackScheme,
    );

    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) {
      throw AuthException('No authorization code received');
    }

    // Step 2: Exchange code for access token
    final tokenResponse = await http.post(
      Uri.https('github.com', '/login/oauth/access_token'),
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': GitHubOAuthConfig.clientId,
        'client_secret': GitHubOAuthConfig.clientSecret,
        'code': code,
        'redirect_uri': GitHubOAuthConfig.redirectUri,
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw AuthException('Failed to exchange code for token');
    }

    final tokenJson = jsonDecode(tokenResponse.body);
    final accessToken = tokenJson['access_token'] as String?;

    if (accessToken == null) {
      final error = tokenJson['error_description'] ?? tokenJson['error'];
      throw AuthException('Failed to get access token: $error');
    }

    // Step 3: Get user info
    final userResponse = await http.get(
      Uri.https('api.github.com', '/user'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/vnd.github+json',
      },
    );

    if (userResponse.statusCode != 200) {
      throw AuthException('Failed to get user info');
    }

    final user = GitHubUser.fromJson(jsonDecode(userResponse.body));

    // Step 4: Save session
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

    return AuthSession(accessToken: accessToken, user: user);
  }

  /// Clear the saved session
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Generate a random state for OAuth
  String _generateState() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return base64Encode(utf8.encode(random)).substring(0, 16);
  }
}

class AuthSession {
  final String accessToken;
  final GitHubUser user;

  AuthSession({required this.accessToken, required this.user});
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
