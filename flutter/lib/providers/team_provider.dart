import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../models/team.dart';
import '../models/github_repository.dart';
import '../services/github_service.dart';
import 'repository_provider.dart';

enum TeamState { initial, loading, checking, notFound, found, creating, error }

class TeamProvider extends ChangeNotifier {
  TeamState _state = TeamState.initial;
  Team? _team;
  TeamConfig? _config;
  String? _error;
  String? _teamBranch;

  GitHubService? _gitHubService;
  GitHubRepository? _repository;

  TeamState get state => _state;
  Team? get team => _team;
  TeamConfig? get config => _config;
  String? get error => _error;
  String? get teamBranch => _teamBranch;
  bool get isInitialized => _state == TeamState.found && _team != null;
  bool get isLoading =>
      _state == TeamState.loading ||
      _state == TeamState.checking ||
      _state == TeamState.creating;

  void updateRepository(RepositoryProvider repoProvider) {
    _gitHubService = repoProvider.gitHubService;
    _repository = repoProvider.selectedRepository;

    if (_repository != null && _gitHubService != null) {
      checkForTeam();
    } else {
      _state = TeamState.initial;
      _team = null;
      _config = null;
      notifyListeners();
    }
  }

  Future<void> checkForTeam() async {
    if (_gitHubService == null || _repository == null) {
      return;
    }

    _state = TeamState.checking;
    _error = null;
    notifyListeners();

    try {
      final owner = _repository!.owner.login;
      final repo = _repository!.name;

      // Check for 'interactions' branch first (preferred)
      final branches = await _gitHubService!.listBranches(owner, repo);

      String? checkBranch;
      if (branches.contains('interactions')) {
        checkBranch = 'interactions';
      } else if (branches.contains(_repository!.defaultBranch)) {
        checkBranch = _repository!.defaultBranch;
      }

      if (checkBranch != null) {
        // Check if .team/config.yaml exists
        final configExists = await _gitHubService!.fileExists(
          owner,
          repo,
          '.team/config.yaml',
          ref: checkBranch,
        );

        if (configExists) {
          _teamBranch = checkBranch;
          await _loadTeamData(owner, repo, checkBranch);
          return;
        }
      }

      // No team found
      _state = TeamState.notFound;
      notifyListeners();
    } catch (e) {
      _state = TeamState.error;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _loadTeamData(String owner, String repo, String branch) async {
    try {
      // Load config
      final configContent = await _gitHubService!.getFileContent(
        owner,
        repo,
        '.team/config.yaml',
        ref: branch,
      );

      if (configContent != null) {
        final configYaml = loadYaml(configContent) as YamlMap?;
        if (configYaml != null) {
          _config = TeamConfig.fromYaml(Map<String, dynamic>.from(configYaml));
        }
      }

      // Load team info if exists
      final teamContent = await _gitHubService!.getFileContent(
        owner,
        repo,
        '.team/team.yaml',
        ref: branch,
      );

      if (teamContent != null) {
        final teamYaml = loadYaml(teamContent) as YamlMap?;
        if (teamYaml != null) {
          _team = Team.fromYaml(Map<String, dynamic>.from(teamYaml));
        }
      } else {
        // Create default team from repo name
        _team = Team(name: repo);
      }

      _state = TeamState.found;
      notifyListeners();
    } catch (e) {
      _state = TeamState.error;
      _error = 'Failed to load team data: $e';
      notifyListeners();
    }
  }

  Future<void> createTeam({
    required String name,
    String? manifesto,
    String? vision,
    required String leaderEmail,
  }) async {
    if (_gitHubService == null || _repository == null) {
      _error = 'Not connected to repository';
      _state = TeamState.error;
      notifyListeners();
      return;
    }

    _state = TeamState.creating;
    _error = null;
    notifyListeners();

    try {
      final owner = _repository!.owner.login;
      final repo = _repository!.name;
      final defaultBranch = _repository!.defaultBranch;

      // Create or get the 'interactions' branch
      await _gitHubService!.getOrCreateBranch(
        owner,
        repo,
        'interactions',
        defaultBranch,
      );

      _teamBranch = 'interactions';

      // Create the team
      _team = Team(
        name: name,
        manifesto: manifesto,
        vision: vision,
        leaders: [leaderEmail],
        members: [],
      );

      // Create default config
      _config = TeamConfig.defaultConfig();

      final yamlWriter = YamlWriter();

      // Create .team/config.yaml
      await _gitHubService!.createOrUpdateFile(
        owner: owner,
        repo: repo,
        path: '.team/config.yaml',
        content: yamlWriter.write(_config!.toYaml()),
        message: 'Initialize team: create config',
        branch: 'interactions',
      );

      // Create .team/team.yaml
      await _gitHubService!.createOrUpdateFile(
        owner: owner,
        repo: repo,
        path: '.team/team.yaml',
        content: yamlWriter.write(_team!.toYaml()),
        message: 'Initialize team: create team definition',
        branch: 'interactions',
      );

      // Create .team/manifesto.yaml if provided
      if (manifesto != null && manifesto.isNotEmpty) {
        await _gitHubService!.createOrUpdateFile(
          owner: owner,
          repo: repo,
          path: '.team/manifesto.yaml',
          content: yamlWriter.write({'content': manifesto}),
          message: 'Initialize team: create manifesto',
          branch: 'interactions',
        );
      }

      // Create .team/vision.yaml if provided
      if (vision != null && vision.isNotEmpty) {
        await _gitHubService!.createOrUpdateFile(
          owner: owner,
          repo: repo,
          path: '.team/vision.yaml',
          content: yamlWriter.write({'content': vision}),
          message: 'Initialize team: create vision',
          branch: 'interactions',
        );
      }

      // Create placeholder directories with .gitkeep
      final directories = [
        '.team/members',
        '.team/team/okrs',
        '.team/team/interactions',
        '.team/team/retrospectives',
        '.team/drafts',
      ];

      for (final dir in directories) {
        await _gitHubService!.createOrUpdateFile(
          owner: owner,
          repo: repo,
          path: '$dir/.gitkeep',
          content: '# This file keeps the directory in git\n',
          message: 'Initialize team: create $dir directory',
          branch: 'interactions',
        );
      }

      _state = TeamState.found;
      notifyListeners();
    } catch (e) {
      _state = TeamState.error;
      _error = 'Failed to create team: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
