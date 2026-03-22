use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Envelope {
    pub envelope_id: Uuid,
    pub team_id: Uuid,
    pub sender_id: String,
    pub timestamp: i64,
    pub recipients: Recipients,
    pub payload: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum Recipients {
    All(String),
    Specific(Vec<String>),
}

impl Recipients {
    pub fn is_all(&self) -> bool {
        matches!(self, Recipients::All(s) if s == "all")
    }

    pub fn member_ids(&self) -> Vec<&str> {
        match self {
            Recipients::All(_) => vec![],
            Recipients::Specific(ids) => ids.iter().map(|s| s.as_str()).collect(),
        }
    }
}
