use axum::extract::State;
use axum::Json;
use serde::{Deserialize, Serialize};

use crate::error::AppError;
use crate::AppState;

use super::code::{generate_code, store_code, verify_code};
use super::jwt::create_token;

#[derive(Deserialize)]
pub struct SendCodeRequest {
    pub email: String,
}

#[derive(Serialize)]
pub struct SendCodeResponse {
    pub message: String,
}

pub async fn send_code(
    State(state): State<AppState>,
    Json(req): Json<SendCodeRequest>,
) -> Result<Json<SendCodeResponse>, AppError> {
    let email = req.email.trim().to_lowercase();
    if email.is_empty() || !email.contains('@') {
        return Err(AppError::BadRequest("invalid email".into()));
    }

    // Ensure user exists
    sqlx::query("INSERT INTO users (email) VALUES ($1) ON CONFLICT DO NOTHING")
        .bind(&email)
        .execute(&state.db)
        .await?;

    let code = generate_code();
    store_code(&state.db, &email, &code).await?;

    crate::email::send_verification_code(&state.config.resend_api_key, &email, &code).await?;

    Ok(Json(SendCodeResponse {
        message: "verification code sent".into(),
    }))
}

#[derive(Deserialize)]
pub struct VerifyRequest {
    pub email: String,
    pub code: String,
}

#[derive(Serialize)]
pub struct VerifyResponse {
    pub token: String,
}

pub async fn verify(
    State(state): State<AppState>,
    Json(req): Json<VerifyRequest>,
) -> Result<Json<VerifyResponse>, AppError> {
    let email = req.email.trim().to_lowercase();

    let valid = verify_code(&state.db, &email, &req.code).await?;
    if !valid {
        return Err(AppError::Unauthorized);
    }

    let token = create_token(&email, &state.config.jwt_secret)?;

    Ok(Json(VerifyResponse { token }))
}
