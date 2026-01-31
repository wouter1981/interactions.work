/// Dart models that mirror the Rust core library.
///
/// These models are structured to match the Rust API exactly,
/// making them easy to replace with FFI bindings in the future.
/// When FFI is enabled, this file can simply re-export the generated bindings.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

// ============================================================================
// Authentication
// ============================================================================

/// Credentials for pincode-based authentication.
///
/// Matches Rust: interactions_core::Credentials
class Credentials {
  /// Salt used for hashing (hex encoded)
  final String salt;

  /// Hashed pincode (hex encoded)
  final String pincodeHash;

  const Credentials({required this.salt, required this.pincodeHash});

  /// Create new credentials from a pincode.
  ///
  /// Generates a random salt and hashes the pincode with it.
  /// Throws if pincode is less than 4 characters.
  factory Credentials.create(String pincode) {
    if (pincode.length < 4) {
      throw ArgumentError('Pincode must be at least 4 characters');
    }

    final saltBytes = _generateSalt();
    final hash = _hashPincode(pincode, saltBytes);

    return Credentials(
      salt: _bytesToHex(saltBytes),
      pincodeHash: hash,
    );
  }

  /// Parse from YAML map.
  factory Credentials.fromYaml(Map<String, dynamic> yaml) {
    return Credentials(
      salt: yaml['salt'] as String,
      pincodeHash: yaml['pincode_hash'] as String,
    );
  }

  /// Serialize to YAML map.
  Map<String, dynamic> toYaml() {
    return {
      'salt': salt,
      'pincode_hash': pincodeHash,
    };
  }

  /// Verify a pincode against these credentials.
  bool verify(String pincode) {
    final saltBytes = _hexToBytes(salt);
    final hash = _hashPincode(pincode, saltBytes);
    return _constantTimeEquals(hash, pincodeHash);
  }

  static Uint8List _generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(16, (_) => random.nextInt(256)),
    );
  }

  static String _hashPincode(String pincode, Uint8List salt) {
    final data = Uint8List.fromList([...salt, ...utf8.encode(pincode)]);
    final digest = sha256.convert(data);
    return _bytesToHex(Uint8List.fromList(digest.bytes));
  }

  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

/// Member credentials stored in .team/members/{email}/credentials.yaml
///
/// Matches Rust: interactions_core::MemberCredentials
class MemberCredentials {
  final String email;
  final Credentials credentials;

  const MemberCredentials({required this.email, required this.credentials});

  /// Create new member credentials.
  factory MemberCredentials.create(String email, String pincode) {
    return MemberCredentials(
      email: email,
      credentials: Credentials.create(pincode),
    );
  }

