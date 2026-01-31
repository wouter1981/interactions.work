import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/github_user.dart';
import '../models/github_repository.dart';

class GitHubService {
  static const String _baseUrl = 'https://api.github.com';

  final String _accessToken;

  GitHubService(this._accessToken);

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_accessToken',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      };

  /// Get the authenticated user
  Future<GitHubUser> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw GitHubException('Failed to get user: ${response.body}');
    }

    return GitHubUser.fromJson(jsonDecode(response.body));
  }

  /// Get repositories the user has access to
  Future<List<GitHubRepository>> getRepositories({
    int perPage = 100,
    int page = 1,
    String sort = 'updated',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/user/repos?per_page=$perPage&page=$page&sort=$sort',
      ),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw GitHubException('Failed to get repositories: ${response.body}');
    }

    final List<dynamic> json = jsonDecode(response.body);
    return json
        .map((e) => GitHubRepository.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific repository
  Future<GitHubRepository> getRepository(String owner, String repo) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw GitHubException('Failed to get repository: ${response.body}');
    }

    return GitHubRepository.fromJson(jsonDecode(response.body));
  }

  /// Check if a file exists in a repository
  Future<bool> fileExists(String owner, String repo, String path,
      {String? ref}) async {
    final uri = ref != null
        ? Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$path?ref=$ref')
        : Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$path');

    final response = await http.get(uri, headers: _headers);
    return response.statusCode == 200;
  }

  /// Get file content from a repository
  Future<String?> getFileContent(String owner, String repo, String path,
      {String? ref}) async {
    final uri = ref != null
        ? Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$path?ref=$ref')
        : Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$path');

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body);
    final content = json['content'] as String?;

    if (content == null) return null;

    // GitHub returns base64 encoded content
    return utf8.decode(base64Decode(content.replaceAll('\n', '')));
  }

  /// Create or update a file in a repository
  Future<void> createOrUpdateFile({
    required String owner,
    required String repo,
    required String path,
    required String content,
    required String message,
    String? branch,
    String? sha, // Required for updates
  }) async {
    final body = {
      'message': message,
      'content': base64Encode(utf8.encode(content)),
      if (branch != null) 'branch': branch,
      if (sha != null) 'sha': sha,
    };

    final response = await http.put(
      Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$path'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw GitHubException('Failed to create/update file: ${response.body}');
    }
  }

  /// Get or create a branch
  Future<String> getOrCreateBranch(
    String owner,
    String repo,
    String branchName,
    String fromBranch,
  ) async {
    // First check if branch exists
    final branchResponse = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/branches/$branchName'),
      headers: _headers,
    );

    if (branchResponse.statusCode == 200) {
      final json = jsonDecode(branchResponse.body);
      return json['commit']['sha'] as String;
    }

    // Get the SHA of the source branch
    final sourceResponse = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/branches/$fromBranch'),
      headers: _headers,
    );

    if (sourceResponse.statusCode != 200) {
      throw GitHubException('Source branch not found: $fromBranch');
    }

    final sourceSha =
        jsonDecode(sourceResponse.body)['commit']['sha'] as String;

    // Create the new branch
    final createResponse = await http.post(
      Uri.parse('$_baseUrl/repos/$owner/$repo/git/refs'),
      headers: _headers,
      body: jsonEncode({
        'ref': 'refs/heads/$branchName',
        'sha': sourceSha,
      }),
    );

    if (createResponse.statusCode != 201) {
      throw GitHubException('Failed to create branch: ${createResponse.body}');
    }

    return sourceSha;
  }

  /// List branches in a repository
  Future<List<String>> listBranches(String owner, String repo) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/branches'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw GitHubException('Failed to list branches: ${response.body}');
    }

    final List<dynamic> json = jsonDecode(response.body);
    return json.map((e) => e['name'] as String).toList();
  }

  /// List directory contents in a repository
  /// Returns a list of names (files and directories) in the given path
  Future<List<DirectoryEntry>> listDirectory(
    String owner,
    String repo,
    String path, {
    String? ref,
  }) async {
    final uri = ref != null
        ? Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$path?ref=$ref')
        : Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$path');

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      return [];
    }

    final json = jsonDecode(response.body);

    // GitHub returns an array for directories
    if (json is List) {
      return json
          .map((e) => DirectoryEntry(
                name: e['name'] as String,
                type: e['type'] as String,
              ))
          .toList();
    }

    return [];
  }
}

/// Represents an entry in a directory listing
class DirectoryEntry {
  final String name;
  final String type; // 'file' or 'dir'

  DirectoryEntry({required this.name, required this.type});

  bool get isDirectory => type == 'dir';
  bool get isFile => type == 'file';
}

class GitHubException implements Exception {
  final String message;
  GitHubException(this.message);

  @override
  String toString() => 'GitHubException: $message';
}
