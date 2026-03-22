use axum::extract::State;
use axum::Json;
use serde::Deserialize;

use crate::auth::jwt::AuthUser;
use crate::error::AppError;
use crate::AppState;

#[derive(Deserialize)]
pub struct RegisterPushRequest {
    pub platform: String,
    pub token: String,
}

pub async fn register_push(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<RegisterPushRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    sqlx::query(
        "INSERT INTO push_tokens (email, platform, token) VALUES ($1, $2, $3) ON CONFLICT (email, token) DO UPDATE SET platform = $2",
    )
    .bind(&auth.email)
    .bind(&req.platform)
    .bind(&req.token)
    .execute(&state.db)
    .await?;

    Ok(Json(serde_json::json!({ "message": "registered" })))
}
