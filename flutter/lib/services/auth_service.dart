import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../models/github_user.dart';

/// GitHub OAuth configuration using Device Flow
///
/// Device Flow is designed for CLI and native apps that can't securely
/// store secrets. The user authorizes via browser while the app polls
/// for completion. No client secret or callback URLs needed!
///
/// To use this app:
/// 1. Create a GitHub OAuth App at https://github.com/settings/developers
/// 2. Enable "Device Flow" in the app settings
/// 3. Set your Client ID below
class GitHubOAuthConfig {
  // This is safe to commit - Device Flow doesn't require a client secret
  static const String clientId = 'Ov23lipXEkxpcxvqltQV';
  static const String scope = 'repo user read:org';
}

/// Device Flow authorization state
class DeviceFlowState {
  /// The code the user must enter at the verification URL
  final String userCode;

  /// The URL where the user enters the code (usually github.com/login/device)
  final String verificationUri;

  /// Internal device code for polling (don't show to user)
  final String deviceCode;

  /// Seconds until this authorization request expires
  final int expiresIn;

  /// Minimum seconds between poll requests
  final int interval;

  DeviceFlowState({
    required this.userCode,
    required this.verificationUri,
    required this.deviceCode,
    required this.expiresIn,
    required this.interval,
  });
}

/// Storage abstraction that uses file-based storage on Linux
/// (where flutter_secure_storage often fails silently) and
/// secure storage on other platforms.
class _SessionStorage {
  static const _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'github_access_token';
  static const _userKey = 'github_user';

  /// Get the config directory for storing session data
  static Directory get _configDir {
    final home = Platform.environment['HOME'] ?? '/tmp';
    final xdgConfig =
        Platform.environment['XDG_CONFIG_HOME'] ?? p.join(home, '.config');
    return Directory(p.join(xdgConfig, 'interactions.work'));
  }

  static File get _sessionFile => File(p.join(_configDir.path, 'session.json'));

  /// Read a value from storage
  Future<String?> read(String key) async {
    // On Linux, use file-based storage as flutter_secure_storage is unreliable
    if (Platform.isLinux) {
      return _readFromFile(key);
    }
    return _secureStorage.read(key: key);
  }

