class GitHubRepository {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final bool private;
  final String htmlUrl;
  final String defaultBranch;
  final Owner owner;
  final Permissions? permissions;

  GitHubRepository({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.private,
    required this.htmlUrl,
    required this.defaultBranch,
    required this.owner,
    this.permissions,
  });

  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    return GitHubRepository(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String?,
      private: json['private'] as bool,
      htmlUrl: json['html_url'] as String,
      defaultBranch: json['default_branch'] as String? ?? 'main',
      owner: Owner.fromJson(json['owner'] as Map<String, dynamic>),
      permissions: json['permissions'] != null
          ? Permissions.fromJson(json['permissions'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'private': private,
      'html_url': htmlUrl,
      'default_branch': defaultBranch,
      'owner': owner.toJson(),
      'permissions': permissions?.toJson(),
    };
  }

  bool get canWrite => permissions?.push ?? false;
  bool get isAdmin => permissions?.admin ?? false;
}

class Owner {
  final int id;
  final String login;
  final String avatarUrl;
  final String type; // "User" or "Organization"

  Owner({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.type,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'] as int,
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'type': type,
    };
  }

  bool get isOrganization => type == 'Organization';
}

class Permissions {
  final bool admin;
  final bool push;
  final bool pull;

  Permissions({
    required this.admin,
    required this.push,
    required this.pull,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      admin: json['admin'] as bool? ?? false,
      push: json['push'] as bool? ?? false,
      pull: json['pull'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin': admin,
      'push': push,
      'pull': pull,
    };
  }
}
