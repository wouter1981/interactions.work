use std::collections::HashMap;
use std::sync::Arc;

use sqlx::PgPool;
use tokio::sync::{mpsc, RwLock};
use uuid::Uuid;

use super::envelope::Envelope;

type Tx = mpsc::UnboundedSender<String>;

#[derive(Clone, Default)]
pub struct Relay {
    connections: Arc<RwLock<HashMap<(Uuid, String), Tx>>>,
}

impl Relay {
    pub fn new() -> Self {
        Self::default()
    }

    pub async fn register(&self, team_id: Uuid, email: String, tx: Tx) {
        self.connections
            .write()
            .await
            .insert((team_id, email), tx);
    }

    pub async fn unregister(&self, team_id: &Uuid, email: &str) {
        self.connections
            .write()
            .await
            .remove(&(*team_id, email.to_string()));
    }

    pub async fn route_envelope(&self, envelope: &Envelope, pool: &PgPool, sender_email: &str) {
        let conns = self.connections.read().await;

        if envelope.recipients.is_all() {
            // Send to all connected team members except sender
            for ((team_id, email), tx) in conns.iter() {
                if *team_id == envelope.team_id && email != sender_email {
                    let msg = serde_json::to_string(envelope).unwrap();
                    let _ = tx.send(msg);
                }
            }
            // Queue for offline members
            self.queue_for_offline(envelope, pool, sender_email).await;
        } else {
            // Send to specific recipients
            for recipient_id in envelope.recipients.member_ids() {
                let key = (envelope.team_id, recipient_id.to_string());
                if let Some(tx) = conns.get(&key) {
                    let msg = serde_json::to_string(envelope).unwrap();
                    let _ = tx.send(msg);
                } else {
                    let _ = self.queue_single(envelope, pool, recipient_id).await;
                }
            }
        }
    }

    async fn queue_for_offline(&self, envelope: &Envelope, pool: &PgPool, sender_email: &str) {
        let members: Vec<String> = sqlx::query_scalar(
            "SELECT email FROM team_members WHERE team_id = $1 AND email != $2",
        )
        .bind(envelope.team_id)
        .bind(sender_email)
        .fetch_all(pool)
        .await
        .unwrap_or_default();

        let conns = self.connections.read().await;
        for member_email in members {
            let key = (envelope.team_id, member_email.clone());
            if !conns.contains_key(&key) {
                let _ = self.queue_single(envelope, pool, &member_email).await;
            }
        }
    }

    async fn queue_single(
        &self,
        envelope: &Envelope,
        pool: &PgPool,
        recipient: &str,
    ) -> Result<(), sqlx::Error> {
        let queue_id = Uuid::new_v4(); // Each queue entry gets its own ID
        let is_broadcast = envelope.recipients.is_all();
        sqlx::query(
            "INSERT INTO envelope_queue (id, team_id, sender_id, recipient_id, encrypted_payload, is_broadcast) VALUES ($1, $2, $3, $4, $5, $6)",
        )
        .bind(queue_id)
        .bind(envelope.team_id)
        .bind(&envelope.sender_id)
        .bind(recipient)
        .bind(&envelope.payload)
        .bind(is_broadcast)
        .execute(pool)
        .await?;
        Ok(())
    }

    pub async fn deliver_queued(&self, pool: &PgPool, team_id: Uuid, email: &str, tx: &Tx) {
        let rows: Vec<(Uuid, String, String, String, bool)> = sqlx::query_as(
            "DELETE FROM envelope_queue WHERE team_id = $1 AND recipient_id = $2 AND expires_at > NOW() RETURNING id, sender_id, encrypted_payload, EXTRACT(EPOCH FROM created_at)::text, is_broadcast",
        )
        .bind(team_id)
        .bind(email)
        .fetch_all(pool)
        .await
        .unwrap_or_default();

        for (id, sender, payload, ts, is_broadcast) in rows {
            let ts_num: f64 = ts.parse().unwrap_or(0.0);
            // Reconstruct recipients: "all" for broadcasts, [recipient] for private
            let recipients: serde_json::Value = if is_broadcast {
                serde_json::json!("all")
            } else {
                serde_json::json!([email])
            };
            let env = serde_json::json!({
                "envelope_id": id,
                "team_id": team_id,
                "sender_id": sender,
                "timestamp": ts_num as i64,
                "recipients": recipients,
                "payload": payload
            });
            let _ = tx.send(env.to_string());
        }
    }
}
