//! Authentication module
//!
//! Handles pincode-based authentication for team members.
//! The pincode is hashed with a salt and stored in the member's profile.

use rand::Rng;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

use crate::{Error, Result};

/// Salt length in bytes
const SALT_LENGTH: usize = 16;

/// Credentials stored in a member's profile
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Credentials {
    /// Salt used for hashing (hex encoded)
    pub salt: String,
    /// Hashed pincode (hex encoded)
    pub pincode_hash: String,
}

impl Credentials {
    /// Create new credentials from a pincode
    ///
    /// Generates a random salt and hashes the pincode with it.
    pub fn new(pincode: &str) -> Result<Self> {
        if pincode.len() < 4 {
            return Err(Error::InvalidConfig(
                "Pincode must be at least 4 characters".to_string(),
            ));
        }

        let salt = generate_salt();
        let pincode_hash = hash_pincode(pincode, &salt);

        Ok(Self {
            salt: hex::encode(&salt),
            pincode_hash,
        })
    }

    /// Verify a pincode against these credentials
    pub fn verify(&self, pincode: &str) -> bool {
        let salt = match hex::decode(&self.salt) {
            Ok(s) => s,
            Err(_) => return false,
        };

        let hash = hash_pincode(pincode, &salt);
        // Constant-time comparison to prevent timing attacks
        constant_time_eq(&hash, &self.pincode_hash)
    }

    /// Update the pincode (creates new salt)
    pub fn update_pincode(&mut self, new_pincode: &str) -> Result<()> {
        if new_pincode.len() < 4 {
            return Err(Error::InvalidConfig(
                "Pincode must be at least 4 characters".to_string(),
            ));
        }

        let salt = generate_salt();
        self.pincode_hash = hash_pincode(new_pincode, &salt);
        self.salt = hex::encode(&salt);
        Ok(())
    }
}

/// Generate a random salt
fn generate_salt() -> Vec<u8> {
    let mut rng = rand::thread_rng();
    (0..SALT_LENGTH).map(|_| rng.gen()).collect()
}

/// Hash a pincode with a salt
fn hash_pincode(pincode: &str, salt: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(salt);
    hasher.update(pincode.as_bytes());
    hex::encode(hasher.finalize())
}

/// Constant-time string comparison to prevent timing attacks
fn constant_time_eq(a: &str, b: &str) -> bool {
    if a.len() != b.len() {
        return false;
    }

    let mut result = 0u8;
    for (x, y) in a.bytes().zip(b.bytes()) {
        result |= x ^ y;
    }
    result == 0
}

/// Member credentials stored in .team/members/{email}/credentials.yaml
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MemberCredentials {
    /// The member's email
    pub email: String,
    /// The member's credentials
    pub credentials: Credentials,
}

impl MemberCredentials {
    /// Create new member credentials
    pub fn new(email: impl Into<String>, pincode: &str) -> Result<Self> {
        Ok(Self {
            email: email.into(),
            credentials: Credentials::new(pincode)?,
        })
    }

    /// Verify the pincode
    pub fn verify(&self, pincode: &str) -> bool {
        self.credentials.verify(pincode)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_credentials_creation() {
        let creds = Credentials::new("1234").unwrap();
        assert!(!creds.salt.is_empty());
        assert!(!creds.pincode_hash.is_empty());
    }

    #[test]
    fn test_credentials_verification() {
        let creds = Credentials::new("mypin123").unwrap();
        assert!(creds.verify("mypin123"));
        assert!(!creds.verify("wrongpin"));
        assert!(!creds.verify("mypin12"));
        assert!(!creds.verify("mypin1234"));
    }

    #[test]
    fn test_pincode_too_short() {
        let result = Credentials::new("123");
        assert!(result.is_err());
    }

    #[test]
    fn test_update_pincode() {
        let mut creds = Credentials::new("oldpin").unwrap();
        let old_hash = creds.pincode_hash.clone();
        let old_salt = creds.salt.clone();

        creds.update_pincode("newpin123").unwrap();

        assert!(creds.verify("newpin123"));
        assert!(!creds.verify("oldpin"));
        assert_ne!(creds.pincode_hash, old_hash);
        assert_ne!(creds.salt, old_salt);
    }

    #[test]
    fn test_member_credentials() {
        let member_creds = MemberCredentials::new("user@example.com", "secret").unwrap();
        assert_eq!(member_creds.email, "user@example.com");
        assert!(member_creds.verify("secret"));
        assert!(!member_creds.verify("wrong"));
    }

    #[test]
    fn test_credentials_serialization() {
        let creds = Credentials::new("testpin").unwrap();
        let yaml = serde_yaml::to_string(&creds).unwrap();
        let parsed: Credentials = serde_yaml::from_str(&yaml).unwrap();

        assert_eq!(creds.salt, parsed.salt);
        assert_eq!(creds.pincode_hash, parsed.pincode_hash);
        assert!(parsed.verify("testpin"));
    }

    #[test]
    fn test_different_salts_produce_different_hashes() {
        let creds1 = Credentials::new("samepin").unwrap();
        let creds2 = Credentials::new("samepin").unwrap();

        // Same pincode but different salts should produce different hashes
        assert_ne!(creds1.salt, creds2.salt);
        assert_ne!(creds1.pincode_hash, creds2.pincode_hash);

        // But both should verify correctly
        assert!(creds1.verify("samepin"));
        assert!(creds2.verify("samepin"));
    }
}