  /// Write a value to storage
  Future<void> write(String key, String value) async {
    if (Platform.isLinux) {
      await _writeToFile(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  /// Delete a value from storage
  Future<void> delete(String key) async {
    if (Platform.isLinux) {
      await _deleteFromFile(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  Future<String?> _readFromFile(String key) async {
    try {
      if (!_sessionFile.existsSync()) {
        return null;
      }
      final content = await _sessionFile.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      return data[key] as String?;
    } catch (e) {
      debugPrint('Failed to read from file: $e');
      return null;
    }
  }

  Future<void> _writeToFile(String key, String value) async {
    try {
      if (!_configDir.existsSync()) {
        _configDir.createSync(recursive: true);
      }

      Map<String, dynamic> data = {};
      if (_sessionFile.existsSync()) {
        final content = await _sessionFile.readAsString();
        data = jsonDecode(content) as Map<String, dynamic>;
      }

      data[key] = value;
      await _sessionFile.writeAsString(jsonEncode(data));

      // Set restrictive permissions (owner read/write only)
      await Process.run('chmod', ['600', _sessionFile.path]);
    } catch (e) {
      debugPrint('Failed to write to file: $e');
    }
  }

  Future<void> _deleteFromFile(String key) async {
    try {
      if (!_sessionFile.existsSync()) {
        return;
      }
      final content = await _sessionFile.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      data.remove(key);

      if (data.isEmpty) {
        await _sessionFile.delete();
      } else {
        await _sessionFile.writeAsString(jsonEncode(data));
      }
    } catch (e) {
      debugPrint('Failed to delete from file: $e');
    }
  }
}

class AuthService {
  final _storage = _SessionStorage();
  static const _tokenKey = _SessionStorage._tokenKey;
  static const _userKey = _SessionStorage._userKey;

  /// Attempt to restore a saved session
  Future<AuthSession?> restoreSession() async {
    try {
      debugPrint('Attempting to restore session...');
      final token = await _storage.read(_tokenKey);
      final userJson = await _storage.read(_userKey);

      debugPrint('Token found: ${token != null}');
      debugPrint('User JSON found: ${userJson != null}');

      if (token == null || userJson == null) {
        debugPrint('No saved session found');
        return null;
      }

      // Validate the token is still valid by making a test request
      final testResponse = await http.get(
        Uri.https('api.github.com', '/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github+json',
        },
      );

      if (testResponse.statusCode != 200) {
        debugPrint(
            'Saved token is no longer valid (${testResponse.statusCode})');
        await clearSession();
        return null;
      }

      final user = GitHubUser.fromJson(jsonDecode(userJson));
      debugPrint('Session restored for: ${user.login}');
      return AuthSession(accessToken: token, user: user);
    } catch (e) {
      debugPrint('Failed to restore session: $e');
      await clearSession();
      return null;
    }
  }

  /// Step 1: Start Device Flow - returns codes for user to enter
  Future<DeviceFlowState> startDeviceFlow() async {
    final response = await http.post(
      Uri.https('github.com', '/login/device/code'),
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': GitHubOAuthConfig.clientId,
        'scope': GitHubOAuthConfig.scope,
      },
    );

    if (response.statusCode != 200) {
      throw AuthException('Failed to start device flow: ${response.body}');
    }

    final json = jsonDecode(response.body);

    if (json['error'] != null) {
      throw AuthException(json['error_description'] ?? json['error']);
    }

    return DeviceFlowState(
      userCode: json['user_code'],
      verificationUri: json['verification_uri'],
      deviceCode: json['device_code'],
      expiresIn: json['expires_in'],
      interval: json['interval'] ?? 5,
    );
  }

  /// Step 2: Poll for authorization completion
  ///
  /// Call this repeatedly until it returns a session or throws.
  /// Respects the polling interval from GitHub.
  Future<AuthSession?> pollForToken(DeviceFlowState state) async {
    final response = await http.post(
      Uri.https('github.com', '/login/oauth/access_token'),
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': GitHubOAuthConfig.clientId,
        'device_code': state.deviceCode,
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
      },
    );

    if (response.statusCode != 200) {
      throw AuthException('Failed to poll for token');
    }

    final json = jsonDecode(response.body);
    final error = json['error'];

    if (error == 'authorization_pending') {
      // User hasn't authorized yet - keep polling
      return null;
    } else if (error == 'slow_down') {
      // We're polling too fast - wait longer next time
      return null;
    } else if (error == 'expired_token') {
      throw AuthException('Authorization expired. Please try again.');
    } else if (error == 'access_denied') {
      throw AuthException('Authorization was denied.');
    } else if (error != null) {
      throw AuthException(json['error_description'] ?? error);
    }

    // Success! We have a token
    final accessToken = json['access_token'] as String;

    // Get user info
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

    // Save session
    debugPrint('Saving session for: ${user.login}');
    await _storage.write(_tokenKey, accessToken);
    await _storage.write(_userKey, jsonEncode(user.toJson()));
    debugPrint('Session saved successfully');

    return AuthSession(accessToken: accessToken, user: user);
  }

  /// Convenience method: Complete device flow with polling loop
  ///
  /// [onStateReady] is called with the user code and URL to display
  /// Returns the session when authorization completes
  Future<AuthSession> loginWithDeviceFlow({
    required void Function(DeviceFlowState state) onStateReady,
    void Function()? onPoll,
  }) async {
    final state = await startDeviceFlow();
    onStateReady(state);

    final expiry = DateTime.now().add(Duration(seconds: state.expiresIn));

    while (DateTime.now().isBefore(expiry)) {
      await Future.delayed(Duration(seconds: state.interval));

      onPoll?.call();

      final session = await pollForToken(state);
      if (session != null) {
        return session;
      }
    }

    throw AuthException('Authorization timed out. Please try again.');
  }

  /// Clear the saved session
  Future<void> clearSession() async {
    debugPrint('Clearing saved session');
    await _storage.delete(_tokenKey);
    await _storage.delete(_userKey);
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
