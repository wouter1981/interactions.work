# Interoperability Tests

Cross-platform test vectors to verify iOS and Android implementations speak the same protocol.

## What to Test

- Envelope serialization/deserialization
- Encryption: both apps encrypt/decrypt with the same test keys
- Conflict resolution: both apps resolve the same conflicts identically
- Sync state: both apps reach the same state given the same sequence of envelopes

## Format

Test vectors are JSON files. Each contains:
- Input: a sequence of operations or envelopes
- Expected output: the resulting state or decrypted content

Both apps load these vectors and verify their implementation produces the expected output.
