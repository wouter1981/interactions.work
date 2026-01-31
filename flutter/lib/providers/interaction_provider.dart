import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../models/models.dart';
import '../services/github_service.dart';
import 'auth_provider.dart';
import 'repository_provider.dart';
import 'team_provider.dart';

enum InteractionState { initial, loading, loaded, error }

enum SaveInteractionState { idle, saving, success, error }

class InteractionProvider extends ChangeNotifier {
  InteractionState _state = InteractionState.initial;
  String? _error;

  GitHubService? _gitHubService;
  GitHubRepository? _repository;
  String? _teamBranch;
  String? _currentUserEmail;

  // Kudos
  List<Interaction> _sentKudos = [];
  List<Interaction> _receivedKudos = [];

  // Feedback
  List<Interaction> _sentFeedback = [];
  List<Interaction> _receivedFeedback = [];

  // Save state
  SaveInteractionState _saveState = SaveInteractionState.idle;
  String? _saveError;

  // Getters
  InteractionState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == InteractionState.loading;
  String? get currentUserEmail => _currentUserEmail;

  List<Interaction> get sentKudos => _sentKudos;
  List<Interaction> get receivedKudos => _receivedKudos;
  List<Interaction> get sentFeedback => _sentFeedback;
  List<Interaction> get receivedFeedback => _receivedFeedback;

  SaveInteractionState get saveState => _saveState;
  String? get saveError => _saveError;
  bool get isSaving => _saveState == SaveInteractionState.saving;

  /// Get all recent interactions (kudos and feedback combined), sorted by timestamp.
  List<Interaction> get recentActivity {
    final all = [
      ..._receivedKudos,
      ..._sentKudos,
      ..._receivedFeedback,
      ..._sentFeedback,
    ];

    // Remove duplicates by ID (same interaction can appear in sent and received)
    final seen = <String>{};
    final unique = all.where((i) => seen.add(i.id)).toList();

    // Sort by timestamp, newest first
    unique.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return unique;
  }

  void updateDependencies(
    AuthProvider authProvider,
    RepositoryProvider repoProvider,
    TeamProvider teamProvider,
  ) {
    _gitHubService = repoProvider.gitHubService;
    _repository = repoProvider.selectedRepository;
    _teamBranch = teamProvider.teamBranch;
    _currentUserEmail = authProvider.user?.email;

    if (_repository != null &&
        _gitHubService != null &&
        teamProvider.isInitialized) {
      loadInteractions();
    } else {
      _state = InteractionState.initial;
      _sentKudos = [];
      _receivedKudos = [];
      _sentFeedback = [];
      _receivedFeedback = [];
      notifyListeners();
    }
  }

