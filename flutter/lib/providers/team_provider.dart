import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../models/models.dart';
import '../services/github_service.dart';
import 'repository_provider.dart';

enum TeamState { initial, loading, checking, notFound, found, creating, error }

enum AddMemberState { idle, adding, success, error }

class TeamProvider extends ChangeNotifier {
  TeamState _state = TeamState.initial;
  Team? _team;
  TeamConfig? _config;
  String? _error;
  String? _teamBranch;

  GitHubService? _gitHubService;
  GitHubRepository? _repository;

  // Member-related state
  Map<String, Member> _memberProfiles = {};
  AddMemberState _addMemberState = AddMemberState.idle;
  String? _addMemberError;

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

  // Member getters
  Map<String, Member> get memberProfiles => _memberProfiles;
  AddMemberState get addMemberState => _addMemberState;
  String? get addMemberError => _addMemberError;
  bool get isAddingMember => _addMemberState == AddMemberState.adding;

  /// Check if the given email belongs to a team leader.
  bool isLeader(String? email) {
    if (email == null || _team == null) return false;
    return _team!.isLeader(email);
  }

  /// Get all team members (leaders + regular members) with their profiles.
  List<MemberWithRole> getAllMembers() {
    if (_team == null) return [];

    final List<MemberWithRole> result = [];

    // Add leaders first
    for (final email in _team!.leaders) {
      final profile = _memberProfiles[email] ?? Member(email: email);
      result.add(MemberWithRole(member: profile, isLeader: true));
    }

    // Add regular members
    for (final email in _team!.members) {
      final profile = _memberProfiles[email] ?? Member(email: email);
      result.add(MemberWithRole(member: profile, isLeader: false));
    }

    return result;
  }

  void updateRepository(RepositoryProvider repoProvider) {
    _gitHubService = repoProvider.gitHubService;
    _repository = repoProvider.selectedRepository;

    if (_repository != null && _gitHubService != null) {
      checkForTeam();
    } else {
      _state = TeamState.initial;
      _team = null;
      _config = null;
      _memberProfiles = {};
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
      // Load config.yaml which contains both Team and TeamConfig data
      // This matches how Rust core's load_team() works (reads from config.yaml)
      final configContent = await _gitHubService!.getFileContent(
        owner,
        repo,
        '.team/config.yaml',
        ref: branch,
      );

      if (configContent != null) {
        final configYaml = loadYaml(configContent) as YamlMap?;
        if (configYaml != null) {
          final yamlMap = Map<String, dynamic>.from(configYaml);
          _config = TeamConfig.fromYaml(yamlMap);

          // config.yaml also contains Team data (name, leaders, members)
          if (yamlMap.containsKey('name')) {
            _team = Team.fromYaml(yamlMap);
          } else {
            _team = Team(name: repo);
          }
        }
      } else {
        // Create default team from repo name
        _team = Team(name: repo);
      }

      _state = TeamState.found;
      notifyListeners();

      // Load member profiles in the background
      await _loadMemberProfiles(owner, repo, branch);
    } catch (e) {
      _state = TeamState.error;
      _error = 'Failed to load team data: $e';
      notifyListeners();
    }
  }

  /// Load member profiles for all team members (leaders + members).
  /// Profiles are loaded from .team/members/{email}/profile.yaml
  Future<void> _loadMemberProfiles(
      String owner, String repo, String branch) async {
    if (_team == null) return;

    // Load profiles for all members listed in the team (leaders + members)
    final allEmails = {..._team!.leaders, ..._team!.members};

    for (final email in allEmails) {
      try {
        final content = await _gitHubService!.getFileContent(
          owner,
          repo,
          '.team/members/$email/profile.yaml',
          ref: branch,
        );

        if (content != null) {
          final yaml = loadYaml(content) as YamlMap?;
          if (yaml != null) {
            _memberProfiles[email] =
                Member.fromYaml(Map<String, dynamic>.from(yaml));
          } else {
            _memberProfiles[email] = Member(email: email);
          }
        } else {
          _memberProfiles[email] = Member(email: email);
        }
      } catch (_) {
        // Profile doesn't exist or couldn't be loaded, use default
        _memberProfiles[email] = Member(email: email);
      }
    }

    notifyListeners();
  }

