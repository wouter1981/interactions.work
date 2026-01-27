/// Team model matching the Rust core library structure
class Team {
  final String name;
  final String? manifesto;
  final String? vision;
  final List<String> leaders;
  final List<String> members;

  Team({
    required this.name,
    this.manifesto,
    this.vision,
    List<String>? leaders,
    List<String>? members,
  })  : leaders = leaders ?? [],
        members = members ?? [];

  factory Team.fromYaml(Map<String, dynamic> yaml) {
    return Team(
      name: yaml['name'] as String,
      manifesto: yaml['manifesto'] as String?,
      vision: yaml['vision'] as String?,
      leaders: (yaml['leaders'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      members: (yaml['members'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'name': name,
      if (manifesto != null) 'manifesto': manifesto,
      if (vision != null) 'vision': vision,
      'leaders': leaders,
      'members': members,
    };
  }

  bool isLeader(String email) => leaders.contains(email);
  bool isMember(String email) => members.contains(email) || isLeader(email);

  Team copyWith({
    String? name,
    String? manifesto,
    String? vision,
    List<String>? leaders,
    List<String>? members,
  }) {
    return Team(
      name: name ?? this.name,
      manifesto: manifesto ?? this.manifesto,
      vision: vision ?? this.vision,
      leaders: leaders ?? this.leaders,
      members: members ?? this.members,
    );
  }
}

/// Team configuration matching .team/config.yaml structure
class TeamConfig {
  final PublishConfig? publish;
  final Map<String, String>? webhooks;
  final LintingConfig? linting;
  final BackupConfig? backup;

  TeamConfig({
    this.publish,
    this.webhooks,
    this.linting,
    this.backup,
  });

  factory TeamConfig.fromYaml(Map<String, dynamic> yaml) {
    return TeamConfig(
      publish: yaml['publish'] != null
          ? PublishConfig.fromYaml(yaml['publish'] as Map<String, dynamic>)
          : null,
      webhooks: (yaml['webhooks'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
      linting: yaml['linting'] != null
          ? LintingConfig.fromYaml(yaml['linting'] as Map<String, dynamic>)
          : null,
      backup: yaml['backup'] != null
          ? BackupConfig.fromYaml(yaml['backup'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      if (publish != null) 'publish': publish!.toYaml(),
      if (webhooks != null) 'webhooks': webhooks,
      if (linting != null) 'linting': linting!.toYaml(),
      if (backup != null) 'backup': backup!.toYaml(),
    };
  }

  factory TeamConfig.defaultConfig() {
    return TeamConfig(
      publish: PublishConfig(
        manifesto: '/MANIFESTO.md',
        vision: '/VISION.md',
        okrs: '/okrs/',
      ),
      linting: LintingConfig(
        enabled: true,
        targetBranch: 'interactions',
      ),
      backup: BackupConfig(
        protectedBranch: 'main',
      ),
    );
  }
}

class PublishConfig {
  final String? manifesto;
  final String? vision;
  final String? okrs;

  PublishConfig({this.manifesto, this.vision, this.okrs});

  factory PublishConfig.fromYaml(Map<String, dynamic> yaml) {
    return PublishConfig(
      manifesto: yaml['manifesto'] as String?,
      vision: yaml['vision'] as String?,
      okrs: yaml['okrs'] as String?,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      if (manifesto != null) 'manifesto': manifesto,
      if (vision != null) 'vision': vision,
      if (okrs != null) 'okrs': okrs,
    };
  }
}

class LintingConfig {
  final bool enabled;
  final String? targetBranch;

  LintingConfig({required this.enabled, this.targetBranch});

  factory LintingConfig.fromYaml(Map<String, dynamic> yaml) {
    return LintingConfig(
      enabled: yaml['enabled'] as bool? ?? false,
      targetBranch: yaml['target_branch'] as String?,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'enabled': enabled,
      if (targetBranch != null) 'target_branch': targetBranch,
    };
  }
}

class BackupConfig {
  final String? protectedBranch;

  BackupConfig({this.protectedBranch});

  factory BackupConfig.fromYaml(Map<String, dynamic> yaml) {
    return BackupConfig(
      protectedBranch: yaml['protected_branch'] as String?,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      if (protectedBranch != null) 'protected_branch': protectedBranch,
    };
  }
}
