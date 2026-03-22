use chrono::{Duration, Utc};
use rand::Rng;
use sqlx::PgPool;

use crate::error::AppError;

pub fn generate_code() -> String {
    let mut rng = rand::thread_rng();
    let code: u32 = rng.gen_range(100_000..1_000_000);
    format!("{code:06}")
}

pub async fn store_code(pool: &PgPool, email: &str, code: &str) -> Result<(), AppError> {
    sqlx::query("DELETE FROM verification_codes WHERE email = $1")
        .bind(email)
        .execute(pool)
        .await?;

    let expires_at = Utc::now() + Duration::minutes(10);

    sqlx::query("INSERT INTO verification_codes (email, code, expires_at) VALUES ($1, $2, $3)")
        .bind(email)
        .bind(code)
        .bind(expires_at)
        .execute(pool)
        .await?;

    Ok(())
}

pub async fn verify_code(pool: &PgPool, email: &str, code: &str) -> Result<bool, AppError> {
    let result = sqlx::query_scalar::<_, i64>(
        "DELETE FROM verification_codes WHERE email = $1 AND code = $2 AND expires_at > NOW() RETURNING 1",
    )
    .bind(email)
    .bind(code)
    .fetch_optional(pool)
    .await?;

    Ok(result.is_some())
}
