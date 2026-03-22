use reqwest::Client;
use serde_json::json;

use crate::error::AppError;

pub async fn send_verification_code(
    api_key: &str,
    to_email: &str,
    code: &str,
) -> Result<(), AppError> {
    if api_key.is_empty() {
        tracing::info!("DEV MODE — verification code for {}: {}", to_email, code);
        return Ok(());
    }

    let client = Client::new();
    let response = client
        .post("https://api.resend.com/emails")
        .header("Authorization", format!("Bearer {api_key}"))
        .json(&json!({
            "from": "interactions.work <noreply@interactions.work>",
            "to": [to_email],
            "subject": "Your verification code",
            "text": format!("Your verification code is: {code}\n\nThis code expires in 10 minutes.")
        }))
        .send()
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;

    if !response.status().is_success() {
        let body = response.text().await.unwrap_or_default();
        return Err(AppError::Internal(format!("email send failed: {body}")));
    }

    Ok(())
}
