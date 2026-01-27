import 'package:flutter_test/flutter_test.dart';

import 'package:interactions/models/team.dart';
import 'package:interactions/models/github_user.dart';
import 'package:interactions/models/github_repository.dart';

void main() {
  group('Team', () {
    test('creates team with required fields', () {
      final team = Team(name: 'Test Team');

      expect(team.name, 'Test Team');
      expect(team.manifesto, isNull);
      expect(team.vision, isNull);
      expect(team.leaders, isEmpty);
      expect(team.members, isEmpty);
    });

    test('creates team with all fields', () {
      final team = Team(
        name: 'Full Team',
        manifesto: 'We value teamwork',
        vision: 'Be the best',
        leaders: ['leader@example.com'],
        members: ['member@example.com'],
      );

      expect(team.name, 'Full Team');
      expect(team.manifesto, 'We value teamwork');
      expect(team.vision, 'Be the best');
      expect(team.leaders, ['leader@example.com']);
      expect(team.members, ['member@example.com']);
    });

    test('isLeader returns correct value', () {
      final team = Team(
        name: 'Test',
        leaders: ['leader@example.com'],
        members: ['member@example.com'],
      );

      expect(team.isLeader('leader@example.com'), isTrue);
      expect(team.isLeader('member@example.com'), isFalse);
      expect(team.isLeader('unknown@example.com'), isFalse);
    });

    test('isMember includes leaders', () {
      final team = Team(
        name: 'Test',
        leaders: ['leader@example.com'],
        members: ['member@example.com'],
      );

      expect(team.isMember('leader@example.com'), isTrue);
      expect(team.isMember('member@example.com'), isTrue);
      expect(team.isMember('unknown@example.com'), isFalse);
    });

    test('toYaml and fromYaml roundtrip', () {
      final original = Team(
        name: 'Roundtrip Team',
        manifesto: 'Our manifesto',
        vision: 'Our vision',
        leaders: ['leader@test.com'],
        members: ['member@test.com'],
      );

      final yaml = original.toYaml();
      final restored = Team.fromYaml(yaml);

      expect(restored.name, original.name);
      expect(restored.manifesto, original.manifesto);
      expect(restored.vision, original.vision);
      expect(restored.leaders, original.leaders);
      expect(restored.members, original.members);
    });
  });

  group('TeamConfig', () {
    test('creates default config', () {
      final config = TeamConfig.defaultConfig();

      expect(config.publish, isNotNull);
      expect(config.publish!.manifesto, '/MANIFESTO.md');
      expect(config.linting, isNotNull);
      expect(config.linting!.enabled, isTrue);
      expect(config.backup, isNotNull);
      expect(config.backup!.protectedBranch, 'main');
    });
  });

  group('GitHubUser', () {
    test('fromJson creates user correctly', () {
      final json = {
        'id': 123,
        'login': 'testuser',
        'name': 'Test User',
        'email': 'test@example.com',
        'avatar_url': 'https://example.com/avatar.png',
        'html_url': 'https://github.com/testuser',
      };

      final user = GitHubUser.fromJson(json);

      expect(user.id, 123);
      expect(user.login, 'testuser');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.avatarUrl, 'https://example.com/avatar.png');
      expect(user.htmlUrl, 'https://github.com/testuser');
    });

    test('displayName returns name or login', () {
      final userWithName = GitHubUser(
        id: 1,
        login: 'user1',
        name: 'Full Name',
        avatarUrl: 'url',
        htmlUrl: 'url',
      );

      final userWithoutName = GitHubUser(
        id: 2,
        login: 'user2',
        avatarUrl: 'url',
        htmlUrl: 'url',
      );

      expect(userWithName.displayName, 'Full Name');
      expect(userWithoutName.displayName, 'user2');
    });
  });

  group('GitHubRepository', () {
    test('fromJson creates repository correctly', () {
      final json = {
        'id': 456,
        'name': 'test-repo',
        'full_name': 'owner/test-repo',
        'description': 'A test repository',
        'private': true,
        'html_url': 'https://github.com/owner/test-repo',
        'default_branch': 'main',
        'owner': {
          'id': 789,
          'login': 'owner',
          'avatar_url': 'https://example.com/owner.png',
          'type': 'User',
        },
        'permissions': {
          'admin': true,
          'push': true,
          'pull': true,
        },
      };

      final repo = GitHubRepository.fromJson(json);

      expect(repo.id, 456);
      expect(repo.name, 'test-repo');
      expect(repo.fullName, 'owner/test-repo');
      expect(repo.description, 'A test repository');
      expect(repo.private, isTrue);
      expect(repo.defaultBranch, 'main');
      expect(repo.owner.login, 'owner');
      expect(repo.canWrite, isTrue);
      expect(repo.isAdmin, isTrue);
    });

    test('canWrite and isAdmin return correct values', () {
      final adminRepo = GitHubRepository(
        id: 1,
        name: 'repo',
        fullName: 'owner/repo',
        private: false,
        htmlUrl: 'url',
        defaultBranch: 'main',
        owner: Owner(id: 1, login: 'owner', avatarUrl: 'url', type: 'User'),
        permissions: Permissions(admin: true, push: true, pull: true),
      );

      final readOnlyRepo = GitHubRepository(
        id: 2,
        name: 'repo2',
        fullName: 'owner/repo2',
        private: false,
        htmlUrl: 'url',
        defaultBranch: 'main',
        owner: Owner(id: 1, login: 'owner', avatarUrl: 'url', type: 'User'),
        permissions: Permissions(admin: false, push: false, pull: true),
      );

      expect(adminRepo.canWrite, isTrue);
      expect(adminRepo.isAdmin, isTrue);
      expect(readOnlyRepo.canWrite, isFalse);
      expect(readOnlyRepo.isAdmin, isFalse);
    });

    test('owner isOrganization returns correct value', () {
      final userOwner = Owner(id: 1, login: 'user', avatarUrl: 'url', type: 'User');
      final orgOwner = Owner(id: 2, login: 'org', avatarUrl: 'url', type: 'Organization');

      expect(userOwner.isOrganization, isFalse);
      expect(orgOwner.isOrganization, isTrue);
    });
  });
}
