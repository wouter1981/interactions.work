import 'package:flutter/foundation.dart';

import '../models/github_user.dart';
import '../services/auth_service.dart';

enum AuthState {
  initial,
  loading,
  awaitingDeviceAuth, // Waiting for user to authorize via browser
  authenticated,
  unauthenticated,
  error
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  GitHubUser? _user;
  String? _accessToken;
  String? _error;

  // Device Flow state
  DeviceFlowState? _deviceFlowState;
  bool _cancelled = false;

  AuthState get state => _state;
  GitHubUser? get user => _user;
  String? get accessToken => _accessToken;
  String? get error => _error;
  DeviceFlowState? get deviceFlowState => _deviceFlowState;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isAwaitingDeviceAuth => _state == AuthState.awaitingDeviceAuth;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final session = await _authService.restoreSession();
      if (session != null) {
        _user = session.user;
        _accessToken = session.accessToken;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
      _error = e.toString();
    }

    notifyListeners();
  }

  /// Start the Device Flow login process
  Future<void> login() async {
    _state = AuthState.loading;
    _error = null;
    _cancelled = false;
    notifyListeners();

    try {
      // Step 1: Get device code
      _deviceFlowState = await _authService.startDeviceFlow();
      _state = AuthState.awaitingDeviceAuth;
      notifyListeners();

      // Step 2: Poll for authorization
      final expiry = DateTime.now().add(
        Duration(seconds: _deviceFlowState!.expiresIn),
      );

      while (DateTime.now().isBefore(expiry) && !_cancelled) {
        await Future.delayed(
          Duration(seconds: _deviceFlowState!.interval),
        );

        if (_cancelled) break;

        final session = await _authService.pollForToken(_deviceFlowState!);
        if (session != null) {
          _user = session.user;
          _accessToken = session.accessToken;
          _state = AuthState.authenticated;
          _deviceFlowState = null;
          notifyListeners();
          return;
        }
      }

      // If we get here, either cancelled or timed out
      if (_cancelled) {
        _state = AuthState.unauthenticated;
        _deviceFlowState = null;
      } else {
        _state = AuthState.error;
        _error = 'Authorization timed out. Please try again.';
        _deviceFlowState = null;
      }
    } catch (e) {
      _state = AuthState.error;
      _error = e.toString().replaceFirst('AuthException: ', '');
      _deviceFlowState = null;
    }

    notifyListeners();
  }

  /// Cancel an in-progress Device Flow login
  void cancelLogin() {
    _cancelled = true;
    _state = AuthState.unauthenticated;
    _deviceFlowState = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    await _authService.clearSession();
    _user = null;
    _accessToken = null;
    _state = AuthState.unauthenticated;

    notifyListeners();
  }

  void clearError() {
    _error = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