  /// Parse from YAML map.
  factory MemberCredentials.fromYaml(Map<String, dynamic> yaml) {
    return MemberCredentials(
      email: yaml['email'] as String,
      credentials: Credentials.fromYaml(
        yaml['credentials'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serialize to YAML map.
  Map<String, dynamic> toYaml() {
    return {
      'email': email,
      'credentials': credentials.toYaml(),
    };
  }

  /// Verify the pincode.
  bool verify(String pincode) => credentials.verify(pincode);
}

// ============================================================================
// Team
// ============================================================================

/// A team with its manifesto, vision, and members.
///
/// Matches Rust: interactions_core::Team
class Team {
  final String name;
  final String? manifesto;
  final String? vision;
  final List<String> leaders;
  final List<String> members;

  const Team({
    required this.name,
    this.manifesto,
    this.vision,
    this.leaders = const [],
    this.members = const [],
  });

  /// Create a new team with the given name.
  factory Team.create(String name) {
    return Team(name: name);
  }

  /// Parse from YAML map.
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

  /// Serialize to YAML map.
  Map<String, dynamic> toYaml() {
    return {
      'name': name,
      if (manifesto != null) 'manifesto': manifesto,
      if (vision != null) 'vision': vision,
      'leaders': leaders,
      'members': members,
    };
  }

  /// Check if an email is a leader.
  bool isLeader(String email) => leaders.contains(email);

  /// Check if an email is a member (including leaders).
  bool isMember(String email) => members.contains(email) || isLeader(email);

  /// Create a copy with modified fields.
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

// ============================================================================
// Team Configuration
// ============================================================================

/// Configuration for publishing markdown files.
///
/// Matches Rust: interactions_core::PublishConfig
class PublishConfig {
  final String? manifesto;
  final String? vision;
  final String? okrs;

  const PublishConfig({this.manifesto, this.vision, this.okrs});

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

/// Configuration for webhook notifications.
///
/// Matches Rust: interactions_core::WebhookConfig
class WebhookConfig {
  final String? discord;
  final String? slack;
  final String? signal;

  const WebhookConfig({this.discord, this.slack, this.signal});

  factory WebhookConfig.fromYaml(Map<String, dynamic> yaml) {
    return WebhookConfig(
      discord: yaml['discord'] as String?,
      slack: yaml['slack'] as String?,
      signal: yaml['signal'] as String?,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      if (discord != null) 'discord': discord,
      if (slack != null) 'slack': slack,
      if (signal != null) 'signal': signal,
    };
  }
}

/// Configuration for linting on PRs.
///
/// Matches Rust: interactions_core::LintingConfig
class LintingConfig {
  final bool enabled;
  final String? targetBranch;

  const LintingConfig({required this.enabled, this.targetBranch});

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

/// Configuration for backups.
///
/// Matches Rust: interactions_core::BackupConfig
class BackupConfig {
  final String? protectedBranch;

  const BackupConfig({this.protectedBranch});

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

/// Team configuration stored in .team/config.yaml
///
/// Matches Rust: interactions_core::TeamConfig
class TeamConfig {
  final PublishConfig? publish;
  final WebhookConfig? webhooks;
  final LintingConfig? linting;
  final BackupConfig? backup;

  const TeamConfig({
    this.publish,
    this.webhooks,
    this.linting,
    this.backup,
  });

  /// Create an empty configuration.
  factory TeamConfig.create() {
    return const TeamConfig();
  }

  /// Create a default configuration with sensible defaults.
  factory TeamConfig.withDefaults() {
    return const TeamConfig(
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

  factory TeamConfig.fromYaml(Map<String, dynamic> yaml) {
    return TeamConfig(
      publish: yaml['publish'] != null
          ? PublishConfig.fromYaml(yaml['publish'] as Map<String, dynamic>)
          : null,
      webhooks: yaml['webhooks'] != null
          ? WebhookConfig.fromYaml(yaml['webhooks'] as Map<String, dynamic>)
          : null,
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
      if (webhooks != null) 'webhooks': webhooks!.toYaml(),
      if (linting != null) 'linting': linting!.toYaml(),
      if (backup != null) 'backup': backup!.toYaml(),
    };
  }
}

// ============================================================================
// Member
// ============================================================================

/// A team member's profile.
///
/// Matches Rust: interactions_core::Member
class Member {
  final String email;
  final String? name;
  final String? bio;
  final String? timezone;

  const Member({
    required this.email,
    this.name,
    this.bio,
    this.timezone,
  });

  /// Create a new member with the given email.
  factory Member.create(String email) {
    return Member(email: email);
  }

  factory Member.fromYaml(Map<String, dynamic> yaml) {
    return Member(
      email: yaml['email'] as String,
      name: yaml['name'] as String?,
      bio: yaml['bio'] as String?,
      timezone: yaml['timezone'] as String?,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'email': email,
      if (name != null) 'name': name,
      if (bio != null) 'bio': bio,
      if (timezone != null) 'timezone': timezone,
    };
  }

  /// Get the display name, falling back to email if not set.
  String get displayName => name ?? email;

  Member copyWith({
    String? email,
    String? name,
    String? bio,
    String? timezone,
  }) {
    return Member(
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      timezone: timezone ?? this.timezone,
    );
  }
}

// ============================================================================
// Interactions
// ============================================================================

/// The kind of interaction.
///
/// Matches Rust: interactions_core::InteractionKind
enum InteractionKind {
  /// Kudos, recognition, appreciation
  appreciation,

  /// Constructive feedback
  feedback,

  /// Making amends
  apology,

  /// Regular check-in
  checkIn,

  /// Retrospective discussion
  retrospective;

  /// Get a human-readable label for this kind.
  String get label {
    switch (this) {
      case InteractionKind.appreciation:
        return 'Appreciation';
      case InteractionKind.feedback:
        return 'Feedback';
      case InteractionKind.apology:
        return 'Apology';
      case InteractionKind.checkIn:
        return 'Check-in';
      case InteractionKind.retrospective:
        return 'Retrospective';
    }
  }

  /// Get the YAML key for this kind.
  String get yamlKey {
    switch (this) {
      case InteractionKind.appreciation:
        return 'appreciation';
      case InteractionKind.feedback:
        return 'feedback';
      case InteractionKind.apology:
        return 'apology';
      case InteractionKind.checkIn:
        return 'check_in';
      case InteractionKind.retrospective:
        return 'retrospective';
    }
  }

  static InteractionKind fromYaml(String value) {
    switch (value) {
      case 'appreciation':
        return InteractionKind.appreciation;
      case 'feedback':
        return InteractionKind.feedback;
      case 'apology':
        return InteractionKind.apology;
      case 'check_in':
        return InteractionKind.checkIn;
      case 'retrospective':
        return InteractionKind.retrospective;
      default:
        throw ArgumentError('Unknown InteractionKind: $value');
    }
  }
}

/// A logged interaction between people.
///
/// Matches Rust: interactions_core::Interaction
class Interaction {
  final String id;
  final InteractionKind kind;
  final String from;
  final List<String> withMembers;
  final String note;
  final DateTime timestamp;
  final bool shared;

  const Interaction({
    required this.id,
    required this.kind,
    required this.from,
    required this.withMembers,
    required this.note,
    required this.timestamp,
    this.shared = false,
  });

  /// Create a new interaction.
  factory Interaction.create({
    required InteractionKind kind,
    required String from,
    required List<String> withMembers,
    required String note,
  }) {
    final now = DateTime.now();
    final id =
        '${now.millisecondsSinceEpoch.toRadixString(16)}${now.microsecond.toRadixString(16)}';

    return Interaction(
      id: id,
      kind: kind,
      from: from,
      withMembers: withMembers,
      note: note,
      timestamp: now.toUtc(),
      shared: false,
    );
  }

  /// Create an appreciation interaction.
  factory Interaction.appreciation({
    required String from,
    required List<String> withMembers,
    required String note,
  }) {
    return Interaction.create(
      kind: InteractionKind.appreciation,
      from: from,
      withMembers: withMembers,
      note: note,
    );
  }

  /// Create a feedback interaction.
  factory Interaction.feedback({
    required String from,
    required List<String> withMembers,
    required String note,
  }) {
    return Interaction.create(
      kind: InteractionKind.feedback,
      from: from,
      withMembers: withMembers,
      note: note,
    );
  }

  factory Interaction.fromYaml(Map<String, dynamic> yaml) {
    return Interaction(
      id: yaml['id'] as String,
      kind: InteractionKind.fromYaml(yaml['kind'] as String),
      from: yaml['from'] as String,
      withMembers:
          (yaml['with'] as List<dynamic>).map((e) => e as String).toList(),
      note: yaml['note'] as String,
      timestamp: DateTime.parse(yaml['timestamp'] as String),
      shared: yaml['shared'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'id': id,
      'kind': kind.yamlKey,
      'from': from,
      'with': withMembers,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'shared': shared,
    };
  }

  Interaction copyWith({
    String? id,
    InteractionKind? kind,
    String? from,
    List<String>? withMembers,
    String? note,
    DateTime? timestamp,
    bool? shared,
  }) {
    return Interaction(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      from: from ?? this.from,
      withMembers: withMembers ?? this.withMembers,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      shared: shared ?? this.shared,
    );
  }
}

// ============================================================================
// OKRs
// ============================================================================

/// Visibility level for OKRs.
///
/// Matches Rust: interactions_core::OkrVisibility
enum OkrVisibility {
  /// Only visible to the owner
  private,

  /// Visible to team members
  shared;

  String get yamlKey {
    switch (this) {
      case OkrVisibility.private:
        return 'private';
      case OkrVisibility.shared:
        return 'shared';
    }
  }

  static OkrVisibility fromYaml(String value) {
    switch (value) {
      case 'private':
        return OkrVisibility.private;
      case 'shared':
        return OkrVisibility.shared;
      default:
        return OkrVisibility.private;
    }
  }
}

/// A key result that measures progress toward an objective.
///
/// Matches Rust: interactions_core::KeyResult
class KeyResult {
  final String description;
  final double progress;
  final String? notes;

  const KeyResult({
    required this.description,
    this.progress = 0.0,
    this.notes,
  });

  /// Create a new key result.
  factory KeyResult.create(String description) {
    return KeyResult(description: description);
  }

  factory KeyResult.fromYaml(Map<String, dynamic> yaml) {
    return KeyResult(
      description: yaml['description'] as String,
      progress: (yaml['progress'] as num?)?.toDouble() ?? 0.0,
      notes: yaml['notes'] as String?,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'description': description,
      'progress': progress,
      if (notes != null) 'notes': notes,
    };
  }

  /// Clamp progress to valid range (0.0-1.0).
  static double clampProgress(double progress) {
    return progress.clamp(0.0, 1.0);
  }

  KeyResult copyWith({
    String? description,
    double? progress,
    String? notes,
  }) {
    return KeyResult(
      description: description ?? this.description,
      progress: clampProgress(progress ?? this.progress),
      notes: notes ?? this.notes,
    );
  }
}

/// An objective with key results.
///
/// Matches Rust: interactions_core::Objective
class Objective {
  final String id;
  final String title;
  final String? description;
  final List<KeyResult> keyResults;
  final OkrVisibility visibility;
  final String? owner;
  final String? quarter;

  const Objective({
    required this.id,
    required this.title,
    this.description,
    this.keyResults = const [],
    this.visibility = OkrVisibility.private,
    this.owner,
    this.quarter,
  });

  /// Create a new objective.
  factory Objective.create(String title) {
    final now = DateTime.now();
    final id =
        'okr-${now.millisecondsSinceEpoch.toRadixString(16)}${now.microsecond.toRadixString(16)}';

    return Objective(id: id, title: title);
  }

  factory Objective.fromYaml(Map<String, dynamic> yaml) {
    return Objective(
      id: yaml['id'] as String,
      title: yaml['title'] as String,
      description: yaml['description'] as String?,
      keyResults: (yaml['key_results'] as List<dynamic>?)
              ?.map((e) => KeyResult.fromYaml(e as Map<String, dynamic>))
              .toList() ??
          [],
      visibility:
          OkrVisibility.fromYaml(yaml['visibility'] as String? ?? 'private'),
      owner: yaml['owner'] as String?,
      quarter: yaml['quarter'] as String?,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'key_results': keyResults.map((kr) => kr.toYaml()).toList(),
      'visibility': visibility.yamlKey,
      if (owner != null) 'owner': owner,
      if (quarter != null) 'quarter': quarter,
    };
  }

  /// Calculate overall progress based on key results.
  double get overallProgress {
    if (keyResults.isEmpty) return 0.0;
    final sum = keyResults.fold<double>(0.0, (acc, kr) => acc + kr.progress);
    return sum / keyResults.length;
  }

  Objective copyWith({
    String? id,
    String? title,
    String? description,
    List<KeyResult>? keyResults,
    OkrVisibility? visibility,
    String? owner,
    String? quarter,
  }) {
    return Objective(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      keyResults: keyResults ?? this.keyResults,
      visibility: visibility ?? this.visibility,
      owner: owner ?? this.owner,
      quarter: quarter ?? this.quarter,
    );
  }
}
