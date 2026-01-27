import 'package:flutter/foundation.dart';

import '../models/github_user.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  GitHubUser? _user;
  String? _accessToken;
  String? _error;

  AuthState get state => _state;
  GitHubUser? get user => _user;
  String? get accessToken => _accessToken;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

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

  Future<void> login() async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      final session = await _authService.login();
      _user = session.user;
      _accessToken = session.accessToken;
      _state = AuthState.authenticated;
    } catch (e) {
      _state = AuthState.error;
      _error = e.toString();
    }

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