  /// Add a new member to the team.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> addMember({
    required String email,
    String? name,
  }) async {
    if (_gitHubService == null || _repository == null || _team == null) {
      _addMemberError = 'Not connected to repository';
      _addMemberState = AddMemberState.error;
      notifyListeners();
      return false;
    }

    // Validate email
    if (email.isEmpty || !email.contains('@')) {
      _addMemberError = 'Please enter a valid email address';
      _addMemberState = AddMemberState.error;
      notifyListeners();
      return false;
    }

    // Check if member already exists
    if (_team!.isMember(email)) {
      _addMemberError = 'This person is already a team member';
      _addMemberState = AddMemberState.error;
      notifyListeners();
      return false;
    }

    _addMemberState = AddMemberState.adding;
    _addMemberError = null;
    notifyListeners();

    try {
      final owner = _repository!.owner.login;
      final repo = _repository!.name;
      final yamlWriter = YamlWriter();

      // Create member profile
      final member = Member(email: email, name: name);
      final memberYaml = member.toYaml();

      await _gitHubService!.createOrUpdateFile(
        owner: owner,
        repo: repo,
        path: '.team/members/$email/profile.yaml',
        content: yamlWriter.write(memberYaml),
        message: 'Add team member: $email',
        branch: _teamBranch ?? 'interactions',
      );

      // Update team.yaml with new member
      final updatedTeam = _team!.copyWith(
        members: [..._team!.members, email],
      );

      await _gitHubService!.createOrUpdateFile(
        owner: owner,
        repo: repo,
        path: '.team/team.yaml',
        content: yamlWriter.write(updatedTeam.toYaml()),
        message: 'Add $email to team members',
        branch: _teamBranch ?? 'interactions',
      );

      // Update local state
      _team = updatedTeam;
      _memberProfiles[email] = member;
      _addMemberState = AddMemberState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _addMemberState = AddMemberState.error;
      _addMemberError = 'Failed to add member: $e';
      notifyListeners();
      return false;
    }
  }

  /// Reset the add member state.
  void resetAddMemberState() {
    _addMemberState = AddMemberState.idle;
    _addMemberError = null;
    notifyListeners();
  }

  Future<void> createTeam({
    required String name,
    String? manifesto,
    String? vision,
    required String leaderEmail,
    required String leaderName,
    required String pincode,
  }) async {
    if (_gitHubService == null || _repository == null) {
      _error = 'Not connected to repository';
      _state = TeamState.error;
      notifyListeners();
      return;
    }

    if (pincode.length < 4) {
      _error = 'Pincode must be at least 4 characters';
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
      _config = TeamConfig.withDefaults();

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

      // Create leader's member profile
      final memberProfile = {
        'email': leaderEmail,
        'name': leaderName,
      };

      await _gitHubService!.createOrUpdateFile(
        owner: owner,
        repo: repo,
        path: '.team/members/$leaderEmail/profile.yaml',
        content: yamlWriter.write(memberProfile),
        message: 'Initialize team: create leader profile',
        branch: 'interactions',
      );

      // Create leader's credentials for TUI login
      final credentials = MemberCredentials.create(leaderEmail, pincode);

      await _gitHubService!.createOrUpdateFile(
        owner: owner,
        repo: repo,
        path: '.team/members/$leaderEmail/credentials.yaml',
        content: yamlWriter.write(credentials.toYaml()),
        message: 'Initialize team: create leader credentials',
        branch: 'interactions',
      );

      // Create placeholder directories with .gitkeep
      final directories = [
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

/// Helper class to represent a member with their role.
class MemberWithRole {
  final Member member;
  final bool isLeader;

  const MemberWithRole({required this.member, required this.isLeader});
}
