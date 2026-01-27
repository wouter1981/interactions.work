class GitHubUser {
  final int id;
  final String login;
  final String? name;
  final String? email;
  final String avatarUrl;
  final String htmlUrl;

  GitHubUser({
    required this.id,
    required this.login,
    this.name,
    this.email,
    required this.avatarUrl,
    required this.htmlUrl,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      id: json['id'] as int,
      login: json['login'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
    };
  }

  String get displayName => name ?? login;
}