  Future<void> loadInteractions() async {
    if (_gitHubService == null || _repository == null) return;

    _state = InteractionState.loading;
    _error = null;
    notifyListeners();

    try {
      final owner = _repository!.owner.login;
      final repo = _repository!.name;
      final branch = _teamBranch ?? 'interactions';
      final email = _currentUserEmail;

      // Load received kudos for current user
      if (email != null) {
        _receivedKudos = await _loadInteractionsFromDir(
          owner,
          repo,
          '.team/members/$email/kudos',
          branch,
        );

        _receivedFeedback = await _loadInteractionsFromDir(
          owner,
          repo,
          '.team/members/$email/feedback',
          branch,
        );
      }

      // Note: Sent kudos/feedback are in .personal/ which is gitignored,
      // so they won't be available via GitHub API for Flutter.
      // We can only show what's received or shared.

      // Load shared team interactions
      final sharedInteractions = await _loadInteractionsFromDir(
        owner,
        repo,
        '.team/team/interactions',
        branch,
      );

      // Add shared interactions from current user to sent lists
      if (email != null) {
        _sentKudos = sharedInteractions
            .where((i) =>
                i.kind == InteractionKind.appreciation && i.from == email)
            .toList();
        _sentFeedback = sharedInteractions
            .where((i) => i.kind == InteractionKind.feedback && i.from == email)
            .toList();
      }

      _state = InteractionState.loaded;
      notifyListeners();
    } catch (e) {
      _state = InteractionState.error;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<Interaction>> _loadInteractionsFromDir(
    String owner,
    String repo,
    String path,
    String branch,
  ) async {
    try {
      final entries = await _gitHubService!.listDirectory(
        owner,
        repo,
        path,
        ref: branch,
      );

      final interactions = <Interaction>[];

      for (final entry in entries) {
        if (entry.isFile &&
            entry.name.endsWith('.yaml') &&
            entry.name != '.gitkeep') {
          try {
            final content = await _gitHubService!.getFileContent(
              owner,
              repo,
              '$path/${entry.name}',
              ref: branch,
            );

            if (content != null) {
              final yaml = loadYaml(content) as YamlMap?;
              if (yaml != null) {
                interactions.add(
                  Interaction.fromYaml(Map<String, dynamic>.from(yaml)),
                );
              }
            }
          } catch (_) {
            // Skip invalid files
          }
        }
      }

      // Sort by timestamp, newest first
      interactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return interactions;
    } catch (_) {
      // Directory doesn't exist or other error
      return [];
    }
  }

  /// Save a new kudos interaction.
  Future<bool> giveKudos({
    required String from,
    required List<String> to,
    required String note,
    bool shared = false,
  }) async {
    if (_gitHubService == null || _repository == null) {
      _saveError = 'Not connected to repository';
      _saveState = SaveInteractionState.error;
      notifyListeners();
      return false;
    }

    if (to.isEmpty) {
      _saveError = 'Please select at least one recipient';
      _saveState = SaveInteractionState.error;
      notifyListeners();
      return false;
    }

    if (note.trim().isEmpty) {
      _saveError = 'Please enter a message';
      _saveState = SaveInteractionState.error;
      notifyListeners();
      return false;
    }

    _saveState = SaveInteractionState.saving;
    _saveError = null;
    notifyListeners();

    try {
      // Create the interaction using the model (mirrors FFI)
      final interaction = Interaction.appreciation(
        from: from,
        withMembers: to,
        note: note.trim(),
      ).copyWith(shared: shared);

      final owner = _repository!.owner.login;
      final repo = _repository!.name;
      final branch = _teamBranch ?? 'interactions';
      final yamlWriter = YamlWriter();
      final filename = '${interaction.id}.yaml';
      final content = yamlWriter.write(interaction.toYaml());

      // Save to each recipient's kudos folder
      for (final recipient in to) {
        await _gitHubService!.createOrUpdateFile(
          owner: owner,
          repo: repo,
          path: '.team/members/$recipient/kudos/$filename',
          content: content,
          message: 'Give kudos to $recipient',
          branch: branch,
        );
      }

      // If shared, also save to team interactions
      if (shared) {
        await _gitHubService!.createOrUpdateFile(
          owner: owner,
          repo: repo,
          path: '.team/team/interactions/$filename',
          content: content,
          message: 'Share kudos with team',
          branch: branch,
        );
      }

      _saveState = SaveInteractionState.success;
      notifyListeners();

      // Reload interactions
      await loadInteractions();
      return true;
    } catch (e) {
      _saveState = SaveInteractionState.error;
      _saveError = 'Failed to save kudos: $e';
      notifyListeners();
      return false;
    }
  }

  /// Save a new feedback interaction.
  Future<bool> giveFeedback({
    required String from,
    required List<String> to,
    required String note,
    bool shared = false,
  }) async {
    if (_gitHubService == null || _repository == null) {
      _saveError = 'Not connected to repository';
      _saveState = SaveInteractionState.error;
      notifyListeners();
      return false;
    }

    if (to.isEmpty) {
      _saveError = 'Please select at least one recipient';
      _saveState = SaveInteractionState.error;
      notifyListeners();
      return false;
    }

    if (note.trim().isEmpty) {
      _saveError = 'Please enter feedback';
      _saveState = SaveInteractionState.error;
      notifyListeners();
      return false;
    }

    _saveState = SaveInteractionState.saving;
    _saveError = null;
    notifyListeners();

    try {
      // Create the interaction using the model (mirrors FFI)
      final interaction = Interaction.feedback(
        from: from,
        withMembers: to,
        note: note.trim(),
      ).copyWith(shared: shared);

      final owner = _repository!.owner.login;
      final repo = _repository!.name;
      final branch = _teamBranch ?? 'interactions';
      final yamlWriter = YamlWriter();
      final filename = '${interaction.id}.yaml';
      final content = yamlWriter.write(interaction.toYaml());

      // Save to each recipient's feedback folder
      for (final recipient in to) {
        await _gitHubService!.createOrUpdateFile(
          owner: owner,
          repo: repo,
          path: '.team/members/$recipient/feedback/$filename',
          content: content,
          message: 'Give feedback to $recipient',
          branch: branch,
        );
      }

      // If shared, also save to team interactions
      if (shared) {
        await _gitHubService!.createOrUpdateFile(
          owner: owner,
          repo: repo,
          path: '.team/team/interactions/$filename',
          content: content,
          message: 'Share feedback with team',
          branch: branch,
        );
      }

      _saveState = SaveInteractionState.success;
      notifyListeners();

      // Reload interactions
      await loadInteractions();
      return true;
    } catch (e) {
      _saveState = SaveInteractionState.error;
      _saveError = 'Failed to save feedback: $e';
      notifyListeners();
      return false;
    }
  }

  void resetSaveState() {
    _saveState = SaveInteractionState.idle;
    _saveError = null;
    notifyListeners();
  }
}
