use axum::extract::State;
use axum::Json;

use crate::auth::jwt::AuthUser;
use crate::error::AppError;
use crate::AppState;

pub async fn delete_account(
    State(state): State<AppState>,
    auth: AuthUser,
) -> Result<Json<serde_json::Value>, AppError> {
    // Cascading deletes handle team_members, sessions, push_tokens
    // via FK constraints with ON DELETE CASCADE
    sqlx::query("DELETE FROM users WHERE email = $1")
        .bind(&auth.email)
        .execute(&state.db)
        .await?;

    Ok(Json(serde_json::json!({ "message": "account deleted" })))
}
