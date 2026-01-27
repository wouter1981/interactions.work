import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../models/github_repository.dart';
import '../services/github_service.dart';
import 'auth_provider.dart';

enum RepositoryState { initial, loading, loaded, error }

class RepositoryProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _selectedRepoKey = 'selected_repository';

  RepositoryState _state = RepositoryState.initial;
  List<GitHubRepository> _repositories = [];
  GitHubRepository? _selectedRepository;
  String? _error;

  GitHubService? _gitHubService;

  RepositoryState get state => _state;
  List<GitHubRepository> get repositories => _repositories;
  GitHubRepository? get selectedRepository => _selectedRepository;
  String? get error => _error;
  bool get isLoading => _state == RepositoryState.loading;

  GitHubService? get gitHubService => _gitHubService;

  void updateAuth(AuthProvider auth) {
    if (auth.isAuthenticated && auth.accessToken != null) {
      _gitHubService = GitHubService(auth.accessToken!);
      _loadSavedRepository();
    } else {
      _gitHubService = null;
      _repositories = [];
      _selectedRepository = null;
      _state = RepositoryState.initial;
      notifyListeners();
    }
  }

  Future<void> _loadSavedRepository() async {
    try {
      final savedJson = await _storage.read(key: _selectedRepoKey);
      if (savedJson != null && _gitHubService != null) {
        final saved = GitHubRepository.fromJson(jsonDecode(savedJson));
        // Verify the repository still exists and user has access
        try {
          _selectedRepository = await _gitHubService!.getRepository(
            saved.owner.login,
            saved.name,
          );
          notifyListeners();
        } catch (e) {
          // Repository no longer accessible, clear it
          await _storage.delete(key: _selectedRepoKey);
        }
      }
    } catch (e) {
      debugPrint('Failed to load saved repository: $e');
    }
  }

  Future<void> fetchRepositories() async {
    if (_gitHubService == null) {
      _error = 'Not authenticated';
      _state = RepositoryState.error;
      notifyListeners();
      return;
    }

    _state = RepositoryState.loading;
    _error = null;
    notifyListeners();

    try {
      _repositories = await _gitHubService!.getRepositories();
      _state = RepositoryState.loaded;
    } catch (e) {
      _state = RepositoryState.error;
      _error = e.toString();
    }

    notifyListeners();
  }

  Future<void> selectRepository(GitHubRepository repository) async {
    _selectedRepository = repository;
    await _storage.write(
      key: _selectedRepoKey,
      value: jsonEncode(repository.toJson()),
    );
    notifyListeners();
  }

  Future<void> clearSelection() async {
    _selectedRepository = null;
    await _storage.delete(key: _selectedRepoKey);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    if (_state == RepositoryState.error) {
      _state = RepositoryState.initial;
    }
    notifyListeners();
  }
}
