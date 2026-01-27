import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Credentials model matching the Rust core structure.
///
/// Used for pincode-based authentication for team members.
/// The pincode is hashed with a salt and stored in the member's credentials.yaml.
class Credentials {
  /// Salt used for hashing (hex encoded)
  final String salt;

  /// Hashed pincode (hex encoded)
  final String pincodeHash;

  Credentials({required this.salt, required this.pincodeHash});

  /// Create new credentials from a pincode.
  ///
  /// Generates a random salt and hashes the pincode with it.
  factory Credentials.fromPincode(String pincode) {
    if (pincode.length < 4) {
      throw ArgumentError('Pincode must be at least 4 characters');
    }

    final salt = _generateSalt();
    final pincodeHash = _hashPincode(pincode, salt);

    return Credentials(
      salt: _bytesToHex(salt),
      pincodeHash: pincodeHash,
    );
  }

  factory Credentials.fromYaml(Map<String, dynamic> yaml) {
    return Credentials(
      salt: yaml['salt'] as String,
      pincodeHash: yaml['pincode_hash'] as String,
    );
  }

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

  /// Constant-time string comparison to prevent timing attacks.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

/// Member credentials stored in .team/members/{email}/credentials.yaml.
///
/// This matches the Rust MemberCredentials structure.
class MemberCredentials {
  final String email;
  final Credentials credentials;

  MemberCredentials({required this.email, required this.credentials});

  factory MemberCredentials.create(String email, String pincode) {
    return MemberCredentials(
      email: email,
      credentials: Credentials.fromPincode(pincode),
    );
  }

  factory MemberCredentials.fromYaml(Map<String, dynamic> yaml) {
    return MemberCredentials(
      email: yaml['email'] as String,
      credentials: Credentials.fromYaml(
        yaml['credentials'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'email': email,
      'credentials': credentials.toYaml(),
    };
  }

  bool verify(String pincode) => credentials.verify(pincode);
}
