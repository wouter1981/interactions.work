use axum::extract::ws::{Message, WebSocket};
use axum::extract::{Query, State, WebSocketUpgrade};
use axum::response::IntoResponse;
use futures_util::{SinkExt, StreamExt};
use serde::Deserialize;
use tokio::sync::mpsc;
use uuid::Uuid;

use crate::auth::jwt::validate_token;
use crate::error::AppError;
use crate::AppState;

use super::envelope::Envelope;

#[derive(Deserialize)]
pub struct SyncParams {
    pub token: String,
    pub team_id: Uuid,
}

pub async fn ws_handler(
    ws: WebSocketUpgrade,
    State(state): State<AppState>,
    Query(params): Query<SyncParams>,
) -> Result<impl IntoResponse, AppError> {
    let claims = validate_token(&params.token, &state.config.jwt_secret)?;
    let email = claims.sub;

    let is_member = sqlx::query_scalar::<_, bool>(
        "SELECT EXISTS(SELECT 1 FROM team_members WHERE team_id = $1 AND email = $2)",
    )
    .bind(params.team_id)
    .bind(&email)
    .fetch_one(&state.db)
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?;

    if !is_member {
        return Err(AppError::Forbidden);
    }

    let team_id = params.team_id;
    let state_clone = state.clone();

    Ok(ws.on_upgrade(move |socket| {
        handle_socket(socket, state_clone, team_id, email)
    }))
}

async fn handle_socket(socket: WebSocket, state: AppState, team_id: Uuid, email: String) {
    let (mut ws_sender, mut ws_receiver) = socket.split();
    let (tx, mut rx) = mpsc::unbounded_channel::<String>();

    state
        .relay
        .register(team_id, email.clone(), tx.clone())
        .await;

    // Deliver queued envelopes
    state
        .relay
        .deliver_queued(&state.db, team_id, &email, &tx)
        .await;

    // Forward outgoing messages to WebSocket
    let send_task = tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            if ws_sender.send(Message::Text(msg.into())).await.is_err() {
                break;
            }
        }
    });

    // Process incoming messages
    let relay = state.relay.clone();
    let pool = state.db.clone();
    let email_clone = email.clone();

    while let Some(Ok(msg)) = ws_receiver.next().await {
        if let Message::Text(text) = msg {
            match serde_json::from_str::<Envelope>(&text) {
                Ok(envelope) => {
                    if envelope.team_id == team_id {
                        relay.route_envelope(&envelope, &pool, &email_clone).await;
                    }
                }
                Err(e) => {
                    tracing::warn!("invalid envelope from {}: {}", email_clone, e);
                }
            }
        }
    }

    // Cleanup
    state.relay.unregister(&team_id, &email).await;
    send_task.abort();
    tracing::debug!("{} disconnected from team {}", email, team_id);
}
